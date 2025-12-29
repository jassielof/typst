# Synthetic Small Caps Implementation Review

## Overview

This document reviews the current synthetic small caps implementation, identifies issues, and provides recommendations for improvements.

## ✅ What's Working Well

1. **API Design**: Correctly uses `typographic` parameter (matching sub/super pattern)
2. **Font Feature Detection**: Has `check_smallcaps_support()` and `font_has_smallcap_for_char()` functions
3. **Partial Coverage Handling**: Attempts to handle fonts with partial small caps support
4. **Integration**: Properly integrated into text pipeline (collect → shaping → layout)

## 🐛 Critical Issues (FIXED)

### Issue 1: Cluster Offset Mapping Bug ✅ FIXED

**Location**: `shaping.rs:1220` (now fixed)

**Problem**:
```rust
original_lowercase.contains(&cluster)
```

The `cluster` is a byte offset in `text_to_shape` (potentially transformed text), but `original_lowercase` contains byte offsets from the original `text`. While ASCII case transformation preserves byte offsets, this is fragile and could break with:
- Multi-byte characters
- Complex Unicode transformations
- When case is pre-transformed in `collect.rs`

**Impact**: When `all: false`, synthesis might not be applied correctly to originally lowercase letters.

**Fix Applied**: Now maps cluster offsets back to original text offsets by calculating character index and then finding the corresponding byte offset in the original text.

### Issue 2: Missing Original Case Tracking When Pre-Transformed ✅ FIXED

**Location**: `collect.rs:168-172` and `shaping.rs:1015-1040` (now fixed)

**Problem**: When `typographic: false && all: true`, case was transformed in `collect.rs`, but then in `shaping.rs` we couldn't determine which characters were originally lowercase.

**Impact**: When `typographic: false && all: true`, the `all: false` behavior (only lowercase → small caps) wouldn't work correctly.

**Fix Applied**: Removed pre-transformation from `collect.rs`. Case transformation now always happens in `shaping.rs`, ensuring we can always track original case. This simplifies the code and eliminates the offset mapping issue.

### Issue 3: Warning System Uses Static HashSet ✅ FIXED

**Location**: `shaping.rs:988-1009` (now fixed)

**Problem**: Used a static `OnceLock<Mutex<HashSet>>` to track warned segments, which had thread-safety and deduplication issues.

**Impact**: Warnings might not appear when they should, or might appear when they shouldn't.

**Fix Applied**: Removed static HashSet. Now uses `ctx.sink.warn()` directly, letting Typst's engine handle warning deduplication properly.

### Issue 4: Font Feature Check Uses Transformed Character ✅ FIXED

**Location**: `shaping.rs:1209` (now fixed)

**Problem**:
```rust
font_has_smallcap_for_char(&font, c, all_smallcaps)
```

The character `c` was from `text_to_shape[cluster..]`, which may already be uppercase. Should check against the original character (before transformation) for lowercase letters.

**Impact**: When checking font support for lowercase letters that have been transformed to uppercase, we were checking the wrong character.

**Fix Applied**: Now extracts both `c_shaped` (from transformed text) and `c_original` (from original text). Font feature checking uses `c_original`, ensuring correct detection of font support.

## ⚠️ Potential Issues

### Issue 5: Range Mapping for Transformed Text

**Location**: `shaping.rs:1172-1195`

**Problem**: The code assumes 1:1 byte mapping between `text` and `text_to_shape`:
```rust
// Cluster is in the transformed text, but we need to map it back
// For now, use the cluster directly (they should align if transformation is 1:1)
```

This works for ASCII case transformation, but could break with:
- Multi-byte UTF-8 characters
- Characters that expand/contract during transformation
- Future transformations that change byte length

**Impact**: Glyph ranges might be incorrect, affecting text selection, accessibility, and PDF metadata.

**Fix**: Implement proper offset mapping between original and transformed text.

### Issue 6: Case Transformation Doesn't Handle Unicode Properly

**Location**: `shaping.rs:1042-1057`

**Problem**: Uses `to_uppercase()` which works for ASCII but may not handle all Unicode cases correctly (e.g., Turkish dotted/dotless I, German ß → SS).

**Impact**: Some languages might have incorrect case transformations.

**Fix**: Consider using Unicode-aware case transformation, or document limitations.

### Issue 7: Missing Validation for `all: false` with Pre-Transformed Text

**Location**: `shaping.rs:1218-1220`

**Problem**: When `case_already_transformed` is true and `all: false`, the code tries to use `original_lowercase` which is empty. This should be detected and handled explicitly.

**Impact**: Silent failure - synthesis won't be applied when it should be.

**Fix**: Add explicit check and either error or handle gracefully.

## 📋 Recommendations

### High Priority

1. **Fix cluster offset mapping**: Map cluster offsets from transformed text back to original text before checking `original_lowercase`.

2. **Simplify case transformation**: Always transform in `shaping.rs`, remove pre-transformation from `collect.rs`. This eliminates the offset mapping issue and makes the code simpler.

3. **Fix warning system**: Use `ctx.sink.warn()` directly instead of static HashSet. Let Typst handle warning deduplication.

4. **Fix font feature checking**: Check font support using original character, not transformed character.

### Medium Priority

5. **Improve range mapping**: Implement proper offset mapping for cases where transformation changes byte length.

6. **Add explicit error handling**: Detect and handle cases where `all: false` is used with pre-transformed text.

### Low Priority

7. **Unicode case handling**: Document or improve Unicode case transformation support.

8. **Add tests**: Create comprehensive tests for:
   - Mixed case text with `all: false`
   - Partial font coverage
   - Pre-transformed vs late-transformed cases
   - Unicode characters
   - Multi-byte UTF-8 sequences

## 🔍 Code Review Checklist

- [ ] Cluster offsets correctly mapped between original and transformed text
- [ ] Original case tracking works in all scenarios
- [ ] Warnings use proper engine sink
- [ ] Font feature detection uses correct characters
- [ ] Range mapping handles byte length changes
- [ ] Edge cases tested (Unicode, partial coverage, mixed case)
- [ ] Documentation updated with limitations

## 📝 Implementation Notes

### Suggested Refactoring

1. **Remove pre-transformation from `collect.rs`**:
   - Always transform in `shaping.rs`
   - Simplifies logic and eliminates offset mapping issues

2. **Create helper function for cluster mapping**:
   ```rust
   fn map_cluster_to_original(
       cluster: usize,
       text: &str,
       text_to_shape: &str,
   ) -> usize {
       // Map cluster offset from transformed text to original text
   }
   ```

3. **Improve original case tracking**:
   - Store as `HashSet<usize>` of byte offsets in original text
   - Always create from original `text`, never from transformed text
   - Map cluster offsets before checking

4. **Simplify synthesis logic**:
   - Single code path for case transformation
   - Clear separation between font feature usage and synthesis
   - Better comments explaining when each path is taken

## 🎯 Alignment with Team Feedback

Based on the team's comments:

1. ✅ **Laurenz**: Font feature detection implemented (needs fixes)
2. ⚠️ **Saffronner**: Warnings should be pedantic/optional (needs proper implementation)
3. ⚠️ **Malo**: Need way to know when synthesis is used (warnings need fixing)
4. ✅ **API**: Uses `typographic` matching sub/super pattern

## Next Steps

1. Fix critical issues (1-4)
2. Test with various fonts and text scenarios
3. Add comprehensive test suite
4. Update documentation
5. Consider pedantic warning system for power users

