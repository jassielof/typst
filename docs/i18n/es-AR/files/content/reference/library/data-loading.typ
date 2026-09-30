#import "../../../components/index.typ": docs-category

#show: docs-category.with(
  title: "Carga de datos",
  description: "Documentación de la funcionalidad de carga de datos.",
  category: "data-loading",
)

Carga de datos desde archivos externos.

Estas funciones te ayudan a cargar e incrustar datos, por ejemplo, los resultados de un experimento.

= Codificación <encoding>
Algunas de las funciones también pueden codificar, por ejemplo @cbor.encode. Facilitan pasar datos estructurados a @plugin[plugins].

Sin embargo, cada formato de datos tiene sus propios tipos nativos. Por lo tanto, para un valor arbitrario de Typst, el viaje de ida y vuelta de codificar y decodificar puede perder información. En general, los números, las cadenas de texto y los @array[arrays] o @dictionary[diccionarios] compuestos por ellos se pueden convertir de forma confiable, mientras que otros tipos pueden recurrir a cadenas de texto mediante @repr, que es @repr:debugging-only[solo para depuración]. Consultá la página de cada formato de datos para más detalles.
