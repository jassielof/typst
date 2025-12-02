# Fake Small Caps Implementation Analysis

## Executive Summary

This document analyzes the best approach for implementing fake (synthetic) small caps in Typst, considering API design consistency, implementation complexity, and future extensibility for related features (fake bold, fake italics).

## Current State

### Existing Implementation Patterns

1. **`smallcaps()`**: Currently only supports OpenType features (`smcp`, `c2sc`). Sets `TextElem::smallcaps` field.
2. **`strong()`**: Sets `TextElem::delta` (weight delta) - applies relative weight change.
3. **`emph()`**: Sets `TextElem::emph` (italic toggle) - toggles italic style.
4. **`sub()`/`super()`**: **Key pattern** - Has `typographic: bool` option:
   - `typographic: true` (default): Try font features first, fall back to synthesis
   - `typographic: false`: Force synthesis (fake effect)

### Text Processing Pipeline

1. **Collection** (`collect.rs`): Text elements are collected, case transformations applied
2. **Shaping** (`shaping.rs`): Font features applied, glyphs shaped
3. **Layout**: Glyphs positioned, tracking/spacing applied
4. **Rendering**: Final output to PDF/SVG/HTML

## API Design Analysis

### Option 1: Add Option to `smallcaps()` (RECOMMENDED)

**Proposal:**
```typ
#smallcaps(synthetic: false)[Text]  // Default: use OpenType features
#smallcaps(synthetic: true)[Text]   // Force fake small caps
#set smallcaps(synthetic: true)      // Global setting
```

**Advantages:**
- ✅ **Consistent with `sub`/`super` pattern** - Uses `typographic`/`synthetic` boolean
- ✅ **Single function** - No API bloat, intuitive
- ✅ **Backward compatible** - Default `false` preserves current behavior
- ✅ **Show rules work naturally** - `#show smallcaps: set text(...)` still works
- ✅ **Future-proof** - Can extend with parameters later:
  ```typ
  #smallcaps(
    synthetic: true,
    scale: 0.75,
    stroke: 0.01em,
    tracking: 1.1em
  )
  ```

**Disadvantages:**
- ⚠️ Requires modifying existing function signature
- ⚠️ Need to handle fallback logic (font features → synthesis)

### Option 2: New `fakesc()` Element

**Proposal:**
```typ
#fakesc[Text]
#smallcaps[Text]  // Still uses OpenType features
```

**Advantages:**
- ✅ Clear separation of concerns
- ✅ No changes to existing `smallcaps()`

**Disadvantages:**
- ❌ **API inconsistency** - Different from `sub`/`super` pattern
- ❌ **Confusing for users** - Two ways to do similar things
- ❌ **Future issues** - Would need `fakebold()`, `fakeitalic()` too
- ❌ **Show rules complexity** - Users need to know which to use
- ❌ **Not extensible** - Can't easily add parameters to `smallcaps()` later

## Recommendation: Option 1 with `synthetic` Parameter

Following the established pattern from `sub`/`super`, we should add a `synthetic` parameter to `smallcaps()`:

```rust
pub struct SmallcapsElem {
    /// Whether to use OpenType features or synthesize small caps.
    ///
    /// When `false` (default), Typst uses the `smcp` and `c2sc` OpenType
    /// features if available. When `true`, small caps are synthesized by
    /// scaling and transforming uppercase letters, regardless of font support.
    #[default(false)]
    pub synthetic: bool,

    /// Whether to turn uppercase letters into small capitals as well.
    #[default(false)]
    pub all: bool,

    /// The content to display in small capitals.
    #[required]
    pub body: Content,
}
```

### Implementation Strategy

1. **Fallback Logic** (when `synthetic: false`):
   - Try OpenType features first
   - If font doesn't support, automatically fall back to synthesis
   - This matches `sub`/`super` behavior with `typographic: true`

2. **Synthesis Parameters** (when `synthetic: true` or fallback):
   - Apply during text shaping/layout phase
   - Transform text: uppercase → scale → adjust stroke → adjust tracking

## Technical Implementation Details

### Synthesis Parameters

Based on analysis of workarounds and typographic best practices:

#### Default Values (Recommended)

```rust
pub struct SyntheticSmallcaps {
    /// Scale factor for height (relative to base size)
    /// Range: 0.6-0.8, default: 0.75
    pub scale: Ratio,

    /// Stroke weight increase (to compensate for thinner appearance)
    /// Default: 0.01em (relative to font size)
    pub stroke: Length,

    /// Horizontal expansion factor (glyph width)
    /// Range: 1.0-1.1, default: 1.05
    pub expansion: Ratio,

    /// Character spacing (tracking)
    /// Should match expansion for consistency
    /// Default: 1.1em (relative to base tracking)
    pub tracking: Length,

    /// Vertical baseline adjustment
    /// Default: 0 (no adjustment, or small positive value)
    pub baseline_shift: Length,
}
```

#### Rationale

1. **Scale (0.75)**:
   - True small caps are typically 70-80% of cap height
   - 0.75 is a good middle ground, matches most workarounds

2. **Stroke (0.01em)**:
   - Compensates for thinner appearance when scaled down
   - Relative to font size ensures consistency across sizes
   - Can be increased for sans-serif fonts (0.015-0.02em)

3. **Expansion (1.05)**:
   - Makes glyphs slightly wider to match true small caps proportions
   - Works with tracking to maintain visual consistency

4. **Tracking (1.1em)**:
   - Slightly increased letter spacing
   - Should be proportional to expansion
   - Prevents cramped appearance

5. **Baseline Shift (0)**:
   - Usually not needed, but can be fine-tuned per font
   - Optional parameter for advanced users

### Implementation Location

Synthesis should happen in the **text shaping phase** (`shaping.rs`), similar to how `sub`/`super` handle synthesis:

1. **Check if synthesis needed**:
   - `synthetic: true` → always synthesize
   - `synthetic: false` → check if font supports `smcp`/`c2sc`, fallback if not

2. **Apply transformations**:
   - Convert lowercase to uppercase (if `all: false`, only lowercase)
   - Scale text size
   - Adjust stroke weight
   - Apply horizontal expansion (glyph width)
   - Adjust tracking (character spacing)
   - Apply baseline shift if needed

3. **Text collection**:
   - Case transformation can happen in `collect.rs` (like current `Case` handling)
   - Size/stroke/tracking adjustments in shaping phase

### Show Rules Integration

Users should be able to customize synthesis parameters via show rules:

```typ
// Global defaults
#set smallcaps(
  synthetic: true,
  scale: 0.75,
  stroke: 0.01em,
  expansion: 1.05,
  tracking: 1.1em
)

// Per-instance override
#smallcaps(synthetic: true, scale: 0.8)[Text]

// Show rule customization
#show smallcaps.where(synthetic: true): set text(
  size: 0.75em,
  stroke: 0.015em,
  tracking: 1.15em
)
```

**Note**: The show rule approach has limitations - `scale` and `expansion` can't be easily applied via `text()` parameters. These would need to be handled in the synthesis logic itself.

## Consistency with Future Features

### Fake Bold/Weight

Following the same pattern:
```typ
#strong(synthetic: false)  // Use font weight (default)
#strong(synthetic: true)   // Synthesize with stroke/overlay
```

### Fake Italics/Oblique

```typ
#emph(synthetic: false)  // Use font style (default)
#emph(synthetic: true)   // Synthesize with skew transform
```

**Key Insight**: All three features (`smallcaps`, `strong`, `emph`) would follow the same `synthetic: bool` pattern, maintaining API consistency.

## Comparison with Workarounds

### Issues with Current Workarounds

1. **Cuti package**: Uses regex, breaks text grouping → tracking issues
2. **Terefang's solution**: Uses box scaling → breaks justification
3. **User's workaround**: Better, but still has tracking issues with mixed case

### Native Implementation Advantages

- ✅ Proper text grouping maintained
- ✅ Justification works correctly
- ✅ Consistent with Typst's text processing pipeline
- ✅ Can be optimized in layout engine
- ✅ Works with all text features (ligatures, kerning, etc.)

## Default Behavior Recommendations

### Opt-in vs Opt-out

**Recommendation: Opt-in (`synthetic: false` by default)**

**Rationale:**
1. **Backward compatibility** - Current behavior preserved
2. **Quality first** - True small caps (when available) are always better
3. **User control** - Explicit choice to use synthesis
4. **Matches `sub`/`super`** - `typographic: true` is default there too

### Automatic Fallback

When `synthetic: false` but font doesn't support small caps:
- **Option A**: Automatically fall back to synthesis (silent)
- **Option B**: Warn user, require explicit `synthetic: true`

**Recommendation: Option A (automatic fallback)**

This matches `sub`/`super` behavior - they try typographic first, synthesize if needed. Users can still force synthesis with `synthetic: true`.

## HTML Export Considerations

CSS has `font-variant: small-caps` which browsers synthesize. For HTML export:
- When `synthetic: false`: Use CSS `font-variant: small-caps`
- When `synthetic: true`: Apply inline styles with transforms (similar to PDF)

## Conclusion

**Recommended Approach:**
1. Add `synthetic: bool` parameter to `smallcaps()` (default: `false`)
2. Implement synthesis in text shaping phase
3. Provide sensible defaults for synthesis parameters
4. Allow customization via show rules (where applicable)
5. Follow same pattern for future `strong(synthetic:)` and `emph(synthetic:)`

This approach:
- ✅ Maintains API consistency
- ✅ Preserves backward compatibility
- ✅ Provides user control
- ✅ Sets precedent for related features
- ✅ Integrates cleanly with existing text pipeline
