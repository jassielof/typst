use std::ops::Range;
use std::sync::Arc;

use bytemuck::TransparentWrapper;
use krilla::surface::{Location, Surface};
use krilla::text::GlyphId;
use typst_library::diag::{SourceResult, bail};
use typst_library::layout::Size;
use typst_library::text::{Font, Glyph, TextItem, VariationCoordinates};
use typst_library::visualize::FillRule;
use typst_syntax::Span;
use typst_utils::defer;

use crate::convert::{FrameContext, GlobalContext};
use crate::instance::{instance_variable_font, recalculate_advances_from_instanced};
use crate::util::{AbsExt, TransformExt, display_font};
use crate::{paint, tags};

#[typst_macros::time(name = "handle text")]
pub(crate) fn handle_text(
    fc: &mut FrameContext,
    t: &TextItem,
    surface: &mut Surface,
    gc: &mut GlobalContext,
) -> SourceResult<()> {
    let mut handle = tags::text(gc, fc, surface, t);
    let surface = handle.surface();

    // For variable fonts, verify that instanced font advances match rustybuzz advances
    // and adjust if necessary to fix spacing issues
    let t = if t.font.is_variable() && t.variation_coords.is_some() {
        adjust_glyph_advances_for_instanced_font(t, gc).unwrap_or_else(|_| t.clone())
    } else {
        t.clone()
    };

    let font = convert_font(gc, t.font.clone(), t.variation_coords)?;
    let fill = paint::convert_fill(
        gc,
        &t.fill,
        FillRule::NonZero,
        true,
        surface,
        fc.state(),
        Size::zero(),
    )?;
    let stroke =
        if let Some(stroke) = t.stroke.as_ref().map(|s| {
            paint::convert_stroke(gc, s, true, surface, fc.state(), Size::zero())
        }) {
            Some(stroke?)
        } else {
            None
        };
    let text = t.text.as_str();
    let size = t.size;
    let glyphs: &[PdfGlyph] = TransparentWrapper::wrap_slice(t.glyphs.as_slice());

    surface.push_transform(&fc.state().transform().to_krilla());
    let mut surface = defer(surface, |s| s.pop());
    surface.set_fill(Some(fill));
    surface.set_stroke(stroke);
    surface.draw_glyphs(
        krilla::geom::Point::from_xy(0.0, 0.0),
        glyphs,
        font.clone(),
        text,
        size.to_f32(),
        false,
    );

    Ok(())
}

/// Memoized function to get instanced font data.
/// This avoids re-instancing the same font multiple times.
#[comemo::memoize]
fn get_instanced_font_data(
    typst_font: Font,
    coords: VariationCoordinates,
) -> Result<Vec<u8>, String> {
    instance_variable_font(
        typst_font.data().as_slice(),
        &coords,
        typst_font.variation_info(),
        typst_font.is_cff2(),
    )
}

/// Adjust glyph advance widths to match the instanced font's advances.
///
/// This fixes spacing issues where rustybuzz-calculated advances don't match
/// the instanced font's advances. We recalculate advances from the instanced
/// font and update the glyphs accordingly.
fn adjust_glyph_advances_for_instanced_font(
    t: &TextItem,
    _gc: &mut GlobalContext,
) -> SourceResult<TextItem> {
    use typst_library::layout::Em;

    // We need to get the instanced font data to recalculate advances
    // Use the memoized function to avoid re-instancing
    let instanced_data = if t.font.is_variable()
        && t.variation_coords.is_some()
        && t.variation_coords.as_ref().is_some_and(|c| c.has_any())
    {
        let coords = t.variation_coords.unwrap();
        match get_instanced_font_data(t.font.clone(), coords) {
            Ok(data) => data,
            Err(_) => return Ok(t.clone()), // If instancing fails, use original
        }
    } else {
        return Ok(t.clone()); // Not a variable font or no coords
    };

    // Recalculate advances from instanced font
    let glyph_ids: Vec<u16> = t.glyphs.iter().map(|g| g.id).collect();
    let units_per_em = t.font.units_per_em();

    match recalculate_advances_from_instanced(&instanced_data, &glyph_ids, units_per_em) {
        Ok(instanced_advances_units) => {
            // Convert font units to Em and update glyphs
            let mut updated_glyphs = t.glyphs.clone();
            let mut has_changes = false;

            for (glyph, &advance_units) in updated_glyphs.iter_mut().zip(instanced_advances_units.iter()) {
                let instanced_advance_em = Em::from_units(advance_units as f64, units_per_em);
                let original_advance_em = glyph.x_advance;

                // Only update if there's a significant difference
                // We use a small threshold to avoid rounding errors, but catch real mismatches
                // Threshold: 0.1% of the advance or 0.5 font units (whichever is larger)
                let threshold = (original_advance_em.get().abs() * 0.001).max(0.5 / units_per_em);
                let diff = (instanced_advance_em.get() - original_advance_em.get()).abs();
                if diff > threshold {
                    glyph.x_advance = instanced_advance_em;
                    has_changes = true;
                }
            }

            if has_changes {
                Ok(TextItem {
                    glyphs: updated_glyphs,
                    ..t.clone()
                })
            } else {
                Ok(t.clone())
            }
        }
        Err(_) => {
            // If recalculation fails, use original
            Ok(t.clone())
        }
    }
}

fn convert_font(
    gc: &mut GlobalContext,
    typst_font: Font,
    variation_coords: Option<VariationCoordinates>,
) -> SourceResult<krilla::text::Font> {
    // Check if we need instancing (variable font with coordinates)
    let needs_instancing = typst_font.is_variable()
        && variation_coords.is_some()
        && variation_coords.as_ref().is_some_and(|c| c.has_any());

    if !needs_instancing {
        // For non-variable fonts or fonts without variation coords, use simple cache
        if let Some(font) = gc.fonts_forward.get(&typst_font) {
            return Ok(font.clone());
        }
    }

    // Build the font (with instancing if needed)
    // The comemo::memoize on build_font will cache based on both font and coords
    // PDF version is checked inside build_font to determine if native variable fonts are supported
    let pdf_version_str = gc.options.standards.config.version().as_str();
    let font = build_font(typst_font.clone(), variation_coords, pdf_version_str)?;

    // Only cache in the simple forward cache if we don't have variation coordinates
    // Variable fonts with coordinates are handled by comemo memoization in build_font
    if !needs_instancing {
        gc.fonts_forward.insert(typst_font.clone(), font.clone());
        gc.fonts_backward.insert(font.clone(), typst_font.clone());
    }

    Ok(font)
}

#[comemo::memoize]
fn build_font(
    typst_font: Font,
    variation_coords: Option<VariationCoordinates>,
    _pdf_version_str: &str, // Reserved for future PDF 2.0 native variable font support
) -> SourceResult<krilla::text::Font> {
    // Always instance variable fonts for now, since krilla doesn't support
    // native variable fonts yet (even in PDF 2.0).
    // TODO: Once krilla supports native variable fonts in PDF 2.0, we can skip
    // instancing here and pass the variable font directly to krilla for PDF 2.0+.
    let font_data = if typst_font.is_variable()
        && variation_coords.is_some()
        && variation_coords.as_ref().is_some_and(|c| c.has_any())
    {
        // Instance the variable font with the given coordinates
        // Use the memoized function to avoid duplicate instancing
        let coords = variation_coords.unwrap();
        let instanced_data = match get_instanced_font_data(typst_font.clone(), coords) {
            Ok(data) => data,
            Err(e) => {
                return Err(bail!(
                    Span::detached(),
                    "failed to instance variable font {}: {}",
                    display_font(Some(&typst_font)),
                    e
                ))
            }
        };
        Arc::new(instanced_data) as Arc<dyn AsRef<[u8]> + Send + Sync>
    } else {
        // Use original font data for static fonts or variable fonts without coordinates
        Arc::new(typst_font.data().clone())
    };

    match krilla::text::Font::new(font_data.into(), typst_font.index()) {
        Some(f) => Ok(f),
        None => {
            bail!(
                Span::detached(),
                "failed to process {}",
                display_font(Some(&typst_font))
            )
        }
    }
}

#[derive(Debug, TransparentWrapper)]
#[repr(transparent)]
struct PdfGlyph(Glyph);

impl krilla::text::Glyph for PdfGlyph {
    #[inline(always)]
    fn glyph_id(&self) -> GlyphId {
        GlyphId::new(self.0.id as u32)
    }

    #[inline(always)]
    fn text_range(&self) -> Range<usize> {
        self.0.range.start as usize..self.0.range.end as usize
    }

    #[inline(always)]
    fn x_advance(&self, size: f32) -> f32 {
        // Don't use `Em::at`, because it contains an expensive check whether the result is finite.
        self.0.x_advance.get() as f32 * size
    }

    #[inline(always)]
    fn x_offset(&self, size: f32) -> f32 {
        // Don't use `Em::at`, because it contains an expensive check whether the result is finite.
        self.0.x_offset.get() as f32 * size
    }

    #[inline(always)]
    fn y_offset(&self, size: f32) -> f32 {
        // Don't use `Em::at`, because it contains an expensive check whether the result is finite.
        self.0.y_offset.get() as f32 * size
    }

    #[inline(always)]
    fn y_advance(&self, size: f32) -> f32 {
        // Don't use `Em::at`, because it contains an expensive check whether the result is finite.
        self.0.y_advance.get() as f32 * size
    }

    fn location(&self) -> Option<Location> {
        Some(self.0.span.0.into_raw())
    }
}
