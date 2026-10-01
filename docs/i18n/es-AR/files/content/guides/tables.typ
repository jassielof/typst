#import "../../components/index.typ": docs-chapter, short-or-long

#show: docs-chapter.with(
  title: "Guía de tablas",
  route: "/guides/tables",
  description: "¿No sabés cómo cambiar los trazos de una tabla? ¿Necesitás rotar una tabla? Esta guía explica todo lo que necesitás saber sobre tablas en Typst.",
)

Las tablas son una excelente manera de presentarles datos a tus lectores de forma legible, compacta y ordenada. No solo se usan para valores numéricos, sino también para respuestas de encuestas, planificación de tareas, horarios y más. Por esta amplia variedad de aplicaciones posibles, no existe una única mejor forma de diagramar una tabla. En cambio, pensá en los datos que querés destacar, en el diseño general de tu documento y, en última instancia, en cómo puede servirles mejor tu tabla a tus lectores.

¡Typst puede ayudarte con tus tablas automatizando el estilo, importando datos de otras aplicaciones y más! Esta guía repasa algunas de las preguntas más comunes que pueden surgirte al agregar una tabla a tu documento con Typst. Sentite libre de saltar a la sección que más te interese: diseñamos esta guía para que pueda leerse sin seguir el orden.

Si querés consultar algún detalle de cómo funcionan las tablas, también podés @table[revisar su página de referencia]. Y si lo que buscás es un índice de contenidos y no una tabla común, la página de referencia de la @outline[función `outline`] es el lugar indicado para aprender más.

= #short-or-long[Tablas básicas][¿Cómo creo una tabla básica?] <basic-tables>
Para crear una tabla en Typst, usá la @table[función `table`]. Para una tabla básica, tenés que indicarle a la función table dos cosas:

- La cantidad de columnas
- El contenido de cada una de las celdas de la tabla

Entonces, supongamos que querés crear una tabla de dos columnas que describa los ingredientes de una receta de galletitas:

```example
#table(
  columns: 2,
  [*Amount*], [*Ingredient*],
  [360g], [Baking flour],
  [250g], [Butter (room temp.)],
  [150g], [Brown sugar],
  [100g], [Cane sugar],
  [100g], [70% cocoa chocolate],
  [100g], [35-40% cocoa chocolate],
  [2], [Eggs],
  [Pinch], [Salt],
  [Drizzle], [Vanilla extract],
)
```

Este ejemplo muestra cómo llamar, configurar y completar una tabla. Tanto la cantidad de columnas como el contenido de las celdas se le pasan a la tabla como argumentos. La @function[lista de argumentos] va entre paréntesis. Ahí pasamos primero la cantidad de columnas como argumento con nombre. Después pasamos varios @content[bloques de contenido] como argumentos posicionales. Cada bloque de contenido contiene el contenido de una sola celda.

Para que el ejemplo sea más legible, pusimos dos argumentos de bloque de contenido por línea, imitando cómo aparecerían en la tabla. También podrías escribir cada celda en su propia línea. A Typst no le importa en qué línea pongas los argumentos. En cambio, Typst va a ubicar las celdas de contenido de izquierda a derecha (o de derecha a izquierda, si esa es la dirección de escritura de tu idioma) y luego de arriba hacia abajo. Agrega automáticamente las filas necesarias para que quepa todo tu contenido.

Lo mejor es envolver la fila de encabezado de tu tabla en la @table.header[función `table.header`]. Esto aclara tu intención y además le permite a Typst hacer que el resultado sea más @guides:accessibility[accesible] para usuarios de lectores de pantalla:

```example
#table(
  columns: 2,
  table.header[*Amount*][*Ingredient*],
  [360g], [Baking flour],
<<<  // ... the remaining cells
>>>  [250g], [Butter (room temp.)],
>>>  [150g], [Brown sugar],
>>>  [100g], [Cane sugar],
>>>  [100g], [70% cocoa chocolate],
>>>  [100g], [35-40% cocoa chocolate],
>>>  [2], [Eggs],
>>>  [Pinch], [Salt],
>>>  [Drizzle], [Vanilla extract],
)
```

También podrías escribir una regla show que ponga automáticamente en @strong[énfasis fuerte] el contenido de las primeras celdas de todas las tablas. ¡Esto se vuelve útil enseguida si tu documento contiene varias tablas!

```example
#show table.cell.where(y: 0): strong

#table(
  columns: 2,
  table.header[Amount][Ingredient],
  [360g], [Baking flour],
<<<  // ... the remaining cells
>>>  [250g], [Butter (room temp.)],
>>>  [150g], [Brown sugar],
>>>  [100g], [Cane sugar],
>>>  [100g], [70% cocoa chocolate],
>>>  [100g], [35-40% cocoa chocolate],
>>>  [2], [Eggs],
>>>  [Pinch], [Salt],
>>>  [Drizzle], [Vanilla extract],
)
```

Acá usamos una regla show con un selector por coordenadas de celda en lugar de aplicar nuestros estilos directamente a `table.header`. Esto se debe a una limitación actual de Typst que se va a corregir en una versión futura.

¡Felicitaciones, creaste tu primera tabla! Ahora podés pasar a @guides:tables:column-sizes[cambiar el tamaño de las columnas], @guides:tables:strokes[ajustar los trazos], @guides:tables:fills[agregar filas alternadas] y más.

= #short-or-long[Tamaños de columna][¿Cómo cambio el tamaño de las columnas?] <column-sizes>
Si creás una tabla y especificás la cantidad de columnas, Typst hace cada columna lo bastante ancha para que quepa su celda más grande. Muchas veces querés algo distinto, por ejemplo, que la tabla ocupe todo el ancho de la página. Podés pasar una lista con el ancho de cada columna mediante el argumento `columns`. Hay varias formas de especificar los anchos de columna:

- Primero, está `{auto}`. Es el comportamiento predeterminado e indica a Typst que haga crecer la columna para que entre su contenido. Si no hay espacio suficiente, Typst hace lo posible por repartir el espacio entre las columnas de tamaño `{auto}`.
- @length[Longitudes] como `{6cm}`, `{0.7in}` o `{120pt}`. Como siempre, también podés usar la unidad `em`, que depende de la fuente y es un múltiplo del tamaño de fuente actual. Es útil si querés dimensionar tu tabla para que siempre entre aproximadamente la misma cantidad de texto, sin importar el tamaño de la fuente.
- Una @ratio[proporción en porcentaje], como `{40%}`. Esto hace que la columna ocupe el 40 % del espacio horizontal total disponible para la tabla, es decir, el ancho interior de la página o del contenedor de la tabla. También podés combinar proporciones y longitudes en @relative[longitudes relativas]. Tené en cuenta que, aunque especifiques una lista de anchos de columna que sume 100 %, tu tabla igualmente podría ser más grande que su contenedor. Esto se debe a que puede haber @table.gutter[separación] entre columnas que no está incluida en los anchos de columna. Si querés que una tabla ocupe toda la página, la siguiente opción suele ser muy útil.
- Una @fraction[fracción del espacio libre] con la unidad `fr`, como `1fr`. Esta unidad te permite repartir el espacio disponible entre las columnas. Funciona así: primero, Typst suma las longitudes de todas las columnas que no usan `fr`. Luego determina cuánto espacio horizontal queda. Ese espacio horizontal se reparte entre todas las columnas expresadas en `fr`. En este proceso, una columna de `2fr` va a ser el doble de ancha que una de `1fr`. De ahí viene el nombre: el ancho de la columna es su fracción del total de columnas de tamaño fraccionario.

Pongamos esto en práctica con una tabla que contiene las fechas, los números y las descripciones de algunos controles de rutina. Las dos primeras columnas son de tamaño `auto` y la última es de `1fr` para que ocupe toda la página.

```example
#table(
  columns: (auto, auto, 1fr),
  table.header[Date][°No][Description],
  [24/01/03], [813], [Filtered participant pool],
  [24/01/03], [477], [Transitioned to sec. regimen],
  [24/01/11], [051], [Cycled treatment substrate],
)
```

Acá pasamos nuestra lista de longitudes de columna como un @array[array], encerrado entre paréntesis y con sus elementos separados por comas. Las dos primeras columnas tienen tamaño automático, de modo que toman el tamaño de su contenido, y la tercera es `{1fr}` para que ocupe el resto del espacio de la página. Si en cambio quisieras que la segunda columna fuera un poco más espaciosa, podrías reemplazar su entrada en el array `columns` por un valor como `{6em}`.

= #short-or-long[Epígrafes y referencias][¿Cómo le pongo epígrafe a mi tabla y la referencio?] <captions-and-references>
Una tabla vale tanto como la información que tus lectores extraen de ella. Podés mejorar la eficacia tanto de tu texto como de tu tabla estableciendo una conexión clara entre ambos con una referencia cruzada. Typst puede ayudarte con las @ref[referencias] automáticas y con la @figure[función `figure`].

Igual que con las imágenes, envolver una tabla en la función `figure` te permite agregarle un epígrafe y una etiqueta, para poder referenciar la figura en otro lugar. Envolver tu tabla en una figura también te permite usar el parámetro `placement` de la figura para hacerla flotar en la parte superior o inferior de una página.

Veamos una tabla con epígrafe y cómo referenciarla en el texto:

```example
>>> #set page(width: 14cm)
#show table.cell.where(y: 0): set text(weight: "bold")

#figure(
  table(
    columns: 4,
    stroke: none,

    table.header[Test Item][Specification][Test Result][Compliance],
    [Voltage], [220V ± 5%], [218V], [Pass],
    [Current], [5A ± 0.5A], [4.2A], [Fail],
  ),
  caption: [Probe results for design A],
) <probe-a>

The results from @probe-a show that the design is not yet optimal.
We will show how its performance can be improved in this section.
```

El ejemplo muestra cómo envolver una tabla en una figura, definir un epígrafe y una etiqueta, y cómo referenciar esa etiqueta. Empezamos usando la función `figure`, que espera el contenido de la figura como argumento posicional. Simplemente ponemos la llamada a la función table en su lista de argumentos, omitiendo el carácter `#` porque solo hace falta al llamar a una función en modo de marcado. También agregamos el epígrafe como argumento con nombre (arriba o abajo) de la tabla.

Después de la llamada a figure, ponemos una etiqueta entre paréntesis angulares (`[<probe-a>]`). Esto le indica a Typst que recuerde este elemento y lo haga referenciable con ese nombre en todo tu documento. Después podemos referenciarlo en el texto usando la arroba y el nombre de la etiqueta, `[@probe-a]`. Typst imprime una referencia bien formateada y la actualiza automáticamente si cambia el número de la tabla.

= #short-or-long[Rellenos][¿Cómo hago una tabla con filas alternadas?] <fills>
Muchas tablas usan filas o columnas alternadas en lugar de trazos para diferenciar unas de otras. Este efecto suele llamarse _rayas de cebra._ Las tablas con rayas de cebra son populares en aplicaciones empresariales, comerciales y de análisis de datos, mientras que las aplicaciones académicas tienden a usar trazos.

Para agregarle rayas de cebra a una tabla, usamos el argumento `fill` de la función `table`. Puede recibir tres tipos de valores:

- Un solo color (también puede ser un degradé o un mosaico) con el que se rellenan todas las celdas. Como queremos que algunas celdas tengan otro color, esto no sirve si queremos armar tablas cebra.
- Un array de colores por los que Typst cicla en cada columna. Podemos usar un array de dos elementos para obtener columnas alternadas.
- Una función que recibe la coordenada horizontal `x` y la coordenada vertical `y` de una celda y devuelve su relleno. Podemos usarla para crear rayas horizontales o @grid.cell[patrones de tablero de ajedrez].

Empecemos con un ejemplo de una tabla con rayas horizontales:

```example
>>> #set page(width: 16cm)
#set text(font: "IBM Plex Sans")

// Medium bold table header.
#show table.cell.where(y: 0): set text(weight: "medium")

// Bold titles.
#show table.cell.where(x: 1): set text(weight: "bold")

// See the strokes section for details on this!
#let frame(stroke) = (x, y) => (
  left: if x > 0 { 0pt } else { stroke },
  right: stroke,
  top: if y < 2 { stroke } else { 0pt },
  bottom: stroke,
)

#set table(
  fill: (rgb("EAF2F5"), none),
  stroke: frame(1pt + rgb("21222C")),
)

#table(
  columns: (0.4fr, 1fr, 1fr, 1fr),

  table.header[Month][Title][Author][Genre],
  [January], [The Great Gatsby], [F. Scott Fitzgerald], [Classic],
  [February], [To Kill a Mockingbird], [Harper Lee], [Drama],
  [March], [1984], [George Orwell], [Dystopian],
  [April], [The Catcher in the Rye], [J.D. Salinger], [Coming-of-Age],
)
```

Este ejemplo muestra la lista de lecturas de un club de lectura. La línea `{fill: (rgb("EAF2F5"),  none)}` en la regla set de `table` es todo lo que hace falta para agregar columnas alternadas. Le indica a Typst que alterne entre colorear las columnas con un celeste claro (en la llamada a la función @color.rgb[`rgb`]) y nada (`{none}`). Fijate que sacamos todo el estilo de la llamada a la función `table` y lo pusimos en reglas set y show, para poder reutilizarlo automáticamente en varias tablas.

Como configurar las rayas en sí es fácil, agregamos también otros estilos para que se vea bien. El resto del código del ejemplo dibuja un @guides:tables:stroke-functions[trazo] azul oscuro alrededor de la tabla y debajo de la primera línea, y pone en negrita la primera fila y la columna con el título del libro. Mirá la sección de @guides:tables:strokes[trazos] para ver los detalles de cómo logramos esta configuración.

A continuación veamos cómo cambiar solo la regla set para lograr en cambio rayas horizontales:

```example
>>> #set page(width: 16cm)
>>> #set text(font: "IBM Plex Sans")
>>> #show table.cell.where(x: 1): set text(weight: "medium")
>>> #show table.cell.where(y: 0): set text(weight: "bold")
>>>
>>> #let frame(stroke) = (x, y) => (
>>>   left: if x > 0 { 0pt } else { stroke },
>>>   right: stroke,
>>>   top: if y < 2 { stroke } else { 0pt },
>>>   bottom: stroke,
>>> )
>>>
#set table(
  fill: (_, y) => if calc.odd(y) { rgb("EAF2F5") },
  stroke: frame(1pt + rgb("21222C")),
)
>>>
>>> #table(
>>>   columns: (0.4fr, 1fr, 1fr, 1fr),
>>>
>>>   table.header[Month][Title][Author][Genre],
>>>   [January], [The Great Gatsby],
>>>     [F. Scott Fitzgerald], [Classic],
>>>   [February], [To Kill a Mockingbird],
>>>     [Harper Lee], [Drama],
>>>   [March], [1984],
>>>     [George Orwell], [Dystopian],
>>>   [April], [The Catcher in the Rye],
>>>     [J.D. Salinger], [Coming-of-Age],
>>> )
```

Solo tenemos que reemplazar la regla set del ejemplo anterior por esta para obtener rayas horizontales. Acá le pasamos una función a `fill`. Descarta la coordenada horizontal con un guion bajo y luego comprueba si la coordenada vertical `y` de la celda es impar. Si lo es, la celda recibe un relleno celeste claro; si no, no se devuelve ningún relleno.

Por supuesto, podés hacer esta función tan compleja como quieras. Por ejemplo, si querés alternar las filas con un tono de azul claro y otro más oscuro, podrías hacer algo así:

```example
>>> #set page(width: 16cm)
>>> #set text(font: "IBM Plex Sans")
>>> #show table.cell.where(x: 1): set text(weight: "medium")
>>> #show table.cell.where(y: 0): set text(weight: "bold")
>>>
>>> #let frame(stroke) = (x, y) => (
>>>   left: if x > 0 { 0pt } else { stroke },
>>>   right: stroke,
>>>   top: if y < 2 { stroke } else { 0pt },
>>>   bottom: stroke,
>>> )
>>>
#set table(
  fill: (_, y) => (none, rgb("EAF2F5"), rgb("DDEAEF")).at(calc.rem(y, 3)),
  stroke: frame(1pt + rgb("21222C")),
)
>>>
>>> #table(
>>>   columns: (0.4fr, 1fr, 1fr, 1fr),
>>>
>>>   table.header[Month][Title][Author][Genre],
>>>   [January], [The Great Gatsby],
>>>     [F. Scott Fitzgerald], [Classic],
>>>   [February], [To Kill a Mockingbird],
>>>     [Harper Lee], [Drama],
>>>   [March], [1984],
>>>     [George Orwell], [Dystopian],
>>>   [April], [The Catcher in the Rye],
>>>     [J.D. Salinger], [Coming-of-Age],
>>> )
```

Este ejemplo muestra una forma alternativa de escribir nuestra función de relleno. La función usa un array con tres colores y cicla entre sus valores en cada fila indexando el array con el resto de dividir `y` por 3.

Por último, un ejemplo extra que usa el _trazo_ para lograr filas alternadas:

```example
>>> #set page(width: 16cm)
>>> #set text(font: "IBM Plex Sans")
>>> #show table.cell.where(x: 1): set text(weight: "medium")
>>> #show table.cell.where(y: 0): set text(weight: "bold")
>>>
>>> #let frame(stroke) = (x, y) => (
>>>   left: if x > 0 { 0pt } else { stroke },
>>>   right: stroke,
>>>   top: if y < 2 { stroke } else { 0pt },
>>>   bottom: stroke,
>>> )
>>>
#set table(
  stroke: (x, y) => (
    y: 1pt,
    left: if x > 0 { 0pt } else if calc.even(y) { 1pt },
    right: if calc.even(y) { 1pt },
  ),
)
>>>
>>> #table(
>>>   columns: (0.4fr, 1fr, 1fr, 1fr),
>>>
>>>   table.header[Month][Title][Author][Genre],
>>>   [January], [The Great Gatsby],
>>>     [F. Scott Fitzgerald], [Classic],
>>>   [February], [To Kill a Mockingbird],
>>>     [Harper Lee], [Drama],
>>>   [March], [1984],
>>>     [George Orwell], [Dystopian],
>>>   [April], [The Catcher in the Rye],
>>>     [J.D. Salinger], [Coming-of-Age],
>>> )
```

== #short-or-long[Relleno personalizado][Cómo sobrescribir manualmente el color de relleno de una celda] <fill-override>
A veces, el relleno de una celda no tiene que variar según su posición en la tabla, sino según su contenido. Podemos usar el @table.cell[elemento `table.cell`] en la lista de parámetros de `table` para envolver el contenido de una celda y sobrescribir su relleno.

Por ejemplo, esta es una lista de todos los presidentes de Alemania, con los bordes de las celdas coloreados con el color de su partido.

```example
>>> #set page(width: 10cm)
#set text(font: "Roboto")

#let cdu(name) = ([CDU], table.cell(fill: black, text(fill: white, name)))
#let spd(name) = ([SPD], table.cell(fill: red, text(fill: white, name)))
#let fdp(name) = ([FDP], table.cell(fill: yellow, name))

#table(
  columns: (auto, auto, 1fr),
  stroke: (x: none),

  table.header[Tenure][Party][President],
  [1949-1959], ..fdp[Theodor Heuss],
  [1959-1969], ..cdu[Heinrich Lübke],
  [1969-1974], ..spd[Gustav Heinemann],
  [1974-1979], ..fdp[Walter Scheel],
  [1979-1984], ..cdu[Karl Carstens],
  [1984-1994], ..cdu[Richard von Weizsäcker],
  [1994-1999], ..cdu[Roman Herzog],
  [1999-2004], ..spd[Johannes Rau],
  [2004-2010], ..cdu[Horst Köhler],
  [2010-2012], ..cdu[Christian Wulff],
  [2012-2017], [n/a], [Joachim Gauck],
  [2017-],     ..spd[Frank-Walter-Steinmeier],
)
```

En este ejemplo usamos variables porque solo hubo tres partidos cuyos miembros llegaron a ser presidentes (y un presidente independiente). Sus colores se repiten varias veces, así que guardamos una función que produce un array con el nombre del partido y una celda de tabla con el color de ese partido y el nombre del presidente (`cdu`, `spd` y `fdp`). Después usamos estas funciones en la lista de argumentos de `table` en lugar de agregar directamente el nombre. Usamos el @arguments:spreading[operador spread] `..` para convertir los elementos de los arrays en celdas individuales. También podríamos escribir algo como `{[FDP], table.cell(fill: yellow)[Theodor Heuss]}` para cada celda directamente en la lista de argumentos de `table`, pero se vuelve ilegible, sobre todo para los partidos con colores oscuros, que requieren texto blanco. También eliminamos los trazos verticales y configuramos la fuente en Roboto.

La columna del partido y el color de la celda comunican información redundante a propósito: comunicar datos importantes solo con color es una mala práctica de accesibilidad. Perjudica a los usuarios con discapacidad visual y viola los estándares de acceso universal, como el #link("https://www.w3.org/WAI/WCAG21/Understanding/use-of-color.html")[criterio de éxito 1.4.1 de WCAG 2.1]. Para mejorar esta tabla, agregamos una columna que imprime el nombre del partido. Como alternativa, podrías haber elegido una paleta amigable para el daltonismo y marcado tus celdas con una etiqueta adicional que los lectores de pantalla puedan leer en voz alta. Esta última función todavía no está soportada por Typst, pero se va a agregar en una versión futura. Podés comprobar cómo se ven los colores para lectores daltónicos con #link("https://chromewebstore.google.com/detail/colorblindly/floniaahmccleoclneebhhmnjgdfijgg")[esta extensión de Chrome], #link("https://helpx.adobe.com/photoshop/using/proofing-colors.html")[Photoshop] o #link("https://docs.gimp.org/2.10/en/gimp-display-filter-dialog.html")[GIMP].

= #short-or-long[Trazos][¿Cómo ajusto las líneas de una tabla?] <strokes>
De forma predeterminada, Typst agrega trazos entre cada fila y columna de una tabla. Podés ajustarlos de varias maneras. La más práctica depende de la modificación que quieras hacer y de tu intención:

- ¿Querés darles estilo a todas las tablas de tu documento, sin importar su tamaño y contenido? Usá el argumento @table.stroke[stroke] de la función `table` en una regla set.
- ¿Querés personalizar todas las líneas de una sola tabla? Usá el argumento @table.stroke[stroke] de la función `table` al llamarla.
- ¿Querés cambiar, agregar o quitar el trazo alrededor de una sola celda? Usá el elemento `table.cell` en la lista de argumentos de tu llamada a table.
- ¿Querés cambiar, agregar o quitar una única línea horizontal o vertical en una sola tabla? Usá los elementos @table.hline y @table.vline en la lista de argumentos de tu llamada a table.

¡A continuación vamos a repasar todas estas opciones con ejemplos! Primero nos ocupamos del argumento @table.stroke[stroke] de la función `table`. Ahí podés ajustar tanto cómo se dibujan las líneas de la tabla como cuáles se dibujan.

Empecemos modificando el color y el grosor del trazo:

```example
#table(
  columns: 4,
  stroke: 0.5pt + rgb("666675"),
  [*Monday*], [11.5], [13.0], [4.0],
  [*Tuesday*], [8.0], [14.5], [5.0],
  [*Wednesday*], [9.0], [18.5], [13.0],
)
```

Esto hace que las líneas de la tabla sean un poco más finas y usa un gris azulado. Podés ver que le sumamos un ancho en puntos a un color para lograr nuestro trazo personalizado. Esta suma da como resultado un valor del @stroke[tipo trazo]. Como alternativa, podés usar la representación como diccionario para los trazos, que te da acceso a funciones avanzadas como las líneas punteadas.

El ejemplo anterior mostró cómo usar el argumento stroke en la invocación de la función table. Como alternativa, podés especificar el argumento stroke en la regla set de `table`. Esto tiene exactamente el mismo efecto en todas las llamadas posteriores a `table` que si el argumento se hubiera especificado en la lista de argumentos. Es útil si estás escribiendo una plantilla o querés darle estilo a todo tu documento.

```typ
// Renders the exact same as the last example
#set table(stroke: 0.5pt + rgb("666675"))

#table(
  columns: 4,
  [*Monday*], [11.5], [13.0], [4.0],
  [*Tuesday*], [8.0], [14.5], [5.0],
  [*Wednesday*], [9.0], [18.5], [13.0],
)
```

En las tablas chicas, a veces querés suprimir todos los trazos porque agregan demasiado ruido visual. Para eso, simplemente poné el argumento stroke en `{none}`:

```example
#table(
  columns: 4,
  stroke: none,
  [*Monday*], [11.5], [13.0], [4.0],
  [*Tuesday*], [8.0], [14.5], [5.0],
  [*Wednesday*], [9.0], [18.5], [13.0],
)
```

Si querés un control más fino de dónde se colocan las líneas de tu tabla, también podés pasar un diccionario con las claves `top`, `left`, `right`, `bottom` (que controlan los lados respectivos de la celda), `x`, `y` (que controlan los trazos verticales y horizontales) y `rest` (que abarca todos los trazos a los que no les dio estilo otra entrada del diccionario). Todas las claves son opcionales; las claves omitidas usan el valor establecido anteriormente o el valor predeterminado si nunca se estableció. Por ejemplo, para obtener una tabla con solo líneas horizontales, podés hacer esto:

```example
#table(
  columns: 2,
  stroke: (x: none),
  align: horizon,
  [☒], [Close cabin door],
  [☐], [Start engines],
  [☐], [Radio tower],
  [☐], [Push back],
)
```

Esto desactiva todos los trazos verticales y deja los horizontales. Para lograr el efecto inverso (solo trazos verticales), poné en cambio el argumento stroke en `{(y: none)}`.

@guides:tables:stroke-functions[Más adelante en la guía] vemos cómo usar una función en el argumento stroke para personalizar todos los trazos individualmente. Así se logran patrones de trazos más complejos.

== #short-or-long[Líneas individuales][Cómo agregar líneas individuales en la tabla] <individual-lines>
Si querés agregar una única línea horizontal o vertical a tu tabla, por ejemplo para separar un grupo de filas, podés usar los elementos @table.hline y @table.vline para líneas horizontales y verticales, respectivamente. Agregalos a la lista de argumentos de la función `table` igual que agregarías celdas individuales y un encabezado.

Veamos el siguiente ejemplo de la referencia:

```example
#set table.hline(stroke: 0.6pt)

#table(
  stroke: none,
  columns: (auto, 1fr),
  // Morning schedule abridged.
  [14:00], [Talk: Tracked Layout],
  [15:00], [Talk: Automations],
  [16:00], [Workshop: Tables],
  table.hline(),
  [19:00], [Day 1 Attendee Mixer],
)
```

En este ejemplo podés ver que pusimos una llamada a `table.hline` entre las celdas, lo que produce una línea horizontal en ese lugar. También usamos una regla set sobre el elemento para reducir el grosor de su trazo y que combine mejor con el peso de la fuente.

De forma predeterminada, Typst coloca las líneas horizontales y verticales después de la fila o columna actual, según su posición en la lista de argumentos. También podés moverlas manualmente a otra posición agregando el argumento `y` (para `hline`) o `x` (para `vline`). Por ejemplo, el siguiente código produciría el mismo resultado:

```typ
#set table.hline(stroke: 0.6pt)

#table(
  stroke: none,
  columns: (auto, 1fr),
  // Morning schedule abridged.
  table.hline(y: 3),
  [14:00], [Talk: Tracked Layout],
  [15:00], [Talk: Automations],
  [16:00], [Workshop: Tables],
  [19:00], [Day 1 Attendee Mixer],
)
```

Imaginemos que trabajás con una plantilla que no muestra ningún trazo de tabla salvo uno entre la primera y la segunda fila. Ahora bien, como tenés una tabla que además tiene etiquetas en la primera columna, querés agregarle una línea vertical extra. Sin embargo, no querés que esa línea vertical cruce la fila superior. Podés lograrlo con el argumento `start`:

```example
>>> #set page(width: 12cm)
>>> #show table.cell.where(y: 0): strong
>>> #set table(stroke: (_, y) => if y == 0 { (bottom: 1pt) })
// Base template already configured tables, but we need some
// extra configuration for this table.
#{
  set table(align: (x, _) => if x == 0 { left } else { right })
  show table.cell.where(x: 0): smallcaps
  table(
    columns: (auto, 1fr, 1fr, 1fr),
    table.vline(x: 1, start: 1),
    table.header[Trainset][Top Speed][Length][Weight],
    [TGV Réseau], [320 km/h], [200m], [383t],
    [ICE 403], [330 km/h], [201m], [409t],
    [Shinkansen N700], [300 km/h], [405m], [700t],
  )
}
```

En este ejemplo agregamos `table.vline` al comienzo de nuestra lista de argumentos posicionales. Pero como la línea no tiene que ir a la izquierda de la primera columna, especificamos el argumento `x` como `{1}`. También configuramos el argumento `start` en `{1}` para que la línea empiece recién después de la primera fila.

El ejemplo también contiene dos cosas más: usamos el argumento align con una función para alinear a la derecha los datos de todas las columnas salvo la primera, y usamos una regla show para que la primera columna de celdas aparezca en versalitas. Como estos estilos son específicos de esta tabla, ponemos todo en un @reference:scripting:blocks[bloque de código], para que el estilo no afecte a otras tablas.

== #short-or-long[Trazo personalizado][Cómo sobrescribir los trazos de una sola celda] <stroke-override>
Imaginá que querés cambiar el trazo alrededor de una sola celda. ¡Quizás tu celda es muy importante y necesita destacarse! Para este caso existe la @table.cell[función `table.cell`]. En lugar de agregar tu contenido directamente en la lista de argumentos de la tabla, lo envolvés en una llamada a `table.cell`. Ahora podés usar la lista de argumentos de `table.cell` para sobrescribir las propiedades de la tabla, como el trazo, solo para esa celda.

Este es un ejemplo con una matriz de dos de los cinco grandes factores de personalidad, con una intersección resaltada.

```example
>>> #set page(width: 16cm)
#table(
  columns: 3,
  stroke: (x: none),

  table.header[][*High Neuroticism*][*Low Neuroticism*],

  [*High Agreeableness*],
  table.cell(stroke: orange + 2pt)[
    _Sensitive_ \ Prone to emotional distress but very empathetic.
  ],
  [_Compassionate_ \ Caring and stable, often seen as a supportive figure.],

  [*Low Agreeableness*],
  [_Contentious_ \ Competitive and easily agitated.],
  [_Detached_ \ Independent and calm, may appear aloof.],
)
```

Arriba podés ver que usamos el elemento `table.cell` en la lista de argumentos de la tabla y le pasamos el contenido de la celda. Usamos su argumento `stroke` para establecer un trazo naranja más ancho. A pesar de que desactivamos los trazos verticales de la tabla, el trazo naranja apareció en todos los lados de la celda modificada, lo que muestra que la configuración de trazos de la tabla fue sobrescrita.

== #short-or-long[Funciones de trazo][Personalización compleja de trazos para todo el documento] <stroke-functions>
Esta sección explica cómo personalizar todas las líneas a la vez en una o varias tablas. Esto te permite dibujar solo la primera línea horizontal u omitir las líneas exteriores, sin saber cuántas celdas tiene la tabla. Se logra pasando una función al parámetro `stroke` de la tabla. La función debería devolver un trazo dadas las posiciones x e y (desde cero) de la celda actual. Solo deberías necesitar estas funciones si sos autor de plantillas, no usás una plantilla o necesitás personalizar mucho tus tablas. En los demás casos, tu plantilla debería establecer trazos de tabla predeterminados adecuados.

Por ejemplo, esta es una regla set que dibuja todas las líneas horizontales salvo la primera y la última.

```example
#show table.cell.where(x: 0): set text(style: "italic")
#show table.cell.where(y: 0): set text(style: "normal", weight: "bold")
#set table(stroke: (_, y) => if y > 0 { (top: 0.8pt) })

#table(
  columns: 3,
  align: center + horizon,
  table.header[Technique][Advantage][Drawback],
  [Diegetic], [Immersive], [May be contrived],
  [Extradiegetic], [Breaks immersion], [Obtrusive],
  [Omitted], [Fosters engagement], [May fracture audience],
)
```

En la regla set pasamos una función que recibe dos argumentos, asigna la coordenada vertical a `y` y descarta la coordenada horizontal. Luego devuelve un diccionario de trazo con un trazo superior de `{0.8pt}` para todas las líneas menos la primera. Las celdas de la primera línea reciben en cambio `{none}` implícitamente como valor de retorno. Podés modificar fácilmente esta función para dibujar solo las líneas verticales interiores, así: `{(x, _) => if x > 0 { (left: 0.8pt) }}`.

Probemos algunas funciones de trazo más. La siguiente solo dibuja una línea debajo de la primera fila:

```example
>>> #show table.cell: it => if it.x == 0 and it.y > 0 {
>>>   set text(style: "italic")
>>>   it
>>> } else {
>>>   it
>>> }
>>>
>>> #show table.cell.where(y: 0): strong
#set table(stroke: (_, y) => if y == 0 { (bottom: 1pt) })

<<< // Table as seen above
>>> #table(
>>>   columns: 3,
>>>   align: center + horizon,
>>>   table.header[Technique][Advantage][Drawback],
>>>   [Diegetic], [Immersive], [May be contrived],
>>>   [Extradiegetic], [Breaks immersion], [Obtrusive],
>>>   [Omitted], [Fosters engagement], [May fracture audience],
>>> )
```

Si entendiste el primer ejemplo, lo que pasa acá resulta obvio. Comprobamos si estamos en la primera fila. Si es así, devolvemos un trazo inferior. De lo contrario, devolvemos `{none}` implícitamente.

El siguiente ejemplo muestra cómo dibujar todas las líneas salvo las exteriores:

```example
>>> #show table.cell: it => if it.x == 0 and it.y > 0 {
>>>   set text(style: "italic")
>>>   it
>>> } else {
>>>   it
>>> }
>>>
>>> #show table.cell.where(y: 0): strong
#set table(stroke: (x, y) => (
  left: if x > 0 { 0.8pt },
  top: if y > 0 { 0.8pt },
))

<<< // Table as seen above
>>> #table(
>>>   columns: 3,
>>>   align: center + horizon,
>>>   table.header[Technique][Advantage][Drawback],
>>>   [Diegetic], [Immersive], [May be contrived],
>>>   [Extradiegetic], [Breaks immersion], [Obtrusive],
>>>   [Omitted], [Fosters engagement], [May fracture audience],
>>> )
```

Este ejemplo usa las coordenadas `x` e `y`. Omite el trazo izquierdo en la primera columna y el trazo superior en la primera fila. Las líneas derecha e inferior no se dibujan.

Por último, esta es una tabla que dibuja todas las líneas salvo las verticales de la primera fila y las horizontales del cuerpo de la tabla. Se parece un poco a un calendario.

```example
>>> #show table.cell: it => if it.x == 0 and it.y > 0 {
>>>   set text(style: "italic")
>>>   it
>>> } else {
>>>   it
>>> }
>>>
>>> #show table.cell.where(y: 0): strong
#set table(stroke: (x, y) => (
  left: if x == 0 or y > 0 { 1pt } else { 0pt },
  right: 1pt,
  top: if y <= 1 { 1pt } else { 0pt },
  bottom: 1pt,
))

<<< // Table as seen above
>>> #table(
>>>   columns: 3,
>>>   align: center + horizon,
>>>   table.header[Technique][Advantage][Drawback],
>>>   [Diegetic], [Immersive], [May be contrived],
>>>   [Extradiegetic], [Breaks immersion], [Obtrusive],
>>>   [Omitted], [Fosters engagement], [May fracture audience],
>>> )
```

Este ejemplo es un poco más complejo. Empezamos dibujando todos los trazos a la derecha de las celdas. Pero eso significa que también dibujamos trazos en la fila superior, ¡y no los necesitamos! Aprovechamos que `left` sobrescribe a `right` y solo dibujamos la línea izquierda si no estamos en la primera fila o si estamos en la primera columna. En todos los demás casos, quitamos explícitamente la línea izquierda. Por último, dibujamos las líneas horizontales estableciendo primero la línea inferior y después, con la clave `top`, las primeras dos filas, suprimiendo todas las demás líneas superiores. La última línea aparece porque no hay ninguna línea `top` que pueda suprimirla.

== #short-or-long[Trazo doble][¿Cómo logro una línea doble?] <double-stroke>
Typst todavía no tiene una forma nativa de dibujar trazos dobles, pero hay varias maneras de emularlos, por ejemplo con @tiling[mosaicos]. En esta sección mostramos otra solución alternativa: la separación entre celdas de la tabla.

Las tablas pueden separar sus celdas con el argumento `gutter`. Cuando se aplica una separación, se dibuja un trazo en cada una de las celdas ahora separadas. Podemos agregar separación de forma selectiva entre las filas o columnas en las que queremos dibujar una línea doble. Los argumentos `row-gutter` y `column-gutter` nos permiten hacerlo. Aceptan arrays de valores de separación. Veamos un ejemplo:

```example
#table(
  columns: 3,
  stroke: (x: none),
  row-gutter: (2.2pt, auto),
  table.header[Date][Exercise Type][Calories Burned],
  [2023-03-15], [Swimming], [400],
  [2023-03-17], [Weightlifting], [250],
  [2023-03-18], [Yoga], [200],
)
```

Vemos que usamos un array para `row-gutter` que especifica un espacio de `{2.2pt}` entre la primera y la segunda fila. Luego continúa con `auto` (que es el valor predeterminado, en este caso una separación de `{0pt}`), que será la separación entre todas las demás filas, ya que es la última entrada del array.

= #short-or-long[Alineación][¿Cómo alineo el contenido de las celdas de mi tabla?] <alignment>
Podés usar varios mecanismos para alinear el contenido de tu tabla. Podés usar el argumento `align` de la función `table` para establecer la alineación de toda la tabla (o usarlo en una regla set para establecerla en las tablas de todo tu documento), o bien la función @align (o el argumento `align` de `table.cell`) para sobrescribir la alineación de una sola celda.

Al usar el argumento align de la función `table`, podés elegir entre tres métodos para especificar una @alignment[alineación]:

- Simplemente especificar una única alineación, como `right` (alinea en la esquina superior derecha) o `center + horizon` (centra todo el contenido de las celdas). Esto cambia la alineación de todas las celdas.
- Proporcionar un array. Typst cicla por este array en cada columna.
- Proporcionar una función a la que se le pasan las coordenadas horizontal `x` y vertical `y` de una celda y que devuelve una alineación.

Por ejemplo, este itinerario de viaje alinea a la derecha la columna del día y a la izquierda todo lo demás, proporcionando un array en el argumento `align`:

```example
>>> #set page(width: 12cm)
#set text(font: "IBM Plex Sans")
#show table.cell.where(y: 0): set text(weight: "bold")

#table(
  columns: 4,
  align: (right, left, left, left),
  fill: (_, y) => if calc.odd(y) { green.lighten(90%) },
  stroke: none,

  table.header[Day][Location][Hotel or Apartment][Activities],
  [1], [Paris, France], [Hôtel de l'Europe], [Arrival, Evening River Cruise],
  [2], [Paris, France], [Hôtel de l'Europe], [Louvre Museum, Eiffel Tower],
  [3], [Lyon, France], [Lyon City Hotel], [City Tour, Local Cuisine Tasting],
  [4], [Geneva, Switzerland], [Lakeview Inn], [Lake Geneva, Red Cross Museum],
  [5], [Zermatt, Switzerland], [Alpine Lodge], [Visit Matterhorn, Skiing],
)
```

Sin embargo, este ejemplo todavía no se ve perfecto: las celdas del encabezado deberían estar alineadas abajo. Usemos una función para lograrlo:

```example
>>> #set page(width: 12cm)
#set text(font: "IBM Plex Sans")
#show table.cell.where(y: 0): set text(weight: "bold")

#table(
  columns: 4,
  align: (x, y) =>
    if x == 0 { right } else { left } +
    if y == 0 { bottom } else { top },
  fill: (_, y) => if calc.odd(y) { green.lighten(90%) },
  stroke: none,

  table.header[Day][Location][Hotel or Apartment][Activities],
  [1], [Paris, France], [Hôtel de l'Europe], [Arrival, Evening River Cruise],
  [2], [Paris, France], [Hôtel de l'Europe], [Louvre Museum, Eiffel Tower],
<<<  // ... remaining days omitted
>>>  [3], [Lyon, France], [Lyon City Hotel], [City Tour, Local Cuisine Tasting],
>>>  [4], [Geneva, Switzerland], [Lakeview Inn], [Lake Geneva, Red Cross Museum],
>>>  [5], [Zermatt, Switzerland], [Alpine Lodge], [Visit Matterhorn, Skiing],
)
```

En la función calculamos una alineación horizontal y otra vertical según si estamos en la primera columna (`{x == 0}`) o en la primera fila (`{y == 0}`). Luego aprovechamos que podemos sumar alineaciones horizontales y verticales con `+` para obtener una única alineación bidimensional.

Podés encontrar un ejemplo de uso de `table.cell` para cambiar la alineación de una sola celda en @table.cell[su página de referencia].

= #short-or-long[Combinar celdas][¿Cómo combino celdas?] <merge-cells>
Cuando una tabla contiene agrupaciones lógicas o los mismos datos en varias celdas adyacentes, puede ser conveniente combinar varias celdas en una sola celda más grande. Otro caso de uso para los grupos de celdas son los encabezados de tabla con varias filas: así, por ejemplo, podés agrupar una tabla de datos de ventas por trimestre en la primera fila y por mes en la segunda.

Una celda combinada abarca varias filas y/o columnas. Lo lográs con los argumentos `rowspan` y `colspan` de la función @table.cell: simplemente especificá cuántas filas o columnas querés que abarque tu celda.

El siguiente ejemplo contiene un calendario de asistencia de una oficina, con los días presenciales y remotos de cada integrante del equipo. Para que la tabla se entienda de un vistazo, combinamos las celdas adyacentes con el mismo valor:

```example
>>> #set page(width: 22cm)
#let ofi = [Office]
#let rem = [_Remote_]
#let lea = [*On leave*]

#show table.cell.where(y: 0): set text(
  fill: white,
  weight: "bold",
)

#table(
  columns: 6 * (1fr,),
  align: (x, y) => if x == 0 or y == 0 { left } else { center },
  stroke: (x, y) => (
    // Separate black cells with white strokes.
    left: if y == 0 and x > 0 { white } else { black },
    rest: black,
  ),
  fill: (_, y) => if y == 0 { black },

  table.header(
    [Team member],
    [Monday],
    [Tuesday],
    [Wednesday],
    [Thursday],
    [Friday]
  ),
  [Evelyn Archer],
    table.cell(colspan: 2, ofi),
    table.cell(colspan: 2, rem),
    ofi,
  [Lila Montgomery],
    table.cell(colspan: 5, lea),
  [Nolan Pearce],
    rem,
    table.cell(colspan: 2, ofi),
    rem,
    ofi,
)
```

En el ejemplo, primero definimos variables con "Office", "Remote" y "On leave" para no tener que escribir estas etiquetas cada vez. Después podemos usar estas variables en el cuerpo de la tabla, ya sea directamente o en una llamada a `table.cell` si la persona pasa varios días seguidos en la oficina, en remoto o de licencia.

El ejemplo también contiene un encabezado negro (creado con el argumento `fill` de `table`) con trazos blancos (argumento `stroke` de `table`) y texto blanco (establecido por la regla set de `table.cell`). Por último, alineamos al centro todo el contenido de todas las celdas del cuerpo. Si querés saber más sobre las funciones que se le pasan a `align`, `stroke` y `fill`, podés consultar las secciones sobre @alignment[alineación], @guides:tables:stroke-functions[trazos] y @guides:tables:fills[tablas con filas alternadas].

¡Esta tabla sería una excelente candidata para generarse de forma totalmente automática a partir de una fuente de datos externa! Mirá la @guides:tables:importing-data[sección sobre importación de datos] para aprender más al respecto.

= #short-or-long[Rotar una tabla][¿Cómo roto una tabla?] <rotate-table>
Cuando las tablas tienen muchas columnas, la orientación vertical del papel puede quedar chica enseguida. Por eso, a veces vas a querer pasar tus tablas a orientación horizontal. Hay dos maneras de lograrlo en Typst:

- Si querés rotar solo la tabla, pero no el resto del contenido de la página ni la página en sí, usá la @rotate[función `rotate`] con el argumento `reflow` en `{true}`.
- Si querés rotar toda la página en la que está la tabla, podés usar la @page[función `page`] con su argumento `flipped` en `{true}`. El encabezado, el pie de página y el número de página también aparecen ahora en el borde largo de la página. Esto tiene la ventaja de que la tabla se ve derecha cuando se lee en una computadora, pero también implica que una página de tu documento tiene dimensiones distintas de las demás, lo que puede resultarles chocante a tus lectores.

A continuación vamos a demostrar ambas técnicas con una tabla de calificaciones de estudiantes.

Primero vamos a rotar la tabla en la página. El ejemplo también coloca algo de texto a la derecha de la tabla.

```example
#set page("a5", columns: 2, numbering: "— 1 —")
>>> #set page(margin: auto)
#show table.cell.where(y: 0): set text(weight: "bold")

#rotate(
  -90deg,
  reflow: true,

  table(
    columns: (1fr,) + 5 * (auto,),
    inset: (x: 0.6em,),
    stroke: (_, y) => (
      x: 1pt,
      top: if y <= 1 { 1pt } else { 0pt },
      bottom: 1pt,
    ),
    align: (left, right, right, right, right, left),

    table.header(
      [Student Name],
      [Assignment 1], [Assignment 2],
      [Mid-term], [Final Exam],
      [Total Grade],
    ),
    [Jane Smith], [78%], [82%], [75%], [80%], [B],
    [Alex Johnson], [90%], [95%], [94%], [96%], [A+],
    [John Doe], [85%], [90%], [88%], [92%], [A],
    [Maria Garcia], [88%], [84%], [89%], [85%], [B+],
    [Zhang Wei], [93%], [89%], [90%], [91%], [A-],
    [Marina Musterfrau], [96%], [91%], [74%], [69%], [B-],
  ),
)

#lorem(80)
```

Lo que tenemos acá es un documento de dos columnas en papel ISO A5 con números de página al pie. La tabla tiene seis columnas y algunas personalizaciones de @guides:tables:strokes[trazo], alineación y espaciado. Pero lo más importante es que la tabla está envuelta en una llamada a la función `rotate` con el argumento `reflow` en `{true}`. Esto hace que la tabla gire 90 grados en sentido antihorario. El argumento reflow es necesario para que la rotación de la tabla afecte al diseño. Si se omitiera, Typst diagramaría la página como si la tabla no estuviera rotada (`{true}` podría pasar a ser el valor predeterminado en el futuro).

El ejemplo también muestra cómo producir muchas columnas del mismo tamaño: a la columna inicial de `{1fr}` le sumamos un array con cinco elementos `{auto}`, que creamos multiplicando por cinco un array con un solo elemento `{auto}`. Tené en cuenta que los arrays con un solo elemento necesitan una coma final para distinguirlos de simples expresiones entre paréntesis.

El segundo ejemplo muestra cómo rotar toda la página para que la tabla quede derecha:

```example
#set page("a5", numbering: "— 1 —")
>>> #set page(margin: auto)
#show table.cell.where(y: 0): set text(weight: "bold")

#page(flipped: true)[
  #table(
    columns: (1fr,) + 5 * (auto,),
    inset: (x: 0.6em,),
    stroke: (_, y) => (
      x: 1pt,
      top: if y <= 1 { 1pt } else { 0pt },
      bottom: 1pt,
    ),
    align: (left, right, right, right, right, left),

    table.header(
      [Student Name],
      [Assignment 1], [Assignment 2],
      [Mid-term], [Final Exam],
      [Total Grade],
    ),
    [Jane Smith], [78%], [82%], [75%], [80%], [B],
    [Alex Johnson], [90%], [95%], [94%], [96%], [A+],
    [John Doe], [85%], [90%], [88%], [92%], [A],
    [Maria Garcia], [88%], [84%], [89%], [85%], [B+],
    [Zhang Wei], [93%], [89%], [90%], [91%], [A-],
    [Marina Musterfrau], [96%], [91%], [74%], [69%], [B-],
  )

  #pad(x: 15%, top: 1.5em)[
    = Winter 2023/24 results
    #lorem(80)
  ]
]
```

Acá tomamos la misma tabla y el otro contenido que queremos componer junto con ella y los ponemos en una llamada a la función @page, pasándole `{true}` al argumento `flipped`. Esto le indica a Typst que cree páginas nuevas con el ancho y el alto intercambiados y que coloque el contenido de la llamada en una página nueva. Fijate que el número de página también está ahora en el borde largo del papel. Al pie de la página usamos la función @pad para acotar el ancho del párrafo y lograr una longitud de línea cómoda y legible.

= #short-or-long[Tabla en varias páginas][¿Cómo divido una tabla en varias páginas?] <table-across-pages>
Lo mejor es que una tabla entre en una sola página. Sin embargo, algunas tablas tienen muchísimas filas y dividirlas entre varias páginas se vuelve inevitable. Por suerte, Typst soporta dividir tablas entre páginas de forma predeterminada. Si usás las funciones @table.header y @table.footer, su contenido se repite en cada página como primera y última fila, respectivamente. Si querés desactivar este comportamiento, podés poner `repeat` en `{false}` en cualquiera de ellas.

Si pusiste tu tabla dentro de una @figure[figura], por defecto no puede dividirse entre páginas. Sin embargo, podés cambiar este comportamiento. Veamos cómo:

```example
#set page(width: 9cm, height: 6cm)
#show table.cell.where(y: 0): set text(weight: "bold")
#show figure: set block(breakable: true)

#figure(
  caption: [Training regimen for Marathon],
  table(
    columns: 3,
    fill: (_, y) => if y == 0 { gray.lighten(75%) },

    table.header[Week][Distance (km)][Time (hh:mm:ss)],
    [1], [5],  [00:30:00],
    [2], [7],  [00:45:00],
    [3], [10], [01:00:00],
    [4], [12], [01:10:00],
    [5], [15], [01:25:00],
    [6], [18], [01:40:00],
    [7], [20], [01:50:00],
    [8], [22], [02:00:00],
    [...], [...], [...],
    table.footer[_Goal_][_42.195_][_02:45:00_],
  )
)
```

Una figura produce automáticamente un @block[bloque] que, por defecto, no puede dividirse. Sin embargo, podemos reconfigurar el bloque de la figura con una regla show para hacerlo `breakable`. Ahora la figura abarca varias páginas y los encabezados y pies se repiten.

= #short-or-long[Importar datos][¿Cómo importo datos a una tabla?] <importing-data>
Muchas veces necesitás poner en una tabla datos que obtuviste de otro lado. A veces vienen de Microsoft Excel o Google Sheets, a veces de un conjunto de datos de la web o de tu experimento. Por suerte, Typst puede cargar muchos @reference:data-loading[formatos de archivo comunes], así que podés usar scripting para incluir sus datos en una tabla.

El formato de archivo más común para datos tabulares es CSV. Podés obtener un archivo CSV desde Excel eligiendo "Guardar como" en el menú _Archivo_ y seleccionando el formato "CSV UTF-8 (delimitado por comas) (.csv)". Guardá el archivo y, si usás la app web, subilo a tu proyecto.

En nuestro caso, vamos a construir una tabla sobre la Ley de Moore. Para eso usamos una estadística sobre #link("https://ourworldindata.org/grapher/transistors-per-microprocessor")[cuántos transistores tiene en promedio un microprocesador por año, de Our World in Data]. Empecemos presionando el botón "Download" para obtener un archivo CSV con los datos sin procesar.

Asegurate de mover el archivo a tu proyecto o a algún lugar que Typst pueda ver, si usás la CLI. Una vez que lo hiciste, podemos abrir el archivo para ver cómo está estructurado:

```csv
Entity,Code,Year,Transistors per microprocessor
World,OWID_WRL,1971,2308.2417
World,OWID_WRL,1972,3554.5222
World,OWID_WRL,1974,6097.5625
```

El archivo empieza con un encabezado y contiene cuatro columnas: Entity (a quién se aplica la métrica), Code, el año y la cantidad de transistores por microprocesador. Solo las dos últimas columnas cambian entre una fila y otra, así que podemos ignorar "Entity" y "Code".

Primero, carguemos este archivo con la función @csv. Acepta como argumento de tipo cadena de texto el nombre del archivo que queremos cargar:

```typ
#let moore = csv("moore.csv")
```

Cargamos nuestro archivo (suponiendo que lo llamamos `moore.csv`) y @reference:scripting:bindings[lo asociamos] a la nueva variable `moore`. Esto no produce ninguna salida, así que todavía no hay nada para ver. Si queremos examinar lo que Typst cargó, podemos pasar el mouse sobre el nombre de la variable en la app web o imprimir algunos elementos del array:

```example
#let moore = csv("moore.csv")

#moore.slice(0, 3)
```

Con los argumentos `{(0, 3)}`, el método @array.slice[`slice`] devuelve los tres primeros elementos del array (con los índices 0, 1 y 2). Vemos que cada fila es su propio array con un elemento por celda.

Ahora escribamos un bucle que transforme estos datos en un array de celdas que podamos usar con la función table.

```example
#let moore = csv("moore.csv")

#table(
  columns: 2,
  ..for (.., year, count) in moore {
    (year, count)
  }
)
```

El ejemplo anterior usa un bucle for que itera sobre las filas de nuestro archivo CSV y devuelve un array en cada iteración. Usamos la capacidad de @reference:scripting:bindings[desestructuración] del bucle for para descartar todos los elementos de cada fila salvo los dos últimos. Luego creamos un array nuevo con solo esos dos. Como Typst concatena los arrays resultantes de todas las iteraciones del bucle, obtenemos un array unidimensional en el que se alternan la columna del año y la cantidad de transistores. Después podemos insertar el array como celdas. Para eso usamos el @arguments:spreading[operador spread] (`..`). Al anteponer dos puntos a un array o, en nuestro caso, a una expresión que produce un array, le indicamos a Typst que los elementos del array deben usarse como argumentos posicionales.

Como alternativa, también podemos usar los métodos de array @array.map[`map`], @array.slice[`slice`] y @array.flatten[`flatten`] para escribir esto en un estilo más funcional:

```typ
#let moore = csv("moore.csv")

#table(
   columns: 2,
   ..moore.map(m => m.slice(2, 4)).flatten(),
)
```

Este ejemplo se renderiza igual que el anterior, pero primero cargamos el CSV y luego transformamos cada fila con `map`. La función que le pasamos a `map` se aplica a cada fila de los datos y devuelve un array nuevo que reemplaza a la fila original. Acá usamos `{.slice(2, 4)}` para extraer solo la tercera y la cuarta columna, ya que son las que queremos conservar. Como `moore` es un array bidimensional (cada fila es a su vez un array), el resultado del mapeo sigue siendo un array anidado. La función `flatten` convierte esta estructura anidada en un array unidimensional, que es lo que se necesita al expandir los datos en la función `table`. Por último, especificamos explícitamente `{columns: 2}` porque conservamos exactamente dos columnas de cada fila.

Ahora que tenemos un buen código para nuestra tabla, ¡tratemos de que la tabla en sí también quede linda! La cantidad de transistores pasa de millones en 1995 a billones en 2021 y con tantos dígitos cuesta ver los cambios. Podríamos intentar presentar nuestros datos en escala logarítmica para hacerlos más digeribles:

```example
#let moore = csv("moore.csv")
#let moore-log = moore.slice(1).map(m => {
  let (.., year, count) = m
  let log = calc.log(float(count))
  let rounded = str(calc.round(log, digits: 2))
  (year, rounded)
})

#show table.cell.where(x: 0): strong

#table(
   columns: moore-log.first().len(),
   align: right,
   fill: (_, y) => if calc.odd(y) { rgb("D7D9E0") },
   stroke: none,

   table.header[Year][Transistor count ($log_10$)],
   table.hline(stroke: rgb("4D4C5B")),
   ..moore-log.flatten(),
)
```

En este ejemplo, primero descartamos la fila de encabezado de los datos, ya que agregamos la nuestra. Luego descartamos todas las columnas salvo las dos últimas, como antes. Lo hacemos @reference:scripting:bindings[desestructurando] el array `m` y descartando todo menos los dos últimos elementos. Después convertimos la cadena de `count` en un número de punto flotante, calculamos su logaritmo y lo guardamos en la variable `log`. Finalmente, lo redondeamos a dos dígitos, lo convertimos en cadena de texto y lo guardamos en la variable `rounded`. Luego devolvemos un array con `year` y `rounded` que reemplaza a la fila original. En nuestra tabla agregamos un encabezado propio que le indica al lector que aplicamos un logaritmo a los valores. Después expandimos los datos aplanados, como antes.

También le dimos estilo a la tabla con @guides:tables:fills[rayas], una @guides:tables:individual-lines[línea horizontal] debajo de la primera fila, todo @guides:tables:alignment[alineado] a la derecha y la primera columna en negrita. ¡Hacé clic en los enlaces para ir a las secciones de la guía correspondientes y ver cómo se hace!

= #short-or-long[Tabla y grilla][¿Qué hago si necesito la función table para algo que no es una tabla?] <table-and-grid>
Las disposiciones tabulares del contenido pueden ser útiles no solo para matrices de datos estrechamente relacionados, como los que se muestran en los ejemplos de esta guía, sino también con fines de presentación. Typst distingue entre las grillas, que sirven solo para maquetar y presentar, y las tablas, en las que la disposición de las celdas transmite información en sí misma.

Para dejar clara esta diferencia a otros programas y permitir que las plantillas les den mucho estilo a las tablas, Typst tiene dos funciones para la disposición en grilla y en tabla:

- La función @table, explicada a lo largo de esta guía, pensada para datos tabulares.
- La función @grid, pensada para fines de presentación y de maquetación de páginas.

Ambos elementos funcionan de la misma manera y tienen los mismos argumentos. Todo lo que aprendiste sobre tablas en esta guía se aplica a las grillas. Solo hay tres diferencias:

- Vas a tener que usar los elementos @grid.cell, @grid.vline y @grid.hline en lugar de @table.cell, @table.vline y @table.hline.
- La grilla tiene valores predeterminados distintos: no dibuja trazos por defecto y no tiene espaciado (`inset`) dentro de sus celdas.
- Elementos como `figure` no reaccionan a las grillas, ya que se supone que no tienen incidencia semántica en la estructura del documento.
