# Synthetic Small Caps - Fixes Applied

## Summary

This document summarizes the fixes applied to the synthetic small caps implementation based on the code review.

## Changes Made

### 1. Removed Pre-Transformation from `collect.rs` ✅

**File**: `crates/typst-layout/src/inline/collect.rs`

**Change**: Removed the early case transformation that happened when `typographic: false && all: true`. Case transformation now always happens in `shaping.rs`.

**Rationale**:
- Simplifies the code by having a single transformation point
- Ensures we can always track original case for `all: false` behavior
- Eliminates offset mapping issues between collection and shaping phases

**Before**:
```rust
if let Some(sc_settings) = styles.get(TextElem::smallcaps_settings) {
    if !sc_settings.typographic && sc_settings.all {
        // Transform to uppercase for forced synthesis when all: true
        let transformed: EcoString = elem.text.to_uppercase().into();
        full.push_str(&transformed);
    } else if let Some(case) = styles.get(TextElem::case) {
        // ...
    }
}
```

**After**:
```rust
if let Some(sc_settings) = styles.get(TextElem::smallcaps_settings) {
    // Don't pre-transform here - let shaping.rs handle it
    // This allows proper tracking of original lowercase characters
    if let Some(case) = styles.get(TextElem::case) {
        // ...
    }
}
```

### 2. Fixed Warning System ✅

**File**: `crates/typst-layout/src/inline/shaping.rs`

**Change**: Removed static `OnceLock<Mutex<HashSet>>` and now uses Typst's engine sink directly.

**Rationale**:
- Properly integrates with Typst's warning system
- Lets the engine handle deduplication
- Thread-safe and per-document aware

**Before**:
```rust
use std::sync::{Mutex, OnceLock};
use std::collections::HashSet;
static WARNED: OnceLock<Mutex<HashSet<(usize, usize)>>> = OnceLock::new();

if needs_synthesis {
    if let Some(reason) = synthesis_reason {
        let key = (base, text.len());
        let warned = WARNED.get_or_init(|| Mutex::new(HashSet::new()));
        let mut warned = warned.lock().unwrap();
        if warned.insert(key) {
            ctx.sink.warn(warning!(...));
        }
    }
}
```

**After**:
```rust
// Note: Typst's engine will handle warning deduplication automatically
if needs_synthesis {
    if let Some(reason) = synthesis_reason {
        let span = Span::detached();
        ctx.sink.warn(warning!(...));
    }
}
```

### 3. Fixed Cluster Offset Mapping ✅

**File**: `crates/typst-layout/src/inline/shaping.rs`

**Change**: Properly maps cluster offsets from transformed text back to original text before checking `original_lowercase`.

**Rationale**:
- Ensures correct synthesis application when `all: false`
- Handles cases where byte offsets might differ
- More robust for multi-byte characters

**Before**:
```rust
let should_apply_synthesis = if needs_synthesis {
    // ...
    } else {
        // Only originally lowercase letters get synthesis
        original_lowercase.contains(&cluster) // BUG: cluster is from transformed text
    }
};
```

**After**:
```rust
// Calculate original byte offset for checking original_lowercase
let char_index = text_to_shape[..cluster].chars().count();
let original_byte_offset = text.char_indices()
    .nth(char_index)
    .map(|(i, _)| i)
    .unwrap_or(cluster);

let should_apply_synthesis = if needs_synthesis {
    // ...
    } else {
        // Only originally lowercase letters get synthesis
        original_lowercase.contains(&original_byte_offset) // FIXED: uses original offset
    }
};
```

### 4. Fixed Font Feature Character Checking ✅

**File**: `crates/typst-layout/src/inline/shaping.rs`

**Change**: Extracts both original and transformed characters, uses original for font feature checking.

**Rationale**:
- Font feature detection should check the original character (before case transformation)
- Ensures correct detection of font support for lowercase letters

**Before**:
```rust
let c = text_to_shape[cluster..].chars().next().unwrap();
// ...
let use_font_feature = ctx.smallcaps_settings
    .map_or(false, |s| s.typographic)
    && font_has_smallcap_for_char(&font, c, all_smallcaps); // BUG: c is from transformed text
```

**After**:
```rust
// Get character from transformed text (used for shaping)
let c_shaped = text_to_shape[cluster..].chars().next().unwrap();
// Get original character from original text for font feature checking
let char_index = text_to_shape[..cluster].chars().count();
let c_original = text.chars().nth(char_index).unwrap_or(c_shaped);
// ...
let use_font_feature = ctx.smallcaps_settings
    .map_or(false, |s| s.typographic)
    && font_has_smallcap_for_char(&font, c_original, all_smallcaps); // FIXED: uses original
```

### 5. Simplified Case Transformation Logic ✅

**File**: `crates/typst-layout/src/inline/shaping.rs`

**Change**: Removed `case_already_transformed` check and simplified the logic.

**Rationale**:
- Since we no longer pre-transform in `collect.rs`, we don't need this check
- Simplifies the code path
- Always transforms in shaping phase, ensuring consistency

**Before**:
```rust
let case_already_transformed = ctx.smallcaps_settings
    .map_or(false, |s| !s.typographic && s.all);

let needs_case_transform = needs_synthesis && !case_already_transformed;

let original_lowercase: HashSet<usize> = if !all_smallcaps && needs_synthesis && !case_already_transformed {
    // ...
} else {
    HashSet::new()
};
```

**After**:
```rust
// Case transformation always happens here (not in collect.rs) to maintain
// proper tracking of original case for selective synthesis (all: false)
let needs_case_transform = needs_synthesis;

let original_lowercase: HashSet<usize> = if !all_smallcaps && needs_synthesis {
    // Track originally lowercase characters by their byte offsets in original text
    text.char_indices()
        .filter(|(_, c)| c.is_lowercase())
        .map(|(i, _)| i)
        .collect()
} else {
    HashSet::new()
};
```

## Testing Recommendations

After these fixes, the following scenarios should be tested:

1. **Basic functionality**:
   - `#smallcaps[Hello]` with font that has small caps
   - `#smallcaps[Hello]` with font that doesn't have small caps
   - `#smallcaps(typographic: false)[Hello]` (forced synthesis)

2. **Partial coverage**:
   - Font with small caps for some letters but not others
   - Mixed case text: `#smallcaps[Hello World]`
   - `#smallcaps(all: false)[Hello World]` (only lowercase should be small caps)

3. **Edge cases**:
   - Unicode characters (multi-byte)
   - Mixed scripts (Latin + CJK)
   - Text with numbers and punctuation

4. **Warning system**:
   - Verify warnings appear when synthesis is used
   - Verify warnings don't spam (engine deduplication works)

## Remaining Considerations

### Medium Priority

1. **Range mapping for transformed text**: Currently assumes 1:1 byte mapping. Should be verified/tested with multi-byte UTF-8 sequences.

2. **Unicode case handling**: Uses Rust's standard `to_uppercase()` which handles most cases, but may have edge cases for specific languages (Turkish, German).

### Low Priority

3. **Performance**: The character index calculation could be optimized if it becomes a bottleneck, but for typical text lengths it should be fine.

4. **Documentation**: Consider adding examples showing the difference between `typographic: true` and `typographic: false`.

## Verification Checklist

- [x] Removed pre-transformation from `collect.rs`
- [x] Fixed warning system to use engine sink
- [x] Fixed cluster offset mapping
- [x] Fixed font feature character checking
- [x] Simplified case transformation logic
- [x] No linter errors
- [ ] Manual testing with various fonts
- [ ] Manual testing with edge cases
- [ ] Verify warnings work correctly

## Next Steps

1. Run manual tests with the fixes
2. Test with various fonts (with/without small caps, partial coverage)
3. Test edge cases (Unicode, mixed scripts)
4. Verify warning behavior
5. Consider adding unit tests for the fixed logic

