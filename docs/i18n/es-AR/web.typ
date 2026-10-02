// Entry point of the es-AR website. The `base` input is the path the site is
// served from, e.g. `--input base=/typst/` for a GitHub Pages project site.
//
//   cargo docit compile --format website --lang es-AR --release \
//     --input base=/typst/ docs/i18n/es-AR/web.typ docs/dist/site-es-AR
#import "@typst/docs:0.0.0": docs

#let base = sys.inputs.at("base", default: "/")

// The fonts of the PDF edition, served as assets from the committed font
// folders (web flavors where they exist).
#let reforma-dir = "fonts/Reforma/Reforma/Reforma Webfonts/"
#let font-files = (
  ..for (family, dir) in (("Reforma1918", "Reforma1918"), ("Reforma2018", "Reforma2018")) {
    for style in ("Gris", "GrisItalica", "Negra", "NegraItalica") {
      ((family + "-" + style + ".woff2", reforma-dir + dir + "/" + family + "-" + style + ".woff2"),)
    }
  },
  ("ChivoMono.ttf", "fonts/ChivoMono/ChivoMono-VariableFont_wght.ttf"),
  ("ChivoMono-Italic.ttf", "fonts/ChivoMono/ChivoMono-Italic-VariableFont_wght.ttf"),
  ("IBMPlexMath-Regular.woff2", "fonts/IBMPlexMath/fonts/complete/woff2/IBMPlexMath-Regular.woff2"),
)
#for (name, path) in font-files {
  asset(base + "assets/fonts/" + name, read(path, encoding: none))
}

// Redefines the families that the original style sheets use, so that no
// upstream CSS has to change: "HK Grotesk" (text) becomes Reforma 2018,
// "Cascadia Mono" (code) Chivo Mono and "NewComputerModernMath" IBM Plex Math.
// Headings use Reforma 1918. These rules come after the original ones.
#let face(family, file, weight, style: "normal", format: "woff2") = (
  "@font-face{font-family:\"" + family + "\";font-weight:" + weight
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
        prefix + "-" + name + suffix + ".woff2",
        str(weight),
        style: style,
      ))
      .join()
  })
  .join()
)
#let style = (
  reforma("HK Grotesk", "Reforma2018")
    + reforma("Reforma 1918", "Reforma1918")
    + face("Cascadia Mono", "ChivoMono.ttf", "100 900", format: "truetype")
    + face(
      "Cascadia Mono",
      "ChivoMono-Italic.ttf",
      "100 900",
      style: "italic",
      format: "truetype",
    )
    + face("NewComputerModernMath", "IBMPlexMath-Regular.woff2", "400")
    + "body.docs h1,body.docs h2,body.docs h3{font-family:\"Reforma 1918\",\"HK Grotesk\",serif;font-variant-numeric:lining-nums;}"
)

// A simple favicon, so the tab does not show a generic icon (and does not imitate
// the official one).
#let favicon = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'><rect width='64' height='64' rx='14' fill='#239dad'/><text x='32' y='46' font-family='Georgia,serif' font-size='40' font-weight='bold' text-anchor='middle' fill='#fff'>ES</text></svg>"
#asset(base + "assets/favicon.svg", bytes(favicon))

// A prominent link to the PDF edition, in the banner and in the sidebar.
#let pdf-style = "display: inline-block; padding: 0.15em 0.8em; border: 1px solid var(--brand, #239dad); border-radius: 6px; background: var(--brand, #239dad); color: #fff; font-weight: bold; text-decoration: none;"
#let pdf-button(block: false) = html.a(
  href: base + "docs-es-AR.pdf",
  style: pdf-style + if block { " display: block; text-align: center; margin: 1.5em 0 0.5em; padding: 0.5em 0.8em;" },
  [Descargar el PDF],
)

// Shown at the top of every page (see the `page-top` insertion). It can be
// closed; the choice is only remembered for the current browser session so the
// disclaimer comes back on the next visit.
#let close-js = "document.getElementById('es-ar-notice').style.display='none';try{sessionStorage.setItem('es-ar-notice','closed')}catch(e){}"
#let init-js = (
  "(function(){var n=document.getElementById('es-ar-notice');"
    + "try{if(n&&sessionStorage.getItem('es-ar-notice')==='closed')n.style.display='none'}catch(e){}"
    + "var l=document.createElement('link');l.rel='icon';l.type='image/svg+xml';"
    + "l.href='" + base + "assets/favicon.svg';document.head.appendChild(l)})()"
)
#let notice = {
  html.style(style)
  html.div(
    id: "es-ar-notice",
    style: "position: relative; box-sizing: border-box; width: 100%; padding: 0.5em 3em 0.5em 1em; font-size: 0.8em; line-height: 1.4; text-align: center; background: #fff7e0; color: #4a3b00; border-bottom: 1px solid #e6c85c;",
    {
      strong[Traducción no oficial]
      [ al español rioplatense (es-AR), generada con IA (Claude Sonnet 5.5) bajo la dirección y revisión de ]
      link("https://github.com/jassielof")[Jassiel Ovando]
      [. No es una publicación de Typst GmbH ni cuenta con su aval; ante cualquier duda, prevalece la ]
      link("https://typst.app/docs")[documentación oficial en inglés]
      [. ]
      pdf-button()
      [ Tipografía: ]
      link("https://www.pampatype.com/reforma")[Reforma]
      [, de PampaType.]
      html.elem("button", attrs: (
        type: "button",
        onclick: close-js,
        "aria-label": "Cerrar aviso",
        title: "Cerrar aviso",
        style: "position: absolute; top: 0.2em; right: 0.5em; padding: 0 0.4em; border: 0; background: none; color: inherit; font-size: 1.6em; line-height: 1; cursor: pointer;",
      ))[×]
    },
  )
  html.script(init-js)
}

#docs(
  content-base: base,
  asset-base: base + "assets/",
  insertions: (
    "page-top": notice,
    "after-nav-items": pdf-button(block: true),
  ),
)
