// Entry point of the es-AR website. The `base` input is the path the site is
// served from, e.g. `--input base=/typst/` for a GitHub Pages project site.
//
//   cargo docit compile --format website --lang es-AR --release \
//     --input base=/typst/ docs/i18n/es-AR/web.typ docs/dist/site-es-AR
#import "@typst/docs:0.0.0": docs

#let base = sys.inputs.at("base", default: "/")

// The fonts of the PDF edition, served as assets. Reforma is fetched by
// `python3 tools/i18n fonts`; the others are committed in `fonts/`.
#let font-files = (
  "Reforma2018-Gris.ttf",
  "Reforma2018-GrisItalica.ttf",
  "Reforma2018-Negra.ttf",
  "Reforma2018-NegraItalica.ttf",
  "Reforma1918-Gris.ttf",
  "Reforma1918-GrisItalica.ttf",
  "Reforma1918-Negra.ttf",
  "Reforma1918-NegraItalica.ttf",
  "GoogleSansCode-Regular.ttf",
  "GoogleSansCode-Bold.ttf",
  "IBMPlexMath-Regular.otf",
)
#for file in font-files {
  asset(base + "assets/fonts/" + file, read("fonts/" + file, encoding: none))
}

// Redefines the families that the original style sheets use, so that no
// upstream CSS has to change: "HK Grotesk" (text) becomes Reforma 2018,
// "Cascadia Mono" (code) Google Sans Code and "NewComputerModernMath" IBM Plex
// Math. Headings use Reforma 1918. These rules come after the original ones.
#let face(family, file, weight, style: "normal", format: "truetype") = (
  "@font-face{font-family:\"" + family + "\";font-weight:" + str(weight)
    + ";font-style:" + style + ";font-display:swap;src:url(\"" + base
    + "assets/fonts/" + file + "\") format(\"" + format + "\");}"
)
#let weights = range(100, 1000, step: 100)
#let reforma(family, prefix) = (
  weights
  .map(weight => {
    let name = if weight >= 600 { "Negra" } else { "Gris" }
    (("normal", ""), ("italic", "Italica"))
      .map(((style, suffix)) => face(
        family,
        prefix + "-" + name + suffix + ".ttf",
        weight,
        style: style,
      ))
      .join()
  })
  .join()
)
#let mono = (
  weights
  .map(weight => face(
    "Cascadia Mono",
    if weight >= 600 { "GoogleSansCode-Bold.ttf" } else { "GoogleSansCode-Regular.ttf" },
    weight,
  ))
  .join()
)
#let style = (
  reforma("HK Grotesk", "Reforma2018")
    + reforma("Reforma 1918", "Reforma1918")
    + mono
    + face(
      "NewComputerModernMath",
      "IBMPlexMath-Regular.otf",
      400,
      format: "opentype",
    )
    + "body.docs h1,body.docs h2,body.docs h3{font-family:\"Reforma 1918\",\"HK Grotesk\",serif;font-variant-numeric:lining-nums;}"
)

// Shown at the top of every page (see the `page-top` insertion).
#let notice = {
  html.style(style)
  html.div(
    style: "box-sizing: border-box; width: 100%; padding: 0.5em 1em; font-size: 0.8em; line-height: 1.4; text-align: center; background: #fff7e0; color: #4a3b00; border-bottom: 1px solid #e6c85c;",
    {
      strong[Traducción no oficial]
      [ al español rioplatense (es-AR), generada con IA (Claude Sonnet 5.5) bajo la dirección y revisión de ]
      link("https://github.com/jassielof")[Jassiel Ovando]
      [. No es una publicación de Typst GmbH ni cuenta con su aval; ante cualquier duda, prevalece la ]
      link("https://typst.app/docs")[documentación oficial en inglés]
      [. También podés ]
      link(base + "docs-es-AR.pdf")[descargar el PDF]
      [. Tipografía: ]
      link("https://www.pampatype.com/reforma")[Reforma]
      [, de PampaType.]
    },
  )
}

#docs(
  content-base: base,
  asset-base: base + "assets/",
  insertions: ("page-top": notice),
)
