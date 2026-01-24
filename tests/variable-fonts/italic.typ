#let the-font = "Retail Variable"
#set text(
  font: the-font,
  fallback: false,
)

= #context text.font

#lorem(30)

#text(style: "italic", lorem(30))

_#lorem(30)_

#emph(lorem(30))
