// #let the-font = "Google Sans Flex" // ranges from 6 to 144
#let the-font = "Source Serif 4 Variable" // It's easier to notice a difference in optical size with serif fonts, ranges from 8 to 60
// For better visual testing, it's recommended to use have 2 PDF viewers open side by side, both with same output, one zommed in into the first page, and the other zoomed out to the last page.
#set text(
  font: the-font,
  fallback: false,
)


#for opt-size in range(8, 60, step: 1) {
  set align(center + horizon)
  set page(flipped: true, width: auto, height: auto)
  text(size: opt-size * 1pt, style: "italic")[Handgloves]
  pagebreak(weak: true)
}
