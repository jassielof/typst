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

  Esta documentación es de código abierto y se puede contribuir a ella en https://github.com/typst/typst. Fue compuesta con Typst #sys.version, #fonts.body y #fonts.mono. La traducción al español rioplatense fue generada con IA y puede contener errores; ante cualquier duda, prevalece la documentación oficial en inglés.

  Publicado por Typst GmbH, Heidestraße 34, 10557 Berlin, Germany.

  https://typst.app/

  #v(1fr)
]
