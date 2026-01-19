#set page(height: auto)
#set text(size: 15pt)
// --- Content Definitions (Short samples for table cells) ---
// Latin (English & Spanish mix for coverage)
#let text_latin = "The quick brown fox jumps. El veloz murciélago."

// Japanese (Natsume Sōseki snippet)
#let text_jp = "吾輩は猫である。名前はまだ無い。"

// Korean (Universal Declaration of Human Rights snippet)
#let text_kr = "모든 인간은 태어날 때부터 자유로우며"

// Simplified Chinese
#let text_sc = "人人生而自由，在尊严和权利上一律平等。"

// Traditional Chinese
#let text_tc = "人人生而自由，在尊嚴和權利上一律平等。"


// --- Testing Function ---
#let test-font(font-family, sample-text) = context [
  // Start a new page for each font to keep it clean
  #pagebreak(weak: true)

  // Level 1 Heading (Hierarchically correct)
  = #font-family

  // Ensure the font is applied to smallcaps explicitly
  #show smallcaps: set text(font: font-family)

  #let weights = ()

  // Iterate weights 100 to 900
  #for weight in range(100, 1000, step: 100) {
    weights.push(align(center + horizon)[#weight])

    for style in ("normal", "italic") {
      weights.push(
        text(font: font-family, weight: weight, style: style)[
          // Standard text
          #box(sample-text, fill: luma(240), inset: 4pt, radius: 2pt)
          #v(0.5em)
          // Smallcaps text (Note: CJK fonts often lack true smallcaps, but this tests fallback)
          #box(smallcaps(sample-text), fill: luma(220), inset: 4pt, radius: 2pt)
        ],
      )
    }
  }

  // Display the grid
  #table(
    columns: (auto, 1fr, 1fr),
    inset: 10pt,
    align: (x, y) => if x == 0 { center + horizon } else { left + top },
    table.header([*Weight*], [*Normal*], [*Italic*]),
    ..weights,
  )
]


// --- Font Test Calls ---

// 1. Buenard (Latin)
#test-font("Buenard", text_latin)

// 2. Google Sans Flex (Latin)
#test-font("Google Sans Flex", text_latin)

// 3. Google Sans Code (Latin Monospace)
#test-font("Google Sans Code", text_latin)

// 4. Inter (Latin)
#test-font("Inter", text_latin)

// 5. Noto Sans (Latin)
#test-font("Noto Sans", text_latin)

// 6. Noto Sans JP (Japanese)
#test-font("Noto Sans JP", text_jp)

// 7. Noto Sans KR (Korean)
#test-font("Noto Sans KR", text_kr)

// 8. Noto Sans SC (Simplified Chinese)
#test-font("Noto Sans SC", text_sc)

// 9. Noto Sans TC (Traditional Chinese)
#test-font("Noto Sans TC", text_tc)

// 10. Noto Serif (Latin)
#test-font("Noto Serif", text_latin)

// 11. Noto Serif JP (Japanese)
#test-font("Noto Serif JP", text_jp)
