// The preface of the docs. Only used in the paged version.

#import "system.typ": fonts, logotype

#show link: underline

#page({
  logotype
  v(2fr)
  title[Documentación de Typst]
  text(1.5em, luma(100))[Versión: #sys.version]
  v(1fr)
})

#page[
  #v(4fr)

  Derechos de autor #sym.copyright
  2019 -- #datetime.today().display("[year]")
  #context document.author.join(", ", last: " y ").

  El contenido de este documento y el compilador de Typst se licencian bajo los términos de la Apache License, Version 2.0.

  Esta documentación es de código abierto y se puede contribuir a ella en https://github.com/typst/typst. Fue compuesta con Typst #sys.version, #fonts.body, Reforma 1918, #fonts.mono e #fonts.math.

  La documentación original en inglés es publicada por Typst GmbH, Heidestraße 34, 10557 Berlin, Germany.

  https://typst.app/

  #v(1em)

  #block(
    width: 100%,
    inset: 1em,
    stroke: 0.75pt,
    radius: 3pt,
    breakable: false,
  )[
    *Traducción no oficial.* Esta es una traducción al español rioplatense (es-AR) de la documentación de Typst. *No es una publicación oficial* de Typst GmbH ni del equipo de Typst, y no cuenta con su aval. Fue traducida con inteligencia artificial (Claude Sonnet 5.5, de Anthropic), bajo la dirección y revisión de #link("https://github.com/jassielof")[Jassiel Ovando], y puede contener errores o imprecisiones. Ante cualquier duda, prevalece la documentación oficial en inglés:\ https://typst.app/docs

    *Errores y sugerencias.* ¿Encontraste un error de traducción o tenés una sugerencia? Abrí un _issue_ en el repositorio de la traducción: #link("https://github.com/jassielof/typst/issues")[github.com/jassielof/typst/issues]. Los errores de Typst o de la documentación original van en https://github.com/typst/typst/issues

    *Cambios de diseño respecto del original.* Esta edición usa otras tipografías: la familia Reforma (de PampaType, creada para la Universidad Nacional de Córdoba): #fonts.body, sin serifa, en lugar de HK Grotesk para el texto, y Reforma 1918, con serifa, para los títulos, que en el original usan la misma tipografía que el texto; #fonts.mono en lugar de Cascadia Mono para el código y #fonts.math en lugar de New Computer Modern Math para las fórmulas. Los ejemplos de código compilados se componen con el idioma español de Argentina (es-AR), y el código de los ejemplos, que no se tradujo, se muestra tal como en el original.
  ]

  #v(1fr)
]
