#let the-font = "Google Sans Flex"
#set text(
  font: the-font,
  fallback: false,
)
#show raw: set text(
  font: the-font,
  fallback: false,
)

#table(
  columns: (auto, auto, 1fr, auto),
  ..for w in range(100, 1000, step: 1) {
    (
      [#w],
      context [
        - #measure(text(weight: w, lorem(10))).width
        - #measure(text(weight: w, lorem(10))).height
      ],
      text(weight: w, lorem(10)),
      context text.font,
    )
  }
)
