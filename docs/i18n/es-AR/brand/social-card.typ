// Social card (Open Graph thumbnail) of the website. Regenerate with
//   typst compile --format png --ppi 72 --font-path "<Reforma 1969 folder>" \
//     docs/i18n/es-AR/brand/social-card.typ docs/i18n/es-AR/social-card.png
#set page(width: 1200pt, height: 630pt, margin: 0pt, fill: rgb("#19181f"))
#set text(font: "Reforma 1969", fill: rgb("#ececf2"))

#place(rect(width: 28pt, height: 100%, fill: rgb("#239dad")))
#place(top + left, dx: 98pt, dy: 82pt, box(
  fill: rgb("#165c67"),
  stroke: 2pt + rgb("#2f95a3"),
  radius: 14pt,
  inset: (x: 26pt, y: 12pt),
  text(size: 46pt, weight: "bold", fill: rgb("#e4f6f9"))[rioplatense],
))
#place(top + left, dx: 98pt, dy: 205pt, text(size: 92pt, weight: "bold")[Documentación\ de Typst])
#place(top + left, dx: 98pt, dy: 450pt, text(size: 36pt, fill: rgb("#a9a9b8"))[
  Traducción no oficial: tutorial, referencia y guías.
])
#place(top + left, dx: 98pt, dy: 530pt, text(size: 27pt, fill: rgb("#2bb3c4"))[
  Sitio y PDF · basado en la documentación oficial de Typst
])
