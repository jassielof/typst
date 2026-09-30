#import "../../../components/index.typ": docs-category

#show: docs-category.with(
  title: "Visualización",
  description: "Documentación de la funcionalidad de dibujo y visualización de datos.",
  category: "visualize",
)

Dibujo y visualización de datos.

Si querés crear dibujos o gráficos más avanzados, mirá también el paquete #link("https://github.com/johannes-wolf/cetz")[CeTZ], así como otros #link("https://typst.app/universe")[paquetes] más especializados para tu caso de uso.

= Accesibilidad <accessibility>
Todas las formas y rutas dibujadas por Typst se marcan automáticamente como @pdf.artifact[artefactos] para que sean invisibles para las tecnologías de asistencia (TA) durante la exportación a PDF. Sin embargo, su contenido (si lo hay) sigue siendo accesible.

Si estás usando las funciones de esta categoría para crear una ilustración con significado semántico, hacela accesible envolviéndola en una llamada a la función @figure. Usá su @figure.alt[parámetro `alt`] para proporcionar una @guides:accessibility:textual-representations[descripción alternativa].
