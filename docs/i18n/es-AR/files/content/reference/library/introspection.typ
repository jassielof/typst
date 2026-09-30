#import "../../../components/index.typ": docs-category

#show: docs-category.with(
  title: "Introspección",
  description: "Documentación de la funcionalidad que permite las interacciones entre distintas partes de un documento.",
  category: "introspection",
)

Interacciones entre partes del documento.

Esta categoría es el hogar de las capacidades de introspección de Typst: con la función `counter`, podés acceder a los contadores de páginas, secciones, figuras y ecuaciones y manipularlos, o crear contadores personalizados. Por su parte, la función `query` te permite buscar elementos en el documento para construir cosas como una lista de figuras o encabezados que muestran el título del capítulo actual.

La mayoría de las funciones son _contextuales._ Se recomienda leer el capítulo sobre @reference:context[contexto] antes de continuar acá.
