# Testing Variable Fonts Implementation

## Setup

### Download Test Fonts

For testing, download one or more variable fonts:

1. **Inter** (recommended for initial testing)
   - Download from: https://github.com/rsms/inter/releases
   - File: `Inter-VariableFont.ttf` or `InterVariable.ttf`
   - Axes: `wght` (100-900), `slnt` (-10 to 0)

2. **Roboto Flex**
   - Download from: https://github.com/googlefonts/roboto-flex
   - Has many axes including `wght`, `wdth`, `GRAD`, etc.
   - Good for future multi-axis testing

3. **Source Sans Variable**
   - Download from: https://github.com/adobe-fonts/source-sans
   - Simpler variable font with `wght` axis only

Place downloaded fonts in a test directory:
```bash
mkdir -p ~/typst-test-fonts
cp /path/to/downloaded/InterVariable.ttf ~/typst-test-fonts/
```

## Phase 0: Baseline Testing

Before any changes, verify current behavior:

```bash
# Compile with variable font (will use default weight only)
cargo run --release -- compile \
  --font-path ~/typst-test-fonts \
  tests/suite/text/variable-fonts-basic.typ \
  baseline.pdf

# Open baseline.pdf
# Expected: All text renders at the same weight (default, usually 400)
```

## Phase 1: Detection Testing

After implementing variable font detection:

```bash
# Build with detection code
cargo build --release

# The build should succeed
# Fonts should load without errors
# No visible changes to output yet

# Optional: Add debug output to Font::new() to verify fvar detection
# Look for console output showing detected axes
```

### Expected Results:
- Build succeeds
- No crashes when loading variable fonts
- Static fonts still work normally

## Phase 2: Mapping Testing

After implementing weight-to-axis mapping:

```bash
# Build with mapping code
cargo build --release

# Compile test file
cargo run --release -- compile \
  --font-path ~/typst-test-fonts \
  tests/suite/text/variable-fonts-basic.typ \
  phase2.pdf
```

### Expected Results:
- Build succeeds
- PDF compiles without errors
- **Still no visible weight changes** (shaping not integrated yet)

## Phase 3: Shaping Testing

After integrating rustybuzz variations:

```bash
# Build with shaping integration
cargo build --release

# Compile to SVG first (easier to debug)
cargo run --release -- compile \
  --font-path ~/typst-test-fonts \
  tests/suite/text/variable-fonts-basic.typ \
  phase3.svg

# Open phase3.svg in a browser
# EXPECTED: Different weights should be VISIBLE!

# Also test PNG
cargo run --release -- compile \
  --font-path ~/typst-test-fonts \
  tests/suite/text/variable-fonts-basic.typ \
  phase3.png
```

### Expected Results:
- SVG/PNG shows different weights correctly
- Thin text is visibly thinner than black text
- Regular weight looks normal

### Success Criteria for Phase 3:
✅ Eight lines of text with visibly different weights
✅ No crashes or errors
✅ Text is readable and properly shaped

## Phase 4: PDF Instancing Testing

After implementing allsorts font instancing:

```bash
# Build with instancing code
cargo build --release

# Compile to PDF
cargo run --release -- compile \
  --font-path ~/typst-test-fonts \
  tests/suite/text/variable-fonts-basic.typ \
  final.pdf

# Open in multiple viewers
xdg-open final.pdf  # Linux default viewer
# Also test in Chrome, Firefox, Adobe Acrobat if available
```

### Expected Results:
- PDF opens without errors
- Different weights render correctly
- Text is selectable
- Text is searchable (select text, copy-paste should work)

### Debugging PDF Output:

```bash
# Check PDF structure
pdfinfo final.pdf

# Extract text to verify it's embedded correctly
pdftotext final.pdf final.txt
cat final.txt

# Examine font embedding (if you have pdftk or similar)
# Should see multiple font instances, one per weight
```

### Success Criteria for Phase 4:
✅ PDF displays different weights correctly in all viewers
✅ Text is selectable and copyable
✅ Text search works
✅ No PDF validation errors
✅ File size is reasonable (will be larger than non-variable due to multiple instances)

## Comprehensive Testing

### Test with Multiple Fonts

Create additional test files for different variable fonts:

```typ
// test-roboto-flex.typ
#set text(font: "Roboto Flex")
#text(weight: "thin")[Thin]
#text(weight: "bold")[Bold]
#text(weight: "black")[Black]
```

### Test Mixed Documents

```typ
// test-mixed.typ
// Mix variable and static fonts
#set text(font: "Inter")
#text(weight: "bold")[Variable font bold text]

#set text(font: "Liberation Sans")
#text(weight: "bold")[Static font bold text]
```

### Test Edge Cases

```typ
// test-edge-cases.typ
#set text(font: "Inter")

// Weight outside font's range (should clamp)
#text(weight: 50)[Weight 50 (should clamp to 100)]

// Numeric weight
#text(weight: 450)[Weight 450]

// Very large document with many weight changes
#for i in range(100) [
  #text(weight: "bold")[Bold ] #text(weight: "regular")[Regular ]
]
```

## Performance Testing

```bash
# Test compilation time
time cargo run --release -- compile \
  --font-path ~/typst-test-fonts \
  large-variable-font-doc.typ \
  large.pdf

# Compare with static font version
time cargo run --release -- compile \
  --font-path ~/typst-test-fonts \
  large-static-font-doc.typ \
  large-static.pdf
```

## Regression Testing

Ensure static fonts still work:

```bash
# Test with static fonts only (no variable fonts)
cargo run --release -- compile \
  tests/suite/text/text-basic.typ \
  static-test.pdf

# Should work exactly as before
```

## Validation Testing

### PDF Validators

If available, validate PDF output:

```bash
# VeraPDF (if installed)
verapdf final.pdf

# PDF/A validation
# Some validators available online
```

### Font Validation

Check that fonts are correctly embedded:

```bash
# Use pdffonts (from poppler-utils)
pdffonts final.pdf

# Expected output: Multiple entries for the variable font,
# one per weight instance used
```

## Debugging Tips

### Enable Debug Output

Add to your code temporarily:

```rust
println!("DEBUG: Font {} is variable: {}", font.info().family, is_variable);
println!("DEBUG: wght axis range: {}-{}", min_wght, max_wght);
println!("DEBUG: Requested weight: {}, clamped to: {}", requested, clamped);
println!("DEBUG: Instancing font with wght={}", wght_value);
```

### Check Shaping Output

In shaping code:

```rust
println!("DEBUG: Shaping with variations: {:?}", variations);
println!("DEBUG: Glyph advances: {:?}", shaped_glyphs.iter().map(|g| g.x_advance));
```

### Check PDF Font Embedding

In text.rs:

```rust
println!("DEBUG: Building font {} with coords {:?}", font.info().family, coords);
println!("DEBUG: Font data size: {} bytes", font_data.len());
```

## Known Issues to Watch For

1. **Memoization Cache**: Ensure different weights create different cache entries
2. **Font Index**: Instanced fonts should use index 0 (they're no longer collections)
3. **Memory Usage**: Multiple instances can increase memory usage
4. **Subsetting**: Verify each instance is subsetted correctly by krilla

## Success Metrics

The implementation is successful when:

1. ✅ Variable fonts are detected correctly
2. ✅ Weight parameter correctly maps to wght axis
3. ✅ SVG/PNG output shows different weights
4. ✅ PDF output shows different weights in all viewers
5. ✅ Text is selectable and searchable
6. ✅ Static fonts continue to work normally
7. ✅ No crashes or panics
8. ✅ Performance is acceptable (< 2x slowdown for typical documents)
9. ✅ File sizes are reasonable
10. ✅ All existing tests still pass
