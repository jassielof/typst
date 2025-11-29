//! Variable font support.
//!
//! This module provides types and functions for working with OpenType variable fonts.
//! Variable fonts allow a single font file to contain multiple variations (weights,
//! widths, etc.) controlled by design-variation axes.

/// Information about a single variation axis in a variable font.
///
/// Each axis is identified by a 4-character tag (e.g., "wght" for weight) and
/// has a range of valid values with a default.
#[derive(Debug, Clone, PartialEq)]
pub struct VariationAxis {
    /// The 4-byte axis tag (e.g., b"wght", b"wdth").
    pub tag: [u8; 4],
    /// The minimum value for this axis.
    pub min_value: f32,
    /// The default value for this axis.
    pub default_value: f32,
    /// The maximum value for this axis.
    pub max_value: f32,
    /// The name ID for this axis (for UI display).
    pub name_id: u16,
}

impl VariationAxis {
    /// Create a new variation axis.
    pub fn new(
        tag: [u8; 4],
        min_value: f32,
        default_value: f32,
        max_value: f32,
        name_id: u16,
    ) -> Self {
        Self { tag, min_value, default_value, max_value, name_id }
    }

    /// Check if this is the weight axis ("wght").
    pub fn is_weight(&self) -> bool {
        &self.tag == b"wght"
    }

    /// Check if this is the width/stretch axis ("wdth").
    pub fn is_width(&self) -> bool {
        &self.tag == b"wdth"
    }

    /// Check if this is the slant axis ("slnt").
    pub fn is_slant(&self) -> bool {
        &self.tag == b"slnt"
    }

    /// Check if this is the italic axis ("ital").
    pub fn is_italic(&self) -> bool {
        &self.tag == b"ital"
    }

    /// Clamp a value to this axis's valid range.
    pub fn clamp(&self, value: f32) -> f32 {
        value.clamp(self.min_value, self.max_value)
    }

    /// Get the tag as a string for debugging.
    pub fn tag_str(&self) -> String {
        String::from_utf8_lossy(&self.tag).to_string()
    }
}

/// Information about a font's variable font capabilities.
///
/// This includes whether the font is variable and what axes it supports.
#[derive(Debug, Clone)]
pub struct VariationInfo {
    /// Whether this font is a variable font.
    is_variable: bool,
    /// The variation axes defined in the font.
    axes: Vec<VariationAxis>,
}

impl VariationInfo {
    /// Create variation info for a static (non-variable) font.
    pub fn new_static() -> Self {
        Self { is_variable: false, axes: Vec::new() }
    }

    /// Create variation info for a variable font with the given axes.
    pub fn new_variable(axes: Vec<VariationAxis>) -> Self {
        Self { is_variable: true, axes }
    }

    /// Extract variation information from a ttf-parser Face.
    pub fn from_ttf(face: &ttf_parser::Face) -> Self {
        // Check if the font has a fvar (font variations) table
        let Some(fvar) = face.tables().fvar else {
            return Self::new_static();
        };

        // Parse all variation axes from the fvar table
        let mut axes = Vec::new();
        for axis in fvar.axes {
            let tag_bytes = axis.tag.to_bytes();
            let tag = [tag_bytes[0], tag_bytes[1], tag_bytes[2], tag_bytes[3]];

            axes.push(VariationAxis::new(
                tag,
                axis.min_value,
                axis.def_value,
                axis.max_value,
                axis.name_id,
            ));
        }

        // If we found axes, this is a variable font
        if axes.is_empty() {
            Self::new_static()
        } else {
            Self::new_variable(axes)
        }
    }

    /// Check if this is a variable font.
    pub fn is_variable(&self) -> bool {
        self.is_variable
    }

    /// Get all axes defined in the font.
    pub fn axes(&self) -> &[VariationAxis] {
        &self.axes
    }

    /// Check if the font has the specified axis.
    pub fn has_axis(&self, tag: &[u8; 4]) -> bool {
        self.axes.iter().any(|axis| &axis.tag == tag)
    }

    /// Get the axis with the specified tag, if it exists.
    pub fn get_axis(&self, tag: &[u8; 4]) -> Option<&VariationAxis> {
        self.axes.iter().find(|axis| &axis.tag == tag)
    }

    /// Get the weight axis ("wght") if it exists.
    pub fn get_weight_axis(&self) -> Option<&VariationAxis> {
        self.get_axis(b"wght")
    }

    /// Get the width axis ("wdth") if it exists.
    pub fn get_width_axis(&self) -> Option<&VariationAxis> {
        self.get_axis(b"wdth")
    }

    /// Get the slant axis ("slnt") if it exists.
    pub fn get_slant_axis(&self) -> Option<&VariationAxis> {
        self.get_axis(b"slnt")
    }

    /// Get the italic axis ("ital") if it exists.
    pub fn get_italic_axis(&self) -> Option<&VariationAxis> {
        self.get_axis(b"ital")
    }
}

impl Default for VariationInfo {
    fn default() -> Self {
        Self::new_static()
    }
}

/// Variation coordinates for a specific font instance.
///
/// This specifies the values for each axis when rendering text.
/// For now, we only support the weight axis.
#[derive(Debug, Clone, Copy, PartialEq, Default)]
pub struct VariationCoordinates {
    /// The weight axis coordinate (wght).
    pub wght: Option<f32>,
    // Future: wdth, ital, slnt
}

impl Eq for VariationCoordinates {}

impl std::hash::Hash for VariationCoordinates {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        // Hash f32 by converting to bits (handles NaN consistently)
        if let Some(wght) = self.wght {
            wght.to_bits().hash(state);
        }
    }
}

impl VariationCoordinates {
    /// Create new empty coordinates.
    pub fn new() -> Self {
        Self::default()
    }

    /// Create coordinates with just the weight axis set.
    pub fn with_weight(wght: f32) -> Self {
        Self { wght: Some(wght) }
    }

    /// Check if any coordinates are set.
    pub fn is_empty(&self) -> bool {
        self.wght.is_none()
    }

    /// Check if this has any coordinates set.
    pub fn has_any(&self) -> bool {
        !self.is_empty()
    }

    /// Compute variation coordinates for a font based on a variant.
    ///
    /// This maps Typst's font variant (weight, stretch, style) to OpenType
    /// variation axis coordinates. For now, only weight is supported.
    ///
    /// Returns `None` if the font is not variable or has no supported axes.
    pub fn from_variant(
        variation_info: &VariationInfo,
        variant: super::FontVariant,
    ) -> Option<Self> {
        if !variation_info.is_variable() {
            return None;
        }

        let mut coords = Self::new();

        // Map weight to wght axis if available
        if let Some(wght_axis) = variation_info.get_weight_axis() {
            // Convert FontWeight (100-900) to f32 and clamp to axis range
            let weight_value = variant.weight.to_number() as f32;
            coords.wght = Some(wght_axis.clamp(weight_value));
        }

        // Future: Map stretch to wdth axis
        // Future: Map style to ital/slnt axis

        // Only return Some if we have at least one coordinate
        if coords.is_empty() {
            None
        } else {
            Some(coords)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_variation_axis_clamp() {
        let axis = VariationAxis::new(*b"wght", 100.0, 400.0, 900.0, 0);

        assert_eq!(axis.clamp(50.0), 100.0);
        assert_eq!(axis.clamp(400.0), 400.0);
        assert_eq!(axis.clamp(1000.0), 900.0);
    }

    #[test]
    fn test_variation_axis_checks() {
        let wght = VariationAxis::new(*b"wght", 100.0, 400.0, 900.0, 0);
        let wdth = VariationAxis::new(*b"wdth", 75.0, 100.0, 125.0, 0);

        assert!(wght.is_weight());
        assert!(!wght.is_width());

        assert!(wdth.is_width());
        assert!(!wdth.is_weight());
    }

    #[test]
    fn test_variation_info_static() {
        let info = VariationInfo::new_static();

        assert!(!info.is_variable());
        assert!(info.axes().is_empty());
        assert!(info.get_weight_axis().is_none());
    }

    #[test]
    fn test_variation_info_variable() {
        let axes = vec![
            VariationAxis::new(*b"wght", 100.0, 400.0, 900.0, 0),
            VariationAxis::new(*b"wdth", 75.0, 100.0, 125.0, 0),
        ];

        let info = VariationInfo::new_variable(axes);

        assert!(info.is_variable());
        assert_eq!(info.axes().len(), 2);
        assert!(info.has_axis(b"wght"));
        assert!(info.has_axis(b"wdth"));
        assert!(!info.has_axis(b"slnt"));

        let wght = info.get_weight_axis().unwrap();
        assert_eq!(wght.min_value, 100.0);
        assert_eq!(wght.default_value, 400.0);
        assert_eq!(wght.max_value, 900.0);
    }

    #[test]
    fn test_variation_coordinates() {
        let coords = VariationCoordinates::new();
        assert!(coords.is_empty());

        let coords = VariationCoordinates::with_weight(700.0);
        assert!(!coords.is_empty());
        assert_eq!(coords.wght, Some(700.0));
    }

    #[test]
    fn test_variation_coordinates_from_variant() {
        use super::super::{FontWeight, FontVariant};

        // Test with static font - should return None
        let static_info = VariationInfo::new_static();
        let variant = FontVariant::new(
            super::super::FontStyle::Normal,
            FontWeight::BOLD,
            super::super::FontStretch::NORMAL,
        );

        assert!(VariationCoordinates::from_variant(&static_info, variant).is_none());

        // Test with variable font
        let axes = vec![VariationAxis::new(*b"wght", 100.0, 400.0, 900.0, 0)];
        let var_info = VariationInfo::new_variable(axes);

        // Test bold weight
        let variant = FontVariant::new(
            super::super::FontStyle::Normal,
            FontWeight::BOLD,
            super::super::FontStretch::NORMAL,
        );
        let coords = VariationCoordinates::from_variant(&var_info, variant).unwrap();
        assert_eq!(coords.wght, Some(700.0));

        // Test weight clamping - weight 950 should clamp to 900
        let variant = FontVariant::new(
            super::super::FontStyle::Normal,
            FontWeight::from_number(950),
            super::super::FontStretch::NORMAL,
        );
        let coords = VariationCoordinates::from_variant(&var_info, variant).unwrap();
        assert_eq!(coords.wght, Some(900.0));

        // Test weight clamping - weight 50 should clamp to 100
        let variant = FontVariant::new(
            super::super::FontStyle::Normal,
            FontWeight::from_number(50),
            super::super::FontStretch::NORMAL,
        );
        let coords = VariationCoordinates::from_variant(&var_info, variant).unwrap();
        assert_eq!(coords.wght, Some(100.0));
    }
}
