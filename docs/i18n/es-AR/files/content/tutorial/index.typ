#import "../../components/index.typ": (
  docs-chapter, paged-heading-offset, short-or-long,
)

#docs-chapter(
  title: "Tutorial",
  route: "/tutorial",
  description: "Tutorial de Typst.",
  introduction: true,
)[
  ¡Te damos la bienvenida al tutorial de Typst! En este tutorial vas a aprender a escribir y dar formato a documentos en Typst. Vamos a empezar con tareas cotidianas e ir introduciendo de a poco funciones más avanzadas. Este tutorial no supone conocimientos previos de Typst, de otros lenguajes de marcado ni de programación. Sí damos por sentado que sabés editar un archivo de texto.

  La mejor forma de empezar es registrarte gratis en la app de Typst y seguir los pasos de abajo. La app te da vista previa instantánea, resaltado de sintaxis y autocompletado útil. Como alternativa, podés seguir el tutorial en tu editor de texto local con la #link("https://github.com/typst/typst")[CLI de código abierto].

  = #short-or-long[Cuándo Typst][Cuándo usar Typst] <when-typst>
  Antes de empezar, veamos qué es Typst y cuándo conviene usarlo. Typst es un lenguaje de marcado para componer documentos. Está diseñado para ser fácil de aprender, rápido y versátil. Typst toma archivos de texto con marcado y genera PDF.

  Typst es una buena opción para escribir cualquier texto extenso, como ensayos, artículos, trabajos científicos, libros, informes y tareas. Además, Typst es ideal para documentos con notación matemática, como los trabajos de matemática, física e ingeniería. Por último, gracias a sus potentes funciones de estilos y automatización, es una excelente opción para cualquier conjunto de documentos que compartan un estilo común, como una colección de libros.

  = #short-or-long[Aprendizajes][Qué vas a aprender] <learnings>
  Este tutorial tiene cuatro capítulos. Cada capítulo se apoya en el anterior. Esto es lo que vas a aprender en cada uno:

  + @tutorial:writing-in-typst[Escribir en Typst:] Aprendé a escribir texto e insertar imágenes, ecuaciones y otros elementos.
  + @tutorial:formatting[Formato:] Aprendé a ajustar el formato de tu documento, incluidos el tamaño de fuente, los estilos de los títulos y más.
  + @tutorial:advanced-styling[Estilos avanzados:] Creá un diseño de página complejo para un trabajo científico, con características tipográficas como una lista de autores y títulos incorporados al párrafo.
  + @tutorial:making-a-template[Crear una plantilla:] Construí una plantilla reutilizable a partir del trabajo que creaste en el capítulo anterior.

  ¡Esperamos que disfrutes Typst!
]

#show: paged-heading-offset.with(1)
#include "1-writing.typ"
#include "2-formatting.typ"
#include "3-advanced.typ"
#include "4-template.typ"
