#import "../../components/index.typ": (
  docs-chapter, modifier-list, paged-heading-offset, ty-pill,
)

#docs-chapter(
  title: "Referencia",
  route: "/reference",
  description: "La referencia de Typst es una guía sistemática y completa del lenguaje de composición tipográfica Typst.",
  introduction: true,
  class: "reference-index",
)[
  Esta documentación de referencia es una guía completa de toda la sintaxis, los conceptos, las funciones, los tipos y otras definiciones de Typst. Usá la referencia para responder preguntas específicas sobre Typst y para ampliar tu comprensión de las características disponibles.

  Si sos completamente nuevo en Typst, te recomendamos empezar con el @tutorial[tutorial] y después volver a la referencia para aprender más sobre las características de Typst a medida que las necesites.

  = Lenguaje <language>
  La referencia empieza cubriendo los fundamentos del lenguaje Typst. Primero, damos un panorama de la @reference:syntax[sintaxis de Typst.] Las siguientes secciones cubren conceptos centrales del lenguaje Typst, como @reference:styling[dar estilo a los documentos,] usar las @reference:scripting[capacidades de scripting de Typst] y @reference:context[razonar sobre el contenido de tu documento.]

  = Biblioteca <library>
  #context if target() == "paged" [
    // The PDF outline does not contain the part labels, so we have to tell the reader where each section starts.
    A partir de @reference:foundations, la referencia incluye secciones
  ] else [
    La segunda parte incluye secciones
  ] sobre todas las funciones, los tipos y otras definiciones que ofrece la _biblioteca estándar_ del lenguaje Typst.

  Las secciones de definiciones están agrupadas por tema. Por ejemplo, si querés explorar todas las herramientas que ofrece Typst para ajustar dónde caen los elementos en la página, deberías empezar en la sección @reference:layout. Si en cambio preferís saber más sobre los formatos a los que puede exportar Typst, deberías recorrer la sección de @format[formatos].

  = Cómo leer la referencia <reading-the-reference>
  Esta referencia usa algunas convenciones gráficas y etiquetas para que puedas recorrer rápidamente sus secciones.

  / #ty-pill(
      str,
      linked: false,
    ): Estas píldoras indican que un valor es de un tipo particular. El capítulo de cada tipo usa la píldora respectiva como título. Los tipos similares comparten un color. Por ejemplo, todos los tipos numéricos tienen el mismo color.

  / #modifier-list[Element]: Algunas funciones están etiquetadas como elementos. Esto significa que se pueden usar con reglas set y show. Algunos elementos se pueden @locate[ubicar] y usar con la función @query. Los elementos generalmente producen salida visible en el documento. Es posible que uses elementos aunque no llames a funciones, ya que hay marcado dedicado para algunos elementos.

  / #modifier-list[Contextual]: Estas funciones pueden razonar sobre el contenido de tu documento. Solo se pueden usar cuando hay _contexto_ disponible, por ejemplo mediante un bloque de contexto. Consultá la sección @reference:context para más información.

  / #modifier-list[Required]: Aparece en un parámetro de una función si llamar a la función sin ese parámetro produciría un error.

  / #modifier-list[Positional]: Aparece en un parámetro de una función que se especifica sin nombre de parámetro ni dos puntos. En cambio, Typst usará el orden de los parámetros para determinar qué argumento es cuál. Los parámetros que no están marcados como posicionales son parámetros _con nombre._

  / #modifier-list[Variadic]: Aparece en los parámetros de funciones que se pueden especificar varias veces.

  / #modifier-list[Settable]: Aparece en los parámetros de funciones de elementos que se pueden personalizar con una regla set.
]

#show: paged-heading-offset.with(1)
#include "language/index.typ"
#include "library/index.typ"
