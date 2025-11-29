//! Variable font instancing.
//!
//! This module provides functionality to instance (convert) variable fonts
//! to static fonts by baking in specific variation coordinates.

use allsorts::binary::read::ReadScope;
use allsorts::font_data::FontData;
use allsorts::tables::Fixed;
use allsorts::variations::instance as allsorts_instance;
use typst_library::text::VariationCoordinates;

/// Instance a variable font to a static font with specific variation coordinates.
///
/// This function takes a variable font and variation coordinates, and produces
/// a new static font with the variations baked in. This is necessary because
/// krilla (the PDF library) doesn't support variable fonts directly.
///
/// The function uses the allsorts library to perform the instancing operation.
///
/// # Arguments
///
/// * `font_data` - The raw bytes of the variable font
/// * `coords` - The variation coordinates to apply
/// * `variation_info` - The font's variation information (for getting axis defaults)
///
/// # Returns
///
/// Returns the instanced static font data as a `Vec<u8>`, or an error string
/// if instancing fails.
pub fn instance_variable_font(
    font_data: &[u8],
    coords: &VariationCoordinates,
    variation_info: &typst_library::text::VariationInfo,
) -> Result<Vec<u8>, String> {
    // Parse the font with allsorts
    let scope = ReadScope::new(font_data);
    let font_file = scope
        .read::<FontData<'_>>()
        .map_err(|e| format!("Failed to parse font: {:?}", e))?;

    // Get the first font from the file (handle collections)
    let provider = font_file
        .table_provider(0)
        .map_err(|e| format!("Failed to get table provider: {:?}", e))?;

    // Build allsorts variation instance from our coordinates
    // The instance function expects a slice of Fixed values for ALL axes
    // in the exact order they appear in the fvar table
    // variation_info.axes() is already in fvar table order, so we use that
    let mut user_instance = Vec::new();

    for axis in variation_info.axes() {
        let value = if axis.tag == *b"wght" {
            // Use our weight coordinate if provided, otherwise use default
            coords.wght.map(|w| Fixed::from(w as f32))
                .unwrap_or_else(|| Fixed::from(axis.default_value))
        } else {
            // For other axes, use the default value
            Fixed::from(axis.default_value)
        };

        user_instance.push(value);
    }

    // If no weight coordinate to apply, return original font data
    if coords.wght.is_none() || user_instance.is_empty() {
        return Ok(font_data.to_vec());
    }

    // Perform the instancing
    // The function returns (font_data, tuple), we only need the font_data
    let (instanced, _) = allsorts_instance(&provider, &user_instance)
        .map_err(|e| format!("Failed to instance font: {:?}", e))?;

    Ok(instanced)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_instance_non_variable_font() {
        // This test would require actual font data
        // For now, just verify the function signature is correct
        let empty_data = vec![];
        let coords = VariationCoordinates::with_weight(700.0);
        let var_info = typst_library::text::VariationInfo::new_static();

        // This will fail but that's expected for empty data
        assert!(instance_variable_font(&empty_data, &coords, &var_info).is_err());
    }
}
