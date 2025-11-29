# Variable Fonts Implementation Notes

## Current Codebase Architecture (v0.14.0)

### Font Loading & Storage
**Location:** `crates/typst-library/src/text/font/mod.rs`

- `Font` struct (lines 26-192): Main font type
  - Contains `Arc<Repr>` with:
    - `ttf_parser::Face` - for font parsing
    - `rustybuzz::Face` - for text shaping
    - `FontInfo` - metadata
    - `FontMetrics` - metrics
    - `Bytes data` - raw font data

- Font creation: `Font::new(data: Bytes, index: u32)` at line 56
  - Parses both ttf-parser and rustybuzz faces
  - Extracts metrics and info

**Location:** `crates/typst-library/src/text/font/variant.rs`

- `FontVariant` struct (line 12): Style, weight, stretch
- `FontWeight` struct (line 75): Numeric weight 100-900
  - Already matches OpenType `wght` axis values!
  - Constants: THIN(100), LIGHT(300), REGULAR(400), BOLD(700), BLACK(900)

**Location:** `crates/typst-kit/src/fonts.rs`

- `FontSearcher`: Discovers fonts from system/directories
- `FontSlot`: Lazy-loads fonts on demand
- Uses `fontdb` for font discovery

### Text Shaping
**Location:** `crates/typst-layout/src/inline/shaping.rs`

- `ShapedGlyph` struct (line 132): Result of shaping
  - Contains: `font`, `glyph_id`, `x_advance`, `x_offset`, `y_offset`, `size`
- Text shaping happens here using rustybuzz
- **KEY:** Need to find where rustybuzz::shape() is called to add variations

### PDF Export
**Location:** `crates/typst-pdf/src/text.rs`

- `handle_text()` (line 19): Main text rendering function
- `convert_font()` (line 66): Converts Typst font to Krilla font
- **KEY:** `build_font()` (line 83): Memoized font conversion
  - Currently just passes `typst_font.data()` directly to krilla
  - **THIS IS WHERE WE INSTANCE VARIABLE FONTS**

```rust
#[comemo::memoize]
fn build_font(typst_font: Font) -> SourceResult<krilla::text::Font> {
    let font_data: Arc<dyn AsRef<[u8]> + Send + Sync> =
        Arc::new(typst_font.data().clone());

    match krilla::text::Font::new(font_data.into(), typst_font.index()) {
        Some(f) => Ok(f),
        None => bail!(...)
    }
}
```

### Dependencies
- `ttf-parser = "0.25.0"` - Font parsing (has variable font support)
- `rustybuzz = "0.20"` - Text shaping (supports variations)
- `krilla` - PDF generation (does NOT support variable fonts)

## Implementation Strategy

### Phase 1: Variable Font Detection
**Goal:** Detect fvar table and extract axis information

**Changes:**
1. Create `crates/typst-library/src/text/font/variation.rs`:
   - `VariationAxis` struct: tag, min, max, default, name_id
   - `VariationInfo` struct: Vec<VariationAxis>, is_variable bool

2. Modify `crates/typst-library/src/text/font/mod.rs`:
   - Add `variation_info: VariationInfo` field to `Repr` struct
   - In `Font::new()`, parse fvar table using ttf-parser
   - Add helper methods: `has_wght_axis()`, `get_wght_range()`

**ttf-parser API:**
```rust
if let Some(fvar) = ttf.tables().fvar {
    for axis in fvar.axes {
        // axis.tag, axis.min_value, axis.default_value, axis.max_value
    }
}
```

### Phase 2: Axis Value Mapping
**Goal:** Map FontWeight to wght axis coordinate

**Changes:**
1. Create `VariationCoordinates` struct:
   ```rust
   pub struct VariationCoordinates {
       pub wght: Option<f32>,
       // Future: wdth, ital, slnt
   }
   ```

2. Function to compute coordinates:
   ```rust
   fn compute_variation_coords(
       font: &Font,
       variant: FontVariant
   ) -> Option<VariationCoordinates> {
       if !font.is_variable() {
           return None;
       }

       let mut coords = VariationCoordinates::default();

       if let Some(wght_axis) = font.get_wght_axis() {
           let weight_value = variant.weight.to_number() as f32;
           coords.wght = Some(weight_value.clamp(
               wght_axis.min_value,
               wght_axis.max_value
           ));
       }

       Some(coords)
   }
   ```

3. Store coordinates somewhere accessible during shaping and PDF export
   - Possibly in `ShapedGlyph` or `TextItem`

### Phase 3: Shaping Integration
**Goal:** Pass variation coordinates to rustybuzz

**Location:** `crates/typst-layout/src/inline/shaping.rs`

**Changes:**
- Before calling `rustybuzz::shape()`, set variations:
  ```rust
  if let Some(coords) = variation_coords {
      let mut variations = Vec::new();
      if let Some(wght) = coords.wght {
          variations.push(rustybuzz::Variation {
              tag: rustybuzz::Tag::from_bytes(b"wght"),
              value: wght,
          });
      }
      face.set_variations(&variations);
  }
  ```

**Test:** Compile to SVG/PNG and verify different weights render correctly

### Phase 4: Font Instancing for PDF
**Goal:** Convert variable font to static instance before passing to krilla

**Dependencies:**
Add to `crates/typst-pdf/Cargo.toml`:
```toml
allsorts = "0.15"  # or latest version
```

**Implementation:**

1. Create `crates/typst-pdf/src/font/instance.rs`:
   ```rust
   use allsorts::font::Font;
   use allsorts::variations::instance;

   pub fn instance_variable_font(
       font_data: &[u8],
       wght: f32,
   ) -> Result<Vec<u8>, Box<dyn Error>> {
       let font = Font::new(font_data)?;
       let settings = vec![(b"wght", wght)];
       let instanced = instance(&font, &settings)?;
       Ok(instanced)
   }
   ```

2. Modify `crates/typst-pdf/src/text.rs`:
   ```rust
   #[comemo::memoize]
   fn build_font(
       typst_font: Font,
       variation_coords: Option<VariationCoordinates>
   ) -> SourceResult<krilla::text::Font> {
       let font_data = if let Some(coords) = variation_coords {
           if let Some(wght) = coords.wght {
               // Instance the font
               let instanced = instance_variable_font(
                   typst_font.data(),
                   wght
               )?;
               Arc::new(Bytes::from(instanced))
           } else {
               Arc::new(typst_font.data().clone())
           }
       } else {
           Arc::new(typst_font.data().clone())
       };

       // Pass instanced font to krilla
       match krilla::text::Font::new(font_data.into(), 0) {
           Some(f) => Ok(f),
           None => bail!(...)
       }
   }
   ```

**Important:** Memoization key must include variation coordinates!

### Phase 5: Testing & Validation

**Test files:**
- `tests/suite/text/variable-fonts-basic.typ`
- `tests/suite/text/variable-fonts-weights.typ`

**Manual testing:**
1. Compile to PDF with different weights
2. Verify text renders correctly in Adobe Acrobat, Chrome, Firefox
3. Verify text is selectable and searchable
4. Check file size (each weight instance = separate font in PDF)

**Performance:**
- Instance caching is critical (avoid re-instancing same font+weight combo)
- Memoization should handle this automatically

## Key Files to Modify

```
crates/typst-library/src/text/font/
├── mod.rs                    # Add VariationInfo to Font
└── variation.rs              # NEW: VariationAxis, VariationInfo

crates/typst-layout/src/inline/
└── shaping.rs                # Add rustybuzz variation support

crates/typst-pdf/src/
├── Cargo.toml                # Add allsorts dependency
├── text.rs                   # Modify build_font() for instancing
└── font/
    ├── mod.rs                # NEW module
    └── instance.rs           # NEW: Instancing logic
```

## Testing Strategy

### Checkpoint 1: Detection Working
```bash
# After Phase 1
cargo build
cargo run -- compile --font-path /path/to/Inter.ttf test.typ
# Should not crash, fonts should load normally
```

### Checkpoint 2: Shaping Working
```bash
# After Phase 3
cargo run -- compile test.typ test.svg
# Open test.svg - different weights should be visible
```

### Checkpoint 3: PDF Working
```bash
# After Phase 4
cargo run -- compile test.typ test.pdf
# Open test.pdf - different weights should render correctly
```

## Notes

- **DO NOT modify krilla** - We instance fonts BEFORE passing to krilla
- **Start with wght only** - Other axes are future work
- **TrueType only** - CFF2 variable fonts need different approach
- **PDF 1.7** - Native variable fonts require PDF 2.0
- **Test incrementally** - Each phase should be testable independently

## Future Work

- Support for `wdth` axis (stretch)
- Support for `slnt`/`ital` axes (italic/slant)
- Support for CFF2 variable fonts
- Native PDF 2.0 variable font embedding (no instancing)
- Custom axis support (`GRAD`, designer axes)
- Optimize instance caching
- Font subsetting of instanced fonts
