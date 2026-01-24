from pathlib import Path
from fontTools.ttLib import TTFont

# Remove existing .ttx files
FONTS_DIR = Path("assets/fonts")
for ttx_file in FONTS_DIR.rglob("*.ttx"):
    ttx_file.unlink()

# Process all .ttf files
for font_file in FONTS_DIR.rglob("*.ttf"):
    font = TTFont(font_file)

    # Check if font has fvar table (variable font)
    if 'fvar' in font:
        print(f"\n{font_file.name}:")

        # Extract axis information
        for axis in font['fvar'].axes:
            print(f"  {axis.axisTag}: {axis.minValue} - {axis.maxValue} (default: {axis.defaultValue})")
    else:
        print(f"{font_file.name}: Not a variable font")

    font.close()
