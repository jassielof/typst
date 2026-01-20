// fallback so it doesn't use any other font other than the specified, it sholdn't be needed, as it should strictly use the font, otherwise it means something's wrong
// raw to same font, because measure() uses raw
// And i need to test out more google sans flex
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
