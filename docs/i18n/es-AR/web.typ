// Entry point of the es-AR website. The `base` input is the path the site is
// served from, e.g. `--input base=/typst/` for a GitHub Pages project site.
//
//   cargo docit compile --format website --lang es-AR --release \
//     --input base=/typst/ docs/i18n/es-AR/web.typ docs/dist/site-es-AR
#import "@typst/docs:0.0.0": docs

#let base = sys.inputs.at("base", default: "/")

// Shown at the top of every page (see the `page-top` insertion).
#let notice = html.div(
  style: "box-sizing: border-box; width: 100%; padding: 0.5em 1em; font-size: 0.8em; line-height: 1.4; text-align: center; background: #fff7e0; color: #4a3b00; border-bottom: 1px solid #e6c85c;",
  {
    strong[Traducción no oficial]
    [ al español rioplatense (es-AR), generada con IA (Claude Sonnet 5.5) bajo la dirección y revisión de ]
    link("https://github.com/jassielof")[Jassiel Ovando]
    [. No es una publicación de Typst GmbH ni cuenta con su aval; ante cualquier duda, prevalece la ]
    link("https://typst.app/docs")[documentación oficial en inglés]
    [. También podés ]
    link(base + "docs-es-AR.pdf")[descargar el PDF]
    [.]
  },
)

#docs(
  content-base: base,
  asset-base: base + "assets/",
  insertions: ("page-top": notice),
)
