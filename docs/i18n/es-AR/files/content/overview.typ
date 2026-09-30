#import "../components/index.typ": (
  big-nav-button, def-dest, docs-chapter, icon, insertion,
)

#show: docs-chapter.with(
  title: "Descripción general",
  route: "/",
  def-target: <overview>,
  description: "Aprendé a usar Typst para componer documentos más rápido. Empezá con el tutorial o sumergite en la referencia.",
  nav-buttons: html.div(class: "doc-categories", {
    context big-nav-button(
      icon: icon(32, "tutorial-c", "Circled play icon"),
      href: def-dest(<tutorial>),
      title: "Tutorial",
      description: [Guía paso a paso para ayudarte a empezar.],
    )
    context big-nav-button(
      icon: icon(32, "reference-c", "Circled information icon"),
      href: def-dest(<reference>),
      title: "Referencia",
      description: [Detalles sobre toda la sintaxis, los conceptos, los tipos y las funciones.],
    )
  }),
)

¡Te damos la bienvenida a la documentación de Typst! Typst es un sistema de composición tipográfica basado en marcado que combina una automatización potente y una tipografía de alta calidad con velocidad y facilidad de uso. Esto lo hace apto para documentos de cualquier complejidad. Typst es una gran alternativa tanto a los procesadores de texto como a LaTeX.

Esta documentación está dividida en varias partes, que cubren distintas necesidades:

- Si sos nuevo en Typst, te recomendamos empezar con nuestro @tutorial[tutorial para principiantes]. A lo largo del tutorial, te vamos a presentar Typst a través de un ejemplo práctico.

- Para responder preguntas puntuales sobre Typst y familiarizarte con las funciones avanzadas, usá la @reference[referencia]. Describe las características fundamentales del lenguaje Typst y tiene secciones para todas las funciones, los tipos y más elementos que vienen con Typst.

- Para instructivos a medida y en profundidad sobre funciones, casos de uso y públicos específicos, fijate en nuestras @guides[guías]. Incluyen fragmentos de código para copiar y te permiten ganar confianza en un área concreta. Si venís de LaTeX, la @guides:for-latex-users ofrece una introducción alternativa a Typst, que se apoya en conceptos que ya conocés.

El término _Typst_ hace referencia a tres conceptos: el lenguaje Typst, el compilador de Typst y la app web de Typst. El lenguaje es lo que escribís, el compilador traduce los archivos en lenguaje Typst a PDF, páginas HTML y otros formatos, y la app web de Typst te permite trabajar de forma colaborativa en proyectos de Typst desde el navegador. El lenguaje Typst y el compilador son de código abierto.

Esta documentación documenta principalmente el lenguaje Typst, aunque el tutorial y varias páginas hacen referencia a la app web y al compilador de Typst por línea de comandos.
#insertion(
  "overview-web-app",
  fallback: [
    En la copia de la documentación alojada en #link("https://typst.app/docs/"), también incluimos documentación sobre la app web.
  ],
)
Para aprender a instalar el compilador de Typst por línea de comandos, visitá la #link("https://typst.app/open-source")[página de código abierto] de nuestro sitio web. Ahí también podés conocer más sobre la relación entre el compilador de Typst y la app web. Una vez que hayas instalado el compilador, ejecutá `typst help` para obtener más información sobre cómo usarlo.

Nuestro #link("https://github.com/typst/typst")[repositorio de GitHub] ofrece documentación adicional para desarrolladores sobre cómo contribuir a Typst y cómo integrarlo en tus aplicaciones.

La documentación también contiene un @changelog[registro de cambios], en el que podés seguir la evolución de Typst y ver qué implican los cambios del lenguaje de marcado para tus proyectos. Esta documentación corresponde a Typst #sys.version.
