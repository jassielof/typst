// Favicon of the website: a "t" in Reforma 1969. Regenerate with
//   typst compile --format svg --font-path "<Reforma 1969 folder>" \
//     docs/i18n/es-AR/brand/favicon.typ docs/i18n/es-AR/favicon.svg
#set page(width: 64pt, height: 64pt, margin: 0pt, fill: none)
#set text(font: "Reforma 1969", weight: "bold", fill: white)
#place(rect(width: 64pt, height: 64pt, radius: 14pt, fill: rgb("#239dad")))
#place(center + horizon, dy: -1pt, text(size: 54pt, top-edge: "x-height", bottom-edge: "baseline")[t])
