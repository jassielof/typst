#import "../../../components/index.typ": docs-category, short-or-long, scope

#show: docs-category.with(
  title: "Formatos",
  description: "Documentación de los formatos de exportación de Typst.",
  category: "format",
  scope: scope(std, "format"),
  sub-categories: dictionary(format),
)

Los documentos de Typst se pueden exportar a varios formatos de exportación distintos. Esta sección documenta los formatos de exportación disponibles y enumera las configuraciones y características específicas de cada formato.

Cada formato de exportación tiene un elemento asociado con el que se puede configurar. Estos elementos están definidos en el módulo global `format`. Los formatos principales `pdf` y `html` además están directamente disponibles en el ámbito global.

= #short-or-long[Ajustes de exportación][Configurar los ajustes de exportación] <export-settings>
Hay dos maneras de especificar los ajustes de exportación:

- Al momento de exportar, mediante argumentos de línea de comandos o el panel "Export & Preview" de la app web
- En el documento, mediante una @reference:styling:set-rules[regla set] sobre el elemento del formato

A continuación hay un ejemplo que muestra cómo podrías cambiar el @pdf.standard[estándar de PDF] por defecto de un documento. A menos que se especifique otra cosa (por ejemplo, mediante un argumento de línea de comandos), un documento con esta regla set se exportará como PDF/UA-1.

```typ
// The document will now default to PDF/UA-1.
#set pdf(standard: "ua-1")
```

De manera similar, podemos escribir una regla set que haga que los PNG renderizados sean un poco más nítidos por defecto. Acá tenemos que escribir @format.png en lugar de solo `png`, ya que el elemento del formato PNG no está disponible globalmente (es un formato de exportación un poco más de nicho que PDF).

```typ
// This makes PNGs a bit higher-res.
#set format.png(ppi: 300)
```
