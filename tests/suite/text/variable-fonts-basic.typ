// Test: variable-fonts-basic
// Test basic variable font rendering with different weights

// NOTE: This test requires a variable font to be installed
// For testing, use Inter or Roboto Flex which are freely available

#set page(width: 200pt, height: auto, margin: 10pt)

// Test different weights with variable font
#let sample-text = [Whereas recognition of the inherent dignity]
#set text(font: "source serif 4", size: 12pt)

#text(weight: "thin", sample-text)
#linebreak()

#text(weight: "light", sample-text)
#linebreak()

#text(weight: "regular", sample-text)
#linebreak()

#text(weight: "medium", sample-text)
#linebreak()

#text(weight: "semibold", sample-text)
#linebreak()

#text(weight: "bold", sample-text)
#linebreak()

#text(weight: "extrabold", sample-text)
#linebreak()

#text(weight: "black", sample-text)
