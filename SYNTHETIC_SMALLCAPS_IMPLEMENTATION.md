# Synthetic Small Caps Implementation Summary

## Overview

This document explains how synthetic (fake) small caps are implemented in Typst, following the feedback from Laurenz, Malo, and Saffronner, and aligning with the revised plan that follows the `sub`/`super` script pattern.

## Implementation Strategy

### 1. API Design (Following Sub/Super Pattern)

**Parameter: `typographic: bool` (default: `true`)**
- **`typographic: true`** (default): Try OpenType font features first, automatically fall back to synthesis if font doesn't support small caps or has partial coverage
- **`typographic: false`**: Always synthesize, regardless of font support

**Additional Parameters:**
- **`size: Smart<TextSize>`**: Font size for synthesized small caps only (default: `auto` = `0.75em`)
- **`expansion: Smart<Ratio>`**: Horizontal expansion factor for glyph width (default: `auto` = `1.05`)
- **`all: bool`**: Whether to transform uppercase letters too (default: `false`)

### 2. Processing Pipeline

The implementation uses a **two-phase approach**:

#### Phase 1: Text Collection (`collect.rs`)
- **Purpose**: String-level preprocessing
- **When `typographic: false` AND `all: true`**: Transforms all text to uppercase early
- **Otherwise**: Leaves text as-is (deferred to shaping phase)
- **Why**: When `all: false`, we need to track which characters were originally lowercase

#### Phase 2: Text Shaping (`shaping.rs`)
- **Purpose**: Font-level processing and glyph generation
- **Font support check**: `check_smallcaps_support()` verifies OpenType `smcp`/`c2sc` support
- **Per-character check**: `font_has_smallcap_for_char()` checks individual character support (for partial coverage)
- **Fallback logic**: If font doesn't support or has partial coverage, synthesizes missing characters
- **Case transformation**: When needed and not pre-transformed, transforms lowercase → uppercase
- **Synthesis application**: Per-glyph, only for characters that need it

### 3. Key Components

#### `SmallcapsSettings` Struct
```rust
pub struct SmallcapsSettings {
    typographic: bool,      // Use font features if available
    size: Smart<Em>,        // Size for synthesized glyphs (default: 0.75em)
    expansion: Smart<Ratio>, // Width expansion (default: 1.05)
    all: bool,             // Transform uppercase too
}
```

#### Show Rule Logic (`rules.rs`)
- Always sets `smallcaps_settings` for case transformation capability
- When `typographic: true`: Also sets `smallcaps` to try OpenType features first
- When `typographic: false`: Only sets `smallcaps_settings` (forces synthesis)
- Converts `TextSize` to `Em` (following sub/super pattern)

#### Synthesis Transformations
1. **Case transformation**: lowercase → uppercase (selective when `all: false`)
2. **Size scaling**: Uses `size` parameter (default: `0.75em`) for synthesized glyphs only
3. **Width expansion**: `x_advance = x_advance * expansion` (default: `1.05`)
4. **Selective application**: When `typographic: true`, uses font small caps where available, synthesizes only missing characters

### 4. Partial Coverage Handling

**Problem**: Fonts may have small caps for some letters but not others.

**Solution**: Per-character checking
- `font_has_smallcap_for_char()`: Checks if font has small caps for a specific character
- When `typographic: true`: For each glyph, check if font supports it
  - If yes: Use font small caps (OpenType feature)
  - If no: Synthesize that character
- Result: Mixed rendering (font small caps + synthesized) for partial coverage

### 5. Character Tracking for `all: false`

When `all: false`, only originally lowercase letters should become small caps:
- **Problem**: After case transformation, we lose information about original case
- **Solution**: Track original lowercase positions before transformation
- **Implementation**: `HashSet<usize>` stores byte offsets of originally lowercase characters
- **Limitation**: Only works when case transformation happens in shaping phase (not pre-transformed in collect.rs)

## Processing Flow

```
User writes: #smallcaps(typographic: true)[Hello]

1. Show Rule:
   → Sets smallcaps_settings with typographic: true
   → Sets smallcaps to try OpenType features

2. Text Collection:
   → Text stays "Hello" (not transformed yet if all: false)

3. Text Shaping:
   → Check: font supports small caps?
     - If yes: Use OpenType features
     - If partial: Use font where available, synthesize missing
     - If no: Synthesize all
   → Transform case if synthesis needed (and not pre-transformed)
   → Track originally lowercase characters (for all: false)
   → For each glyph:
      - Check if font has small caps for this character
      - If yes and typographic: true: Use font feature
      - If no or typographic: false: Apply synthesis (scale, expansion)
      - When all: false: Only apply to originally lowercase characters

4. Rendering:
   → Glyphs rendered at appropriate size (font small caps or synthesized)
```

## Key Differences from Workarounds

| Workarounds | Native Implementation |
|------------|----------------------|
| Use `box()` + `scale()` | Direct glyph manipulation |
| Use `regex()` to find lowercase | Track original case during processing |
| Break text justification | Preserves justification (proper text grouping) |
| Manual tracking adjustments | Integrated with text layout system |
| Applied as post-processing | Integrated into text pipeline |
| All-or-nothing synthesis | Per-character synthesis (partial coverage) |

## Conditionals/Logic

1. **When to synthesize?**
   - `typographic: false` → always synthesize
   - `typographic: true` → only if font doesn't support or has partial coverage

2. **When to transform case?**
   - If `typographic: false` AND `all: true` → transform in collection phase
   - Otherwise → transform in shaping phase (to track original case)

3. **Which glyphs get synthesis?**
   - If `typographic: false` → all glyphs that need small caps
   - If `typographic: true` → only glyphs where font doesn't have small caps
   - If `all: false` → only glyphs from originally lowercase characters

4. **What transformations?**
   - **Size**: Uses `size` parameter (default: `0.75em`) - only for synthesized glyphs
   - **Expansion**: Uses `expansion` parameter (default: `1.05`) - only for synthesized glyphs
   - Applied during glyph creation, not as post-processing

## Implementation Details

### Font Feature Detection
- Checks GSUB table for `smcp` (lowercase) and `c2sc` (uppercase) features
- Per-character checking for partial coverage support
- Automatic fallback when features are missing

### Synthesis Parameters
- **Size**: `Smart<TextSize>` - converted to `Em` internally (default: `0.75em`)
- **Expansion**: `Smart<Ratio>` - horizontal width expansion (default: `1.05`)
- Both only apply to synthesized glyphs, not font-provided small caps

### Case Transformation Strategy
- **Early transformation** (collect.rs): Only when `typographic: false` AND `all: true`
- **Late transformation** (shaping.rs): When `typographic: true` or `all: false`
- **Rationale**: Need to track original case for selective synthesis when `all: false`

## Usage Examples

```typ
// Default: automatic fallback
#smallcaps[Hello World]

// Force synthesis
#smallcaps(typographic: false)[Hello World]

// Customize synthesized size
#smallcaps(typographic: false, size: 0.8em)[Hello]

// Customize expansion
#smallcaps(typographic: false, expansion: 1.1)[Hello]

// All letters small caps
#smallcaps(all: true)[Hello World]

// Global settings
#set smallcaps(typographic: false, size: 0.75em, expansion: 1.05)
#smallcaps[All text will be synthetic]
```

## Future Improvements

### 1. Pedantic Warnings (Pending)
- Add warnings when synthesis is used (requires engine access in shaping phase)
- Make warnings optional/pedantic (power users can enable)
- Currently: No way to know when synthesis happens

### 2. Better Partial Coverage
- Current: Per-character checking implemented
- Future: Could add visual indicators or warnings for mixed rendering

### 3. Additional Parameters
- `stroke`: Stroke weight adjustment (currently via `text(stroke: ...)`)
- `tracking`: Character spacing (currently via `text(tracking: ...)`)
- `baseline`: Vertical positioning adjustment

## Summary

The implementation:
- ✅ Follows sub/super script pattern (`typographic` parameter)
- ✅ Handles partial font coverage (per-character checking)
- ✅ Works automatically (fallback when font doesn't support)
- ✅ Allows customization (`size`, `expansion` parameters)
- ✅ Preserves text layout (no broken justification)
- ⚠️ Warnings not yet implemented (requires engine access)

The approach integrates synthesis directly into Typst's text pipeline, providing native support that works seamlessly with all text features (justification, line breaking, etc.), unlike workarounds that break layout.

