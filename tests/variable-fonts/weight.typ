#let the-font = "Google Sans Flex"
#set text(
  font: the-font,
  // fallback: false,
)
#show raw: set text(
  font: the-font,
  // fallback: false,
)
// #set page(width: auto)

#table(
  columns: 4,
  ..for w in range(100, 1000, step: 1) {
    (
      [#w],
      context [#measure(text(weight: w, lorem(10)))],
      [
        #text(weight: w, lorem(10))
      ],
      context text.font,
    )
  }
)
