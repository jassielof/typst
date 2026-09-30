#import "../../components/index.typ": (
  docs-chapter, paged-heading-offset, section-outline,
)

#docs-chapter(
  title: "Guías",
  route: "/guides",
  description: "Guías de Typst.",
)[
  ¡Te damos la bienvenida a la sección de guías! Acá vas a encontrar material útil para grupos de usuarios o casos de uso específicos. Mirá la lista de abajo para ver las guías disponibles. ¡No dudes en proponer otros temas para guías!

  #section-outline(
    title: [Lista de guías],
    label: <list-of-guides>,
  )
]

#show: paged-heading-offset.with(1)
#include "for-latex-users.typ"
#include "page-setup.typ"
#include "tables.typ"
#include "accessibility.typ"
