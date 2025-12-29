#set page(height: auto)

// Define the target font and sample text
#let font-family = "Noto Sans"
#let sample-text = "The quick brown fox jumps over the lazy dog."

// --- Exhaustive Test Function ---
#context [
  = Exhaustive Weight Test: #font-family

  // Set smallcaps to use the correct font
  #show smallcaps: set text(font: font-family)

  #let rows = ()

  // Loop from 100 to 900 (range excludes the end, so 901)
  #for w in range(100, 901, step: 1) {
    // 1. Weight Label
    rows.push(align(center + horizon)[*#w*])

    // 2. Normal Style
    rows.push(
      text(font: font-family, weight: w, style: "normal")[
        #sample-text
      ],
    )

    // 3. Italic Style
    rows.push(
      text(font: font-family, weight: w, style: "italic")[
        #sample-text
      ],
    )
  }

  // Display the massive table
  #table(
    columns: (auto, 1fr, 1fr),
    inset: (x: 5pt, y: 3pt),
    // Tighter inset for density
    align: (x, y) => if x == 0 { center + horizon } else { left + horizon },
    stroke: (x, y) => if y == 0 { (bottom: 1pt + black) } else { (bottom: 0.5pt + gray.lighten(50%)) },

    // Header
    table.header([*Weight*], [*Normal*], [*Italic*]),

    // Unpack all 801 rows
    ..rows,
  )
]
