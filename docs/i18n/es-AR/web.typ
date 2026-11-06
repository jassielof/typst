// Entry point of the es-AR website. The `base` input is the path the site is
// served from, e.g. `--input base=/typst/` for a GitHub Pages project site.
//
//   cargo docit compile --format website --lang es-AR --release \
//     --input base=/typst/ docs/i18n/es-AR/web.typ docs/dist/site-es-AR
#import "@typst/docs:0.0.0": docs

#let base = sys.inputs.at("base", default: "/")

// The fonts of the PDF edition, served as assets from the committed font folders (web flavors where they exist).
#let reforma-dir = "fonts/Reforma/Reforma/Reforma Webfonts/"
#let font-files = (
  ..for (family, dir) in (
    ("Reforma1918", "Reforma1918"),
    ("Reforma1969", "Reforma1969"),
    ("Reforma2018", "Reforma2018"),
  ) {
    for style in (
      "Gris",
      "GrisItalica",
      "Negra",
      "NegraItalica",
    ) {
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

// Override upstream font families without modifying their stylesheets:
// Running text uses Reforma 1969,
// "Cascadia Mono" is replaced by Chivo Mono for code,
// and "NewComputerModernMath" maps to IBM Plex Math.
// Headings use Reforma 2018 and the site header uses Reforma 1918.
// These declarations follow the upstream stylesheets.
#let face(family, file, weight, style: "normal", format: "woff2") = (
  "@font-face{font-family:\""
    + family
    + "\";font-weight:"
    + weight
    + ";font-style:"
    + style
    + ";font-display:swap;src:url(\""
    + base
    + "assets/fonts/"
    + file
    + "\") format(\""
    + format
    + "\");}"
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
// One rule per weight (the variable font covers them all). It gets its own family name and the original rules are overridden below: reusing the name "Cascadia Mono" left some elements on the original font.
#let mono(file, style) = (
  weights
    .map(weight => face(
      "Chivo Mono",
      file,
      str(weight),
      style: style,
      format: "truetype",
    ))
    .join()
)
// The dark palette: applied when chosen explicitly (`data-theme="dark"` on the
// root element) and, unless "light" was chosen, when the system prefers it.
#let dark-src = read("dark.css")
#let dark-css = (
  dark-src.replace("@@", ":root[data-theme='dark']")
    + "@media (prefers-color-scheme: dark){"
    + dark-src.replace("@@", ":root:not([data-theme='light'])")
    + "}"
)
#let style = (
  reforma("Reforma 1969", "Reforma1969")
    + reforma("Reforma 2018", "Reforma2018")
    + reforma("Reforma 1918", "Reforma1918")
    + mono("ChivoMono.ttf", "normal")
    + mono("ChivoMono-Italic.ttf", "italic")
    + face("NewComputerModernMath", "IBMPlexMath-Regular.woff2", "400")
    + "body.docs{font-family:\"Reforma 1969\",\"HK Grotesk\",sans-serif;}"
    + "body.docs :is(h1,h2,h3,h4,h5,h6){font-family:\"Reforma 2018\",\"HK Grotesk\",sans-serif;font-variant-numeric:lining-nums;}"
    + "#es-ar-notice{position:relative;box-sizing:border-box;width:100%;padding:.5em 3em .5em 1em;font-size:.8em;line-height:1.7;text-align:center;border-bottom:1px solid #e6c85c;}"
    + "#es-ar-notice button{position:absolute;top:.2em;right:.5em;padding:0 .4em;border:0;background:none;color:inherit;font-size:1.6em;line-height:1;cursor:pointer;}"
    + ".es-ar-theme{margin:1.5em 0 0;font-size:.8em;color:var(--text-primary);}"
    + ".es-ar-theme>div{display:flex;margin-top:.4em;}"
    + ".es-ar-theme button{flex:1;padding:.3em .2em;border-radius:0;font:inherit;cursor:pointer;}"
    + ".es-ar-theme button:first-child{border-radius:6px 0 0 6px;}"
    + ".es-ar-theme button:last-child{border-radius:0 6px 6px 0;}"
    + ".es-ar-theme button+button{border-left-width:0;}"
    + ".es-ar-theme button[data-theme][aria-pressed=true]{background-color:var(--theme-selected-bg,#165c67);border-color:var(--theme-selected-bg,#165c67);color:var(--theme-selected-ink,#fff);font-weight:700;}"
    + dark-css
    + ".es-ar-header{box-sizing:border-box;width:100%;padding:14px 32px;border-bottom:1px solid var(--border-secondary,#ddd);}"
    + ".es-ar-header{display:flex;align-items:center;justify-content:space-between;gap:16px;font-family:\"Reforma 1918\",Georgia,serif;}"
    + ".es-ar-brand{display:inline-flex;align-items:center;gap:14px;color:var(--text-primary,#19181f);text-decoration:none;font-size:20px;font-weight:700;}"
    + ".es-ar-brand img{display:block;width:36px;height:36px;}"
    + ".es-ar-brand:hover{text-decoration:none;}"
    + ".es-ar-language{font-size:13px;color:var(--es-ar-muted-text,#666);}"
    + "@media(max-width:695px){.es-ar-header{padding:12px 24px;}.es-ar-language{display:none;}}"
)

// The favicon is a hand-made SVG (outlined text); the social card is generated
// with Typst (see `brand/`).
#asset(base + "assets/favicon.svg", read("brand/logo.svg", encoding: none))
#asset(base + "assets/social-card.png", read("social-card.png", encoding: none))

// SEO. `origin` (e.g. `--input origin=https://user.github.io`) is the scheme and
// host the site is served from; without it, absolute URLs (canonical, social
// cards, sitemap) are left out. The official docs share the same page paths.
#let origin = sys.inputs.at("origin", default: none)
#let official = "https://typst.app/docs/"
#let site-title = "Documentación de Typst"
#let meta(name, content, key: "name") = html.elem("meta", attrs: ((key): name, content: content))
#let seo-head(route, title, description) = {
  html.style(style)
  let rel = route.slice(base.len())
  let url = if origin != none { origin + route }
  let full-title = title + " - Documentación de Typst"
  html.link(rel: "icon", type: "image/svg+xml", href: base + "assets/favicon.svg")
  for (family, file) in (
    ("Reforma1969", "Gris"),
    ("Reforma2018", "Negra"),
    ("Reforma1918", "Negra"),
  ) {
    html.elem("link", attrs: (
      rel: "preload",
      "as": "font",
      type: "font/woff2",
      crossorigin: "",
      href: base + "assets/fonts/" + family + "-" + file + ".woff2",
    ))
  }
  html.link(rel: "alternate", hreflang: "en", href: official + rel)
  html.link(rel: "alternate", hreflang: "x-default", href: official + rel)
  meta("og:type", "website", key: "property")
  meta("og:site_name", site-title, key: "property")
  meta("og:locale", "es_AR", key: "property")
  meta("og:title", full-title, key: "property")
  meta("og:description", description, key: "property")
  meta("twitter:card", "summary_large_image")
  meta("twitter:title", full-title)
  meta("twitter:description", description)
  if url != none {
    html.link(rel: "canonical", href: url)
    html.link(rel: "alternate", hreflang: "es-AR", href: url)
    meta("og:url", url, key: "property")
    let image = origin + base + "assets/social-card.png"
    meta("og:image", image, key: "property")
    meta("og:image:width", "1200", key: "property")
    meta("og:image:height", "630", key: "property")
    meta("og:image:alt", "Documentación de Typst, traducción rioplatense", key: "property")
    meta("twitter:image", image)
    html.script(type: "application/ld+json", json.encode((
      "@context": "https://schema.org",
      "@type": "TechArticle",
      headline: title,
      description: description,
      inLanguage: "es-AR",
      url: url,
      isBasedOn: official + rel,
      isPartOf: (
        "@type": "WebSite",
        name: site-title,
        url: origin + base,
        inLanguage: "es-AR",
      ),
    )))
  }
}

// Crawler files. A sitemap (and, for a custom domain at the root, robots.txt)
// plus a Spanish 404 page.
#context if origin != none {
  let pages = query(<metadata-page>).map(page => page.value.route)
  asset(
    base + "sitemap.xml",
    bytes(
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        + "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
        + pages.map(route => "<url><loc>" + origin + route + "</loc></url>\n").join()
        + "</urlset>\n",
    ),
  )
  asset(
    base + "robots.txt",
    bytes("User-agent: *\nAllow: /\n\nSitemap: " + origin + base + "sitemap.xml\n"),
  )
}
#document(base + "404.html", title: "Página no encontrada - " + site-title, html.html(lang: "es-AR", {
  html.head({
    html.meta(charset: "utf-8")
    html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
    html.meta(name: "robots", content: "noindex")
    html.title("Página no encontrada - Documentación de Typst")
    html.style("body{font-family:sans-serif;max-width:36em;margin:4em auto;padding:0 1em;line-height:1.5}")
  })
  html.body({
    html.h1[Página no encontrada]
    html.p[No existe esta página en la documentación de Typst en español.]
    html.p({
      html.a(href: base)[Ir al inicio de la documentación]
      [ · ]
      html.a(href: official)[Documentación oficial (en inglés)]
    })
  })
}))

// A prominent link to the PDF edition, in the banner and in the sidebar.
#let pdf-style = "display: inline-block; padding: 0.15em 0.8em; border: 1px solid var(--brand-line, #239dad); border-radius: 6px; background: var(--brand, #239dad); color: var(--brand-ink, #fff); font-weight: bold; text-decoration: none;"
#let pdf-button(block: false) = html.a(
  href: base + "Documentaci%C3%B3n%20de%20Typst.pdf",
  style: pdf-style
    + if block { " display: block; text-align: center; margin: 1.5em 0 0.5em; padding: 0.5em 0.8em;" } else {
      " font-size: 1em; line-height: 1.3; padding: 0.05em 0.7em; margin: 0 0.2em; border-radius: 4px; font-weight: 600;"
    },
  [Descargar el PDF],
)

// Shown at the top of every page (see the `page-top` insertion). It can be closed; the choice is only remembered for the current browser session so the disclaimer comes back on the next visit.
// #let close-js = "document.getElementById('es-ar-notice').style.display='none';try{sessionStorage.setItem('es-ar-notice','closed')}catch(e){}"
// #let init-js = (
// "(function(){var n=document.getElementById('es-ar-notice');"
// + "try{if(n&&sessionStorage.getItem('es-ar-notice')==='closed')n.style.display='none'}catch(e){}"
// + "})()"
// )
// Theme choice: "light", "dark" or none (follow the system, the default).
#let theme-js = (
  "function esArTheme(t){var r=document.documentElement;"
    + "if(t==='light'||t==='dark')r.setAttribute('data-theme',t);else{r.removeAttribute('data-theme');t='system'}"
    + "try{if(t==='system')localStorage.removeItem('es-ar-theme');else localStorage.setItem('es-ar-theme',t)}catch(e){}"
    + "var b=document.querySelectorAll('.es-ar-theme button');"
    + "for(var i=0;i<b.length;i++)b[i].setAttribute('aria-pressed',String(b[i].dataset.theme===t))}"
    + "(function(){var t='system';try{t=localStorage.getItem('es-ar-theme')||'system'}catch(e){}"
    + "if(t!=='light'&&t!=='dark')t='system';"
    + "if(t!=='system')document.documentElement.setAttribute('data-theme',t);"
    + "document.addEventListener('DOMContentLoaded',function(){var b=document.querySelectorAll('.es-ar-theme button');for(var i=0;i<b.length;i++)b[i].setAttribute('aria-pressed',String(b[i].dataset.theme===t))})})()"
)

#let issues = "https://github.com/jassielof/typst/issues"

/// Which revision of the repository this was built from (see `revision` in `docs/src/i18n.rs`): commit (linked), its date and the Typst version.
#let revision-note = {
  let r = stdx.revision
  html.p({
    [Revisión ]
    if r.commit != none {
      html.a(href: r.repo + "/commit/" + r.commit, r.short)
      [ (#r.date-long)]
    } else [sin datos de Git]
    html.br()
    [Typst #r.version · compilada el #r.built-long]
  })
}

#let theme-switch = html.div(class: "es-ar-theme", {
  [Tema]
  html.div(
    for (id, label) in (("light", "Claro"), ("dark", "Oscuro"), ("system", "Sistema")) {
      html.elem("button", attrs: (
        type: "button",
        "data-theme": id,
        "aria-pressed": "false",
        onclick: "esArTheme('" + id + "')",
      ))[#label]
    },
  )
})


#let notice-style = "
  #es-ar-notice {
    box-sizing: border-box;
    width: 100%;
    padding: 24px;
    border-top: 1px solid var(--border-secondary, #ddd);
    background: transparent;
    color: var(--text-primary, #333);
  }

  #es-ar-notice .notice-inner {
    max-width: 800px;
    margin-inline: auto;
    font-size: 13px;
    line-height: 1.65;
    text-align: left;
  }

  #es-ar-notice p {
    margin: 0 0 0.65em;
  }

  #es-ar-notice p:last-child {
    margin-bottom: 0;
  }

  #es-ar-notice a {
    color: inherit;
    text-decoration: underline;
    text-underline-offset: 2px;
  }
"

#let notice = {
  html.style(style + notice-style)

  html.div(id: "es-ar-notice", {
    html.div(class: "notice-inner", [
      *Traducción no oficial · Español rioplatense*

      Traducción realizada con asistencia de IA, bajo la dirección y revisión de #link("https://github.com/jassielof")[Jassiel Ovando]. Este sitio no está afiliado a Typst GmbH ni cuenta con su aval. Ante cualquier discrepancia, prevalece la #link("https://typst.app/docs")[documentación oficial en inglés].

      #link(issues)[Reportar un error o sugerencia] · Tipografía: #link("https://www.pampatype.com/reforma")[Reforma de PampaType], #link("https://www.omnibus-type.com/fonts/chivo-mono/")[Chivo Mono] y #link("https://www.ibm.com/plex/")[IBM Plex (Math)].

      #revision-note
    ])
  })

  html.script(theme-js)
}

#let site-header = html.div(class: "es-ar-header", {
  html.a(href: base, class: "es-ar-brand", {
    html.img(
      src: base + "assets/favicon.svg",
      alt: "",
      width: 36,
      height: 36,
    )
    html.span[Documentación de Typst]
  })
  html.span(class: "es-ar-language")[Español rioplatense]
})

#docs(
  content-base: base,
  asset-base: base + "assets/",
  insertions: (
    head: seo-head,
    "page-top": site-header,
    "page-bottom": notice,
    "after-nav-items": {
      pdf-button(block: true)
      theme-switch
    },
  ),
)
