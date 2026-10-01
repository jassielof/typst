#import "../../components/index.typ": docs-chapter, example, short-or-long

#show: docs-chapter.with(
  title: "Guía de configuración de página",
  route: "/guides/page-setup",
  description: "Una guía en profundidad para configurar las dimensiones de la página, los márgenes y los números de página en Typst. Aprendé a crear diseños atractivos y claros y a lograrlo rápidamente.",
)

La configuración de tu página es una gran parte de la primera impresión que da tu documento. La longitud de las líneas, los márgenes y las columnas influyen en la #link("https://practicaltypography.com/page-margins.html")[apariencia] y en la #link("https://designregression.com/article/line-length-revisited-following-the-research")[legibilidad], mientras que los encabezados y pies de página adecuados ayudarán a tu lector a navegar fácilmente por el documento. Esta guía te va a ayudar a personalizar las páginas, los márgenes, los encabezados, los pies de página y los números de página para que se ajusten bien a tu contenido y puedas ponerte a escribir.

En Typst, cada página tiene un ancho, un alto y márgenes en los cuatro lados. Los márgenes superior e inferior pueden contener un encabezado y un pie de página. La regla set del elemento @page[`{page}`] es donde controlás toda la configuración de la página. Si hacés cambios con esta regla set, Typst se asegurará de que haya después una página vacía nueva y conforme, por lo que puede insertar un salto de página. Por lo tanto, lo mejor es especificar tu regla set de @page[`{page}`] al comienzo de tu documento o en tu plantilla.

```example
#set rect(
  width: 100%,
  height: 100%,
  inset: 4pt,
)
>>> #set text(6pt)
>>> #set page(margin: auto)

#set page(
  paper: "iso-b7",
  header: rect(fill: aqua)[Header],
  footer: rect(fill: aqua)[Footer],
  number-align: center,
)

#rect(fill: aqua.lighten(40%))
```

Este ejemplo visualiza las dimensiones del contenido de la página, los encabezados y los pies de página. El contenido de la página es el tamaño de la página (ISO B7) menos el margen por defecto de cada lado. En los márgenes superior e inferior hay rectángulos con trazo que visualizan el encabezado y el pie de página. No tocan el contenido principal, sino que están desplazados el 30 % del margen respectivo. Podés controlar este desplazamiento especificando los argumentos @page.header-ascent[`header-ascent`] y @page.footer-descent[`footer-descent`].

A continuación, la guía va a entrar en más detalle sobre cómo cumplir con requisitos comunes de configuración de página, con ejemplos.

= #short-or-long[Personalizar márgenes][Personalizar el tamaño de página y los márgenes] <customize-margins>
El tamaño de página por defecto de Typst es papel A4. Según tu región y tu caso de uso, vas a querer cambiarlo. Podés hacerlo con la regla set de @page[`{page}`], pasándole un argumento de tipo cadena de texto para usar un tamaño de página común. Las opciones incluyen la serie ISO 216 completa (por ejemplo, `"a4"` y `"iso-c2"`), formatos habituales de EE. UU. como `"us-legal"` o `"us-letter"` y más. Consultá la referencia del @page.paper[argumento paper de la página] para conocer todas las opciones disponibles.

```example
>>> #set page(margin: auto)
#set page("us-letter")

This page likes freedom.
```

Si necesitás personalizar el tamaño de tu página con ciertas dimensiones, podés especificar en cambio los argumentos con nombre @page.width[`width`] y @page.height[`height`].

```example
>>> #set page(margin: auto)
#set page(width: 12cm, height: 12cm)

This page is a square.
```

== #short-or-long[Cambiar márgenes][Cambiar los márgenes de la página] <change-margins>
Los márgenes son un ingrediente vital de la buena tipografía: #link("https://webtypography.net/2.1.2")[los tipógrafos consideran que las líneas de entre 45 y 75 caracteres son la mejor longitud para la legibilidad] y tus márgenes y tus @guides:page-setup:columns[columnas] ayudan a definir el ancho de las líneas. Por defecto, Typst creará márgenes proporcionales al tamaño de página de tu documento. Para establecer márgenes personalizados, vas a usar el argumento @page.margin[`margin`] en la regla set de @page[`{page}`].

El argumento `margin` acepta una longitud si querés establecer todos los márgenes con el mismo ancho. Sin embargo, a menudo querés establecer márgenes distintos en cada lado. Para eso, podés pasar un diccionario:

```example
#set page(margin: (
  top: 3cm,
  bottom: 2cm,
  x: 1.5cm,
))

#lorem(100)
```

El diccionario de márgenes de página puede tener claves para cada lado (`top`, `bottom`, `left`, `right`), pero también podés controlar juntos el izquierdo y el derecho estableciendo la clave `x` del diccionario de márgenes, como en el ejemplo. De la misma manera, los márgenes superior e inferior se pueden ajustar juntos estableciendo la clave `y`.

Si no especificás márgenes para todos los lados en el diccionario de márgenes, los márgenes anteriores seguirán vigentes en los lados sin establecer. Para evitar esto y establecer todos los márgenes restantes con un tamaño común, podés usar la clave `rest`. Por ejemplo, `[#set page(margin: (left: 1.5in, rest: 1in))]` establecerá el margen izquierdo en 1,5 pulgadas y los demás márgenes en una pulgada.

== #short-or-long[Márgenes alternados][Márgenes distintos en páginas alternadas] <alternating-margins>
A veces vas a necesitar alternar los márgenes horizontales entre las páginas pares e impares, por ejemplo, para tener más espacio hacia el lomo de un libro que en los bordes exteriores de sus páginas. Typst lleva registro de si una página está a la izquierda o a la derecha de la encuadernación. Podés usar esta información y establecer las claves `inside` u `outside` del diccionario de márgenes. El margen `inside` apunta hacia el lomo y el margen `outside` apunta hacia el borde del libro encuadernado.

```typ
#set page(margin: (inside: 2.5cm, outside: 2cm, y: 1.75cm))
```

Typst supondrá que los documentos escritos en escrituras de izquierda a derecha están encuadernados a la izquierda, mientras que los libros escritos en escrituras de derecha a izquierda están encuadernados a la derecha. Sin embargo, en algunos casos vas a tener que cambiar esto: si tu primera página la produce otra aplicación, la encuadernación queda invertida desde la perspectiva de Typst. Además, algunos libros, como los mangas en inglés, suelen encuadernarse a la derecha, aunque el inglés use una escritura de izquierda a derecha. Para cambiar el lado de la encuadernación y establecer explícitamente dónde están `inside` y `outside`, establecé el argumento @page.binding[`binding`] en la regla set de @page[`{page}`].

```typ
// Produce a book bound on the right,
// even though it is set in Spanish.
#set text(lang: "es")
#set page(binding: right)
```

Si `binding` es `left`, los márgenes `inside` estarán a la izquierda en las páginas impares, y viceversa.

= #short-or-long[Encabezados y pies][Agregar encabezados y pies de página] <headers-and-footers>
Los encabezados y los pies de página se insertan en los márgenes superior e inferior de cada página. Podés agregar encabezados y pies de página personalizados o simplemente insertar un número de página.

Si necesitás algo más que un número de página, la mejor forma de insertar un encabezado y un pie de página son los argumentos @page.header[`header`] y @page.footer[`footer`] de la regla set de @page[`{page}`]. Podés pasar cualquier contenido como valor:

```example
>>> #set page("a5", margin: (x: 2.5cm, y: 3cm))
#set page(header: [
  _Lisa Strassner's Thesis_
  #h(1fr)
  National Academy of Sciences
])

#lorem(150)
```

Los encabezados están alineados abajo por defecto, para que no choquen con el borde superior de la página. Podés cambiarlo envolviendo tu encabezado en la función @align[`{align}`].

== #short-or-long[Páginas específicas][Encabezado y pie distintos en páginas específicas] <specific-pages>
Vas a necesitar encabezados y pies de página distintos en algunas páginas. Por ejemplo, quizás no quieras encabezado ni pie de página en la portada. El siguiente ejemplo muestra cómo quitar condicionalmente el encabezado de la primera página:

```typ
#set page(header: context {
  if counter(page).get().first() > 1 [
    _Lisa Strassner's Thesis_
    #h(1fr)
    National Academy of Sciences
  ]
})

#lorem(150)
```

Este ejemplo puede parecer intimidante, pero vamos a desglosarlo: al usar la palabra clave `{context}`, le decimos a Typst que el encabezado depende de dónde estamos en el documento. Luego le preguntamos a Typst si el @counter[contador] de páginas es mayor que uno en nuestra posición actual (dependiente del contexto). El contador de páginas empieza en uno, así que estamos salteando el encabezado en una sola página. Los contadores pueden tener varios niveles. Esta característica se usa para elementos como los títulos, pero el contador de páginas siempre tendrá un solo nivel, así que podemos mirar simplemente el primero.

Por supuesto, podés agregar un `else` a este ejemplo para agregar en cambio un encabezado distinto en la primera página.

== #short-or-long[Elementos específicos][Adaptar encabezados y pies en páginas con elementos específicos] <specific-elements>
La técnica descrita en la sección anterior se puede adaptar para realizar tareas más avanzadas usando las etiquetas de Typst. Por ejemplo, las páginas con tablas grandes podrían omitir sus encabezados para ayudar a reducir el desorden. Vamos a marcar nuestras tablas con una @label[etiqueta] `<big-table>` y a usar el @query[sistema de consultas] para averiguar si esa etiqueta existe en la página actual:

```typ
#set page(header: context {
  let matches = query(<big-table>)
  let current = counter(page).get()
  let has-table = matches.any(m =>
    counter(page).at(m.location()) == current
  )

  if not has-table [
    _Lisa Strassner's Thesis_
    #h(1fr)
    National Academy of Sciences
  ]
})

#lorem(100)
#pagebreak()

#table(
  columns: 2 * (1fr,),
  [A], [B],
  [C], [D],
) <big-table>
```

Acá consultamos todas las instancias de la etiqueta `<big-table>`. Luego comprobamos que ninguna de las tablas esté en la página de nuestra posición actual. Si es así, imprimimos el encabezado. Este ejemplo también usa variables para ser más conciso. Igual que arriba, podrías agregar un `else` para agregar otro encabezado en lugar de eliminarlo.

= #short-or-long[Números de página][Agregar y personalizar números de página] <page-numbers>
Los números de página ayudan a los lectores a orientarse en tu documento y a hacer referencia a él más fácilmente. La forma más simple de insertar números de página es el argumento @page.numbering[`numbering`] de la regla set de @page[`{page}`]. Podés pasar una cadena con un @numbering.numbering[_patrón de numeración_] que muestre cómo querés que se numeren tus páginas.

```example
>>> #set page("iso-b6", margin: 1.75cm)
#set page(numbering: "1")

This is a numbered page.
```

Arriba podés ver el ejemplo más simple imaginable. Agrega un único número de página arábigo en el centro del pie de página. Podés especificar otros caracteres distintos de `"1"` para obtener otros numerales. Por ejemplo, `"i"` dará números romanos en minúscula. Cualquier carácter que no se interprete como número se mostrará tal cual. Por ejemplo, poné guiones alrededor de tu número de página escribiendo esto:

```example
>>> #set page("iso-b6", margin: 1.75cm)
#set page(numbering: "— 1 —")

This is a — numbered — page.
```

Podés agregar la cantidad total de páginas ingresando un segundo carácter numérico en la cadena.

```example
>>> #set page("iso-b6", margin: 1.75cm)
#set page(numbering: "1 of 1")

This is one of many numbered pages.
```

Andá a la @numbering.numbering[referencia de la función `{numbering}`] para aprender más sobre los argumentos que podés pasar acá.

Si necesitás alinear el número de página a la derecha o a la izquierda, usá el argumento @page.number-align[`number-align`] de la regla set de @page[`{page}`]. Por ahora no se admite alternar la alineación entre páginas pares e impares con esta propiedad. Para hacerlo, vas a tener que especificar un pie de página personalizado y consultar el contador de páginas, como se describe en la sección sobre cómo omitir condicionalmente encabezados y pies de página.

== Pie de página personalizado con números de página <custom-footer-with-page-numbers>
A veces necesitás agregar a tu pie de página otro contenido además de un número de página. Sin embargo, una vez que se especifica un pie de página, el argumento @page.numbering[`numbering`] de la regla set de @page[`{page}`] se ignora. Esta sección te muestra cómo agregar un pie de página personalizado con números de página y más.

```example
>>> #set page("iso-b6", margin: 1.75cm)
#set page(footer: context [
  *American Society of Proceedings*
  #h(1fr)
  #counter(page).display(
    "1/1",
    both: true,
  )
])

This page has a custom footer.
```

Primero agregamos algo de texto con énfasis fuerte a la izquierda y agregamos espacio libre para llenar la línea. Luego llamamos a `counter(page)` para obtener el contador de páginas y usamos su función `display` para mostrar su valor actual. También establecemos `both` en `{true}` para que nuestro patrón de numeración se aplique al número de página actual _y_ al final.

También podemos ser más creativos con el número de página. Por ejemplo, insertemos un círculo por cada página.

```example
>>> #set page("iso-b6", margin: 1.75cm)
#set page(footer: context [
  *Fun Typography Club*
  #h(1fr)
  #let (num,) = counter(page).get()
  #let circles = num * (
    box(circle(
      radius: 2pt,
      fill: navy,
    )),
  )
  #box(
    inset: (bottom: 1pt),
    circles.join(h(1pt))
  )
])

This page has a custom footer.
```

En este ejemplo, usamos el número de páginas para crear un array de @circle[círculos]. Los círculos están envueltos en un @box[box] para que todos puedan aparecer en la misma línea, ya que son bloques y, de lo contrario, crearían saltos de párrafo. La longitud de este @array[array] depende del número de página actual.

Luego insertamos los círculos en el lado derecho del pie de página, con 1pt de espacio entre ellos. El método join de un array intentará @reference:scripting:blocks[_unir_] los distintos valores de un array en un único valor, intercalado con su argumento. En nuestro caso, obtenemos un único valor de contenido con círculos y espacios entre ellos que podemos usar con la función align. Por último, usamos otro box para asegurarnos de que el texto y los círculos puedan compartir una línea y usamos el @box.inset[argumento `inset`] para subir un poco los círculos y que queden bien alineados con el texto.

== #short-or-long[Saltear páginas][Reiniciar el número de página y saltear páginas] <skip-pages>
¿Necesitás, en algún punto de tu documento, reiniciar el número de página? Quizás querés empezar con la primera página recién después de la portada. O quizás necesitás saltear algunos números de página porque vas a insertar páginas en el producto impreso final.

La forma correcta de modificar el número de página es manipular el @counter[contador] de páginas. La manipulación más simple es volver a poner el contador en 1.

```typ
#counter(page).update(1)
```

Esta línea reiniciará el contador de páginas en uno. Debería ubicarse al comienzo de una página, porque de lo contrario creará un salto de página. También podés actualizar el contador a partir de su valor anterior pasando una función:

```typ
#counter(page).update(n => n + 5)
```

En este ejemplo, salteamos cinco páginas. `n` es el valor actual del contador de páginas y `n + 5` es el valor de retorno de nuestra función.

Si necesitás obtener el número de página real en lugar del valor del contador de páginas, podés usar el método @location.page[`page`] sobre el valor de retorno de la función @here:

```example
#counter(page).update(n => n + 5)

// This returns one even though the
// page counter was incremented by 5.
#context here().page()
```

También podés obtener el patrón de numeración de páginas a partir de la ubicación devuelta por `here` con el método @location.page-numbering[`page-numbering`].

= #short-or-long[Columnas][Agregar columnas] <columns>
Agregá columnas a tu documento para que entre más en una página manteniendo longitudes de línea legibles. Las columnas son bloques verticales de texto separados por algo de espacio en blanco. Este espacio se llama gutter.

Para disponer tu contenido en columnas, simplemente especificá la cantidad de columnas deseada en una regla set de @page.columns[`{page}`]. Para ajustar la cantidad de espacio entre las columnas, agregá una regla set sobre la @columns[función `columns`], especificando el parámetro `gutter`.

```example
>>> #set page(height: 120pt)
#set page(columns: 2)
#set columns(gutter: 12pt)

#lorem(30)
```

Muy comúnmente, los trabajos científicos tienen un título y un resumen a una columna, mientras que el cuerpo principal está compuesto a dos columnas. Para lograr este efecto, la @place[función `place`] de Typst puede salir temporalmente del diseño de dos columnas especificando `{float: true}` y `{scope: "parent"}`:

#example(
  single: true,
  ```
  >>> #set page(height: 180pt)
  >>> #show heading.where(level: 1): set text(size: 0.9em)
  #set document(
    title: [Impacts of Odobenidae],
  )
  #set page(columns: 2)
  #set par(justify: true)

  #place(
    top + center,
    float: true,
    scope: "parent",
    title(),
  )

  = About seals in the wild
  #lorem(80)
  ```
)

La _ubicación flotante_ se refiere a que los elementos se empujan hacia la parte superior o inferior de la columna o de la página, mientras el resto del contenido fluye entremedio. También se usa con frecuencia para las @figure.placement[figuras].

== #short-or-long[Columnas en cualquier lugar][Usar columnas en cualquier parte de tu documento] <columns-anywhere>
Para crear columnas dentro de un diseño anidado, por ejemplo dentro de un rectángulo, podés usar directamente la @columns[función `columns`]. Sin embargo, realmente solo debería usarse dentro de diseños anidados. A nivel de página, es preferible la regla set de page, porque interactúa mejor con cosas como los elementos flotantes de página, las notas al pie y los números de línea.

```example
#rect(
  width: 6cm,
  height: 3.5cm,
  columns(2, gutter: 12pt)[
    In the dimly lit gas station,
    a solitary taxi stood silently,
    its yellow paint fading with
    time. Its windows were dark,
    its engine idle, and its tires
    rested on the cold concrete.
  ]
)
```

== Columnas equilibradas <balanced-columns>
Si las columnas de la última página de un documento difieren mucho en longitud, pueden crear un diseño desparejo y poco atractivo. Por eso los tipógrafos suelen igualar la longitud de las columnas de la última página. Este efecto se llama equilibrar las columnas. Typst todavía no puede equilibrar columnas automáticamente. Sin embargo, podés equilibrarlas manualmente colocando @colbreak[`[#colbreak()]`] en un lugar apropiado de tu marcado, creando a mano el salto de columna deseado.

= Modificaciones puntuales <one-off-modifications>
No necesitás reemplazar la configuración de tu página si necesitás insertar una sola página con una configuración distinta. Por ejemplo, quizás quieras insertar una página girada a horizontal para poner una tabla grande, o cambiar el margen y las columnas de tu portada. En ese caso, podés llamar a @page[`{page}`] como una función con tu contenido como argumento y los reemplazos como los demás argumentos. Esto insertará suficientes páginas nuevas con tu configuración reemplazada para ubicar tu contenido en ellas. Typst volverá a la configuración de página de la regla set después de la llamada.

```example
>>> #set page("a6")
#page(flipped: true)[
  = Multiplication table

  #table(
    columns: 5 * (1fr,),
    ..for x in range(1, 10) {
      for y in range(1, 6) {
        (str(x*y),)
      }
    }
  )
]
```
