use crate::foundations::{Content, Smart, elem};
use crate::layout::{Em, Ratio};
use crate::text::TextSize;

/// Displays text in small capitals.
///
/// # Example
/// ```example
/// Hello \
/// #smallcaps[Hello]
/// ```
///
/// # Smallcaps fonts
/// By default, this uses the `smcp` and `c2sc` OpenType features on the font.
/// Not all fonts support these features. Sometimes, smallcaps are part of a
/// dedicated font. This is, for example, the case for the _Latin Modern_ family
/// of fonts. In those cases, you can use a show-set rule to customize the
/// appearance of the text in smallcaps:
///
/// ```typ
/// #show smallcaps: set text(font: "Latin Modern Roman Caps")
/// ```
///
/// # Synthetic small caps
/// When a font doesn't support small caps via OpenType features, or only
/// supports them for some characters (partial coverage), Typst can
/// automatically synthesize small caps by scaling and transforming uppercase
/// letters. This happens automatically when `typographic` is `true` (default)
/// and the font lacks small caps support.
///
/// When `typographic` is `true`, Typst uses font small caps where available
/// and synthesizes only the missing characters. When `typographic` is `false`,
/// all small caps are synthesized regardless of font support.
///
/// ```example
/// #smallcaps[Hello World]
/// #smallcaps(typographic: false)[Hello World]
/// ```
///
/// # Smallcaps headings
/// You can use a [show rule]($styling/#show-rules) to apply smallcaps
/// formatting to all your headings. In the example below, we also center-align
/// our headings and disable the standard bold font.
///
/// ```example
/// #set par(justify: true)
/// #set heading(numbering: "I.")
///
/// #show heading: smallcaps
/// #show heading: set align(center)
/// #show heading: set text(
///   weight: "regular"
/// )
///
/// = Introduction
/// #lorem(40)
/// ```
#[elem(title = "Small Capitals")]
pub struct SmallcapsElem {
    /// Whether to use small caps glyphs from the font if available.
    ///
    /// Ideally, small caps glyphs are provided by the font (using the `smcp`
    /// and `c2sc` OpenType features). Otherwise, Typst is able to synthesize
    /// small caps by scaling and transforming uppercase letters.
    ///
    /// When this is set to `{false}`, synthesized small caps will be used
    /// regardless of whether the font provides dedicated small caps glyphs.
    /// When `{true}`, synthesized small caps may still be used in case the font
    /// does not provide the necessary small caps glyphs, or only provides them
    /// for some characters (partial coverage).
    ///
    /// ```example
    /// #smallcaps(typographic: true)[Hello] \
    /// #smallcaps(typographic: false)[Hello]
    /// ```
    #[default(true)]
    pub typographic: bool,

    /// The font size for synthesized small caps.
    ///
    /// This only applies to synthesized small caps. In other words, this has no
    /// effect if `typographic` is `{true}` and the font provides the necessary
    /// small caps glyphs.
    ///
    /// If set to `{auto}`, the size is scaled to `0.75em` relative to the base
    /// font size.
    ///
    /// ```example
    /// #smallcaps(typographic: false, size: 0.8em)[Hello] \
    /// #smallcaps(typographic: false, size: 0.7em)[Hello]
    /// ```
    pub size: Smart<TextSize>,

    /// The horizontal expansion factor for synthesized small caps glyph width.
    ///
    /// This only applies to synthesized small caps. A value of `{auto}` uses a
    /// default of `1.05` (5% wider) to better match true small caps proportions.
    ///
    /// ```example
    /// #smallcaps(typographic: false, expansion: 1.1)[Hello] \
    /// #smallcaps(typographic: false, expansion: 1.0)[Hello]
    /// ```
    #[default(Smart::Auto)]
    pub expansion: Smart<Ratio>,

    /// Whether to turn uppercase letters into small capitals as well.
    ///
    /// Unless overridden by a show rule, this enables the `c2sc` OpenType
    /// feature.
    ///
    /// ```example
    /// #smallcaps(all: true)[UNICEF] is an
    /// agency of #smallcaps(all: true)[UN].
    /// ```
    #[default(false)]
    pub all: bool,
    /// The content to display in small capitals.
    #[required]
    pub body: Content,
}

/// What becomes small capitals.
#[derive(Debug, Copy, Clone, Eq, PartialEq, Hash)]
pub enum Smallcaps {
    /// Minuscules become small capitals.
    Minuscules,
    /// All letters become small capitals.
    All,
}

/// Configuration values for synthetic small caps.
#[derive(Debug, Copy, Clone, Eq, PartialEq, Hash)]
pub struct SmallcapsSettings {
    /// Whether to use OpenType features if available.
    pub typographic: bool,
    /// The font size for synthesized small caps (only applies to synthesized glyphs).
    pub size: Smart<Em>,
    /// The horizontal expansion factor for synthesized small caps glyph width.
    ///
    /// A value of [`Smart::Auto`] uses a default of `1.05`.
    pub expansion: Smart<Ratio>,
    /// Whether to turn uppercase letters into small capitals as well.
    pub all: bool,
}

impl Default for SmallcapsSettings {
    fn default() -> Self {
        Self {
            typographic: true,
            size: Smart::Auto,
            expansion: Smart::Auto,
            all: false,
        }
    }
}
