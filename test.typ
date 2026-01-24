#[
  #set text(font: "New Computer Modern Mono")

  // This works fine, Hola and Buenardo are emphasized with italics as default, and Adios, since it's nested, is normal, basically the emphasize style gets negated or nullified when nested, and so on.
  #emph[Hola #emph[Adios] Buenardo]

  // So here, we would want to change the default style of emphasis to use the oblique style, instead of the italics style. But, this works not as expected, here, Hola and Buenardo are now regular style, and Adios is oblique, which is the opposite
  // Expected should be: Hola (oblique), Adios (normal), Buenardo (oblique)
  #show emph: set text(style: "oblique")
  #emph[Hola #emph[Adios] Buenardo]

  // And here, same behavior, the nested Adios is normal, while Hola and Buenardo are italics or the default emphasis style.
  #show emph: set text(style: "normal")
  // Expected should be: Hola (normal), Adios (italic?), Buenardo (normal)
  #emph[Hola #emph[Adios] Buenardo]
]


// A similar issue happens with raw
// The shorthand for the emph[<content>] is _<content>_
#[
  // This is buggy, as here the "`code`" part is still italics
  // Expected should be that the "`code`" part is normal or upright
  #show raw: set text(style: "normal")
  Yeah, _this `code` here_ should be upright.

  // But here, the "`code`" part is now upright or of "normal" style
  // Expected should be that the "`code`" part is italics
  #show raw: set text(style: "italic")
  Yeah, _this `code` here_ shouldn't be upright.

  // An additional comment
  // The text's emph attribute is set to true, so it sets normal text to italic and italic text to normal.
  // This yields the normally expected result of nested #emph calls toggling each other.
  // So, we set the style to "italic" and we get "normal" text.
]

#[
  // Another user reports a similar issue with math, but I can't replicate his behavior, so JUST IGNORE THE FOLLOWING BLOCK
  - $A = b * 1234567890$ // normal
  - #emph[$A = b * 1234567890$]
  - #emph[$A = #emph($b * 1234567890$)$] // still normal

  #show math.equation: it => {
    set text(font: "Libertinus Math") // same as the default font already, just to be explicit
    show regex("\d"): set text(font: "IBM Plex Mono", style: "normal")
    it
  }

  - $A = b * 1234567890$ // normal
  - #emph[$A = b * 1234567890 times f(x)$] // still normal
  - #emph[$A = #emph($b * 1234567890 times f(x)$)$] // still normal

  #show emph: it => {
    if text.style == "normal" {
      text(style: "italic", it.body)
    } else {
      text(style: "normal", it.body)
    }
  }


  - $ A = b * 1234567890 times f(x) $ // normal
  - #emph[$ A = b * 1234567890 times f(x) $] // still normal
  - #emph[$A = #emph($b * 1234567890$)$] // still normal
]
