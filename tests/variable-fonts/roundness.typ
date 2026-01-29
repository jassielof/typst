#let the-font = "Google Sans Flex"
#set text(
  font: the-font,
  fallback: false,
)
#show raw: set text(
  font: the-font,
  fallback: false,
)

#text(axes: (ROND: 1), size: 100pt, lorem(1))
#text(axes: (ROND: 100), size: 100pt, lorem(1))


#for r in range(1, 101, step: 1) {
  set align(center + horizon)
  set page(flipped: true)
  text(axes: (ROND: r, wdth: 151), size: 100pt, lorem(2))
}
