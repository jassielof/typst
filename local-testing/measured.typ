// #set text(font: "Google Sans Flex")
#set page(width: auto, height: auto)
#table(
  columns: 3,
  ..for w in range(100, 200, step: 1) {
    ([#w], context measure(text(weight: w, lorem(10))), text(weight: w, lorem(10)))
  }
)
