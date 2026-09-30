#import "../../components/index.typ": (
  checked-list, docs-chapter, docs-figure, example, folding-details, info,
  short-or-long,
)

#show: docs-chapter.with(
  title: "Estilos avanzados",
  route: "/tutorial/advanced-styling",
  description: "Tutorial de Typst.",
)

En los dos capítulos anteriores de este tutorial, aprendiste a escribir un documento en Typst y a cambiar su formato. El informe que escribiste a lo largo de los últimos dos capítulos sacó un diez y tu supervisor quiere basar un trabajo para una conferencia en él. Por supuesto, el trabajo tendrá que cumplir con la guía de estilo de la conferencia. Veamos cómo lograrlo.

Antes de empezar, creemos un equipo, invitemos a tu supervisor y agreguémoslo al equipo. Podés hacerlo volviendo al panel de la app con el ícono de volver de la esquina superior izquierda del editor. Después, elegí el ícono de más en la barra de herramientas izquierda y creá un equipo. Por último, hacé clic en el equipo nuevo y andá a su configuración haciendo clic en "administrar equipo" junto al nombre del equipo. Ahora podés invitar a tu supervisor por correo electrónico.

#docs-figure(
  "3-advanced-team-settings.png",
  alt: "La configuración del equipo",
  shadow: false,
)

A continuación, mové tu proyecto al equipo: abrilo, andá a su configuración eligiendo el ícono de engranaje en la barra de herramientas izquierda y seleccioná tu equipo nuevo en el menú desplegable de propietarios. ¡No te olvides de guardar los cambios!

Ahora tu supervisor también puede editar el proyecto y los dos pueden ver los cambios en tiempo real. ¡Podés sumarte a nuestro #link("https://discord.gg/2uDybryKPe")[servidor de Discord] para conocer a otros usuarios y probar los equipos con ellos!

= #short-or-long[Pautas][Las pautas de la conferencia] <guidelines>
Las pautas de diseño están disponibles en el sitio web de la conferencia. Veámoslas:

- La fuente debe ser una fuente con serifas de 11pt
- El título debe estar en 17pt y en negrita
- El trabajo contiene un resumen a una columna y un texto principal a dos columnas
- El resumen debe estar centrado
- El texto principal debe estar justificado
- Los títulos de sección de primer nivel deben ser de 13pt, centrados y en versalitas
- Los títulos de segundo nivel van incorporados al párrafo, en cursiva y con el mismo tamaño que el texto del cuerpo
- Por último, las páginas deben ser de tamaño carta de EE. UU., numeradas en el centro del pie de página, y la esquina superior derecha de cada página debe contener el título del trabajo

Ya sabemos hacer muchas de estas cosas, pero para algunas vamos a tener que aprender trucos nuevos.

= #short-or-long[Reglas set][Escribir las reglas set correctas] <set-rules>
Empecemos escribiendo algunas reglas set para el documento.

```example
#set page(
>>> margin: auto,
  paper: "us-letter",
  header: align(right)[
    Un modelo de dinámica de fluidos
    para el flujo glaciar
  ],
  numbering: "1",
)
#set par(justify: true)
#set text(
  font: "Libertinus Serif",
  size: 11pt,
)

#lorem(600)
```

Ya conocés la mayor parte de lo que pasa acá. Establecimos el tamaño del texto en `{11pt}` y la fuente en Libertinus Serif. También activamos la justificación de párrafos y establecimos el tamaño de página en carta de EE. UU.

El argumento `header` es nuevo: con él, podemos proporcionar contenido para llenar el margen superior de cada página. En el encabezado, especificamos el título de nuestro trabajo, como lo pide la guía de estilo de la conferencia. Usamos la función `align` para alinear el texto a la derecha.

Por último, pero no menos importante, el argumento `numbering`. Acá podemos proporcionar un @numbering[patrón de numeración] que define cómo numerar las páginas. Al establecerlo en `{"1"}`, Typst muestra solamente el número de página. Establecerlo en `{"(1/1)"}` habría mostrado la página actual y el total de páginas entre paréntesis. E incluso podríamos haber proporcionado acá una función completamente personalizada para dar formato a nuestro gusto.

= #short-or-long[Título y resumen][Crear un título y un resumen] <title-and-abstract>
Ahora agreguemos un título y un resumen. Empecemos por el título. Typst trae una función @title. Empecemos proporcionando nuestro título como argumento:

```example
>>> #set page(width: 300pt, margin: 30pt)
>>> #set text(font: "Libertinus Serif", 11pt)
#title[
  Un modelo de dinámica de fluidos
  para el flujo glaciar
]
```

Podés ver que el título ya está en negrita y tiene algo de espacio alrededor. Sin embargo, está alineado a la izquierda y no mide exactamente 17pt. Por lo tanto, tenemos que ajustar su aspecto. La función title no trae argumentos de fuente o tamaño de texto que podamos establecer. En cambio, esas propiedades se definen en las funciones `text` y `align`.

#info[
  ¿Cuál es la diferencia entre lo que insertó la función `title` y los títulos que produjimos con signos igual?

  Los títulos (headings), incluso los de primer nivel, pueden aparecer varias veces en tu documento, mientras que un título de documento (title) aparece una sola vez, generalmente al principio. Diferenciar entre ambos ayuda a Typst a hacer tu documento accesible para usuarios de tecnologías de asistencia, como los lectores de pantalla.
]

Cuando queremos personalizar las propiedades de algún elemento dentro de otro tipo de elemento, podemos usar reglas show-set. Primero, usamos `show` para seleccionar qué elemento queremos personalizar. A esto lo llamamos _selector._ Después, escribimos dos puntos. A continuación, escribimos la regla set que debe aplicarse a los elementos que coinciden con el selector. En resumen, la sintaxis se ve así:

```typ
#show your-selector: set some-element(/* ... */)
```

Recordemos: queremos centrar el título y que mida 17pt. Por lo tanto, necesitamos dos reglas show-set:

- Una con el selector `title` y la regla `{set text(size: 17pt)}`
- Una con el selector `title` y la regla `{set align(center)}`

Nuestro ejemplo ahora se ve así:

```example
>>> #set page(width: 300pt, margin: 30pt)
>>> #set text(font: "Libertinus Serif", 11pt)
#show title: set text(size: 17pt)
#show title: set align(center)

#title[
  Un modelo de dinámica de fluidos
  para el flujo glaciar
]
```

Esto se ve bien. Agreguemos también la lista de autores: como estamos escribiendo este trabajo junto con nuestro supervisor, vamos a agregar nuestro nombre y el suyo.

```example
>>> #set page(width: 300pt, margin: 30pt)
>>> #set text(font: "Libertinus Serif", 11pt)
>>>
>>> #show title: set text(size: 17pt)
>>> #show title: set align(center)
>>>
>>> #title[
>>>   Un modelo de dinámica de fluidos
>>>   para el flujo glaciar
>>> ]

#grid(
  columns: (1fr, 1fr),
  align(center)[
    Therese Tungsten \
    Instituto Artos \
    #link("mailto:tung@artos.edu")
  ],
  align(center)[
    Dr. John Doe \
    Instituto Artos \
    #link("mailto:doe@artos.edu")
  ]
)
```

Los dos bloques de autores se disponen uno al lado del otro. Usamos la función @grid para crear este diseño. Con una grilla, podemos controlar exactamente el tamaño de cada columna y qué contenido va en cada celda. El argumento `columns` toma un array de @relative[longitudes relativas] o @fraction[fracciones]. En este caso, le pasamos dos tamaños fraccionales iguales, para indicarle que divida el espacio disponible en dos columnas iguales. Después le pasamos dos argumentos de contenido a la función grid: el primero con nuestros datos y el segundo con los de nuestro supervisor. Otra vez usamos la función `align` para centrar el contenido dentro de la columna. La grilla acepta una cantidad arbitraria de argumentos de contenido que especifican las celdas. Las filas se agregan automáticamente, pero también se les puede dar tamaño manualmente con el argumento `rows`.

Si miramos a los autores y el título, están un poco demasiado juntos. Podés resolverlo usando otra regla show-set para configurar el espacio debajo del título. El título, la grilla y todos los demás elementos que Typst dispone de arriba hacia abajo en la página (excepto los párrafos) se llaman _bloques._ Cada bloque se controla con la función @block. Ella controla comportamientos como la distancia entre bloques y si un bloque puede contener un salto de página. Eso significa que podemos escribir otra regla show-set que seleccione el título para establecer el espaciado del bloque:

```example
>>> #set page(width: 300pt, margin: 30pt)
>>> #set text(font: "Libertinus Serif", 11pt)
>>>
#show title: set text(size: 17pt)
#show title: set align(center)
#show title: set block(below: 1.2em)

#title[
  Un modelo de dinámica de fluidos
  para el flujo glaciar
]

#grid(
<<<   // ...
>>>   columns: (1fr, 1fr),
>>>   align(center)[
>>>     Therese Tungsten \
>>>     Instituto Artos \
>>>     #link("mailto:tung@artos.edu")
>>>   ],
>>>   align(center)[
>>>     Dr. John Doe \
>>>     Instituto Artos \
>>>     #link("mailto:doe@artos.edu")
>>>   ]
)
```

Con esta regla show-set, sobrescribimos el espaciado debajo del título. Usamos la unidad `em`: nos permite expresar longitudes como múltiplos del tamaño de la fuente. Acá la usamos para separar el título y la lista de autores exactamente 1,2 veces el tamaño de la fuente. Ahora agreguemos el resumen. Acordate de que la conferencia quiere el resumen con alineación centrada y sin justificar.

#example(
  zoom: (0pt, 0pt, 612pt, 317.5pt),
  ```
  >>> #set page(
  >>>   "us-letter",
  >>>   margin: auto,
  >>>   header: align(right + horizon)[
  >>>     Un modelo de dinámica de fluidos
  >>>     para el flujo glaciar
  >>>   ],
  >>>   numbering: "1",
  >>> )
  >>> #set par(justify: true)
  >>> #set text(font: "Libertinus Serif", 11pt)
  >>>
  >>> #show title: set text(size: 17pt)
  >>> #show title: set align(center)
  >>> #show title: set block(below: 1.2em)
  >>>
  >>> #title[
  >>>   Un modelo de dinámica de fluidos
  >>>   para el flujo glaciar
  >>> ]
  >>>
  >>> #grid(
  >>>   columns: (1fr, 1fr),
  >>>   align(center)[
  >>>     Therese Tungsten \
  >>>     Instituto Artos \
  >>>     #link("mailto:tung@artos.edu")
  >>>   ],
  >>>   align(center)[
  >>>     Dr. John Doe \
  >>>     Instituto Artos \
  >>>     #link("mailto:doe@artos.edu")
  >>>   ]
  >>> )
  >>>
  <<< ...

  #align(center)[
    #set par(justify: false)
    *Resumen* \
    #lorem(80)
  ]
  >>> #lorem(600)
  ```
)

¡Bien hecho! Una cosa notable es que usamos una regla set dentro del argumento de contenido de `align` para desactivar la justificación del resumen. Esto no afecta el resto del documento, aunque se haya especificado después de la primera regla set, porque los bloques de contenido _delimitan_ los estilos. Todo lo que se establece dentro de un bloque de contenido solo afecta al contenido de ese bloque.

Otro ajuste podría ser eliminar la duplicación entre el encabezado y el argumento del elemento title. Como comparten el título, sería conveniente guardarlo en un lugar pensado para contener metadatos del documento. Después necesitaríamos una forma de recuperar el título en ambos lugares. El elemento `document` nos puede ayudar con lo primero: al usarlo en una regla set, podemos guardar metadatos del documento como el título, la descripción y las palabras clave.

```typ
#set document(title: [Un modelo de dinámica de fluidos para el flujo glaciar])
```

Al exportar un PDF, el título establecido acá aparece en la barra de título de tu lector de PDF. Tu sistema operativo también usa este título para que el archivo se pueda encontrar en las búsquedas. Por último, contribuye a que tu documento sea más accesible y es obligatorio si elegís cumplir con PDF/UA, un estándar de PDF centrado en la accesibilidad.

Ahora necesitamos una forma de recuperar el valor que establecimos en el título principal y en el encabezado. Como la función `title` está diseñada para trabajar junto con el elemento `document`, llamarla sin argumentos simplemente imprime el título. Para el encabezado, vamos a tener que ser más explícitos: como Typst no tiene forma de saber que queremos insertar el título ahí, tenemos que decírselo manualmente.

Con _context,_ podemos recuperar el contenido de cualquier valor que hayamos establecido antes en elementos. Cuando usamos la palabra clave `{context}`, podemos acceder a cualquier propiedad de cualquier elemento, incluida la propiedad title del elemento document. Se usa así:

#example(
  single: true,
  ```
  #set document(title: [
    Un modelo de dinámica de fluidos
    para el flujo glaciar
  ])

  <<< ...

  #set page(
  >>> "us-letter",
  >>> margin: auto,
    header: align(
      right + horizon,
      // Obtener la propiedad title
      // del elemento document.
      context document.title,
    ),
  <<<   ...
  >>> numbering: "1",
  )
  >>> #set par(justify: true)
  >>> #set text(font: "Libertinus Serif", 11pt)

  >>> #show title: set text(size: 17pt)
  >>>
  >>> #show title: set align(center)
  >>> #show title: set block(below: 1.2em)
  #title()

  <<< ...

  >>> #grid(
  >>>   columns: (1fr, 1fr),
  >>>   align(center)[
  >>>     Therese Tungsten \
  >>>     Instituto Artos \
  >>>     #link("mailto:tung@artos.edu")
  >>>   ],
  >>>   align(center)[
  >>>     Dr. John Doe \
  >>>     Instituto Artos \
  >>>     #link("mailto:doe@artos.edu")
  >>>   ]
  >>> )
  >>>
  >>> #align(center)[
  >>>   #set par(justify: false)
  >>>   *Resumen* \
  >>>   #lorem(80)
  >>> ]
  >>>
  >>> #lorem(600)
  ```
)

Primero, fijate cómo llamamos a la función title con paréntesis redondos vacíos. Como no se pasó ningún argumento, usó por defecto lo que establecimos arriba para el elemento document. La distinción entre paréntesis redondos vacíos y corchetes vacíos es importante: mientras que los paréntesis redondos vacíos indican que no pasás nada, los corchetes vacíos significan que pasás un argumento: un bloque de contenido vacío. Si se la llama de esa manera, el título no tendría contenido visible.

A continuación, mirá el encabezado. En lugar del título entre corchetes, usamos la palabra clave context para acceder al título del documento. Esto insertó exactamente lo que establecimos arriba. El rol de context no se limita a acceder a propiedades: con él podés verificar si hay ciertos elementos en el documento, medir las dimensiones físicas de otros y más. Con context, podés construir plantillas potentes que reaccionan a las preferencias del usuario final.

#info[
  #folding-details(
    title: [¿Por qué hace falta la palabra clave context para acceder a las propiedades de un elemento?],
  )[
    Normalmente, cuando accedemos a una variable, sabemos exactamente cuál va a ser su valor:

    - La variable podría ser una constante incorporada en Typst, como `[#sym.pi]`
    - La variable podría estar definida por un argumento
    - La variable podría estar definida o sobrescrita en el ámbito actual

    Sin embargo, a veces eso no alcanza. En este capítulo del tutorial, insertamos un encabezado de página con el título. Aunque pasamos una sola pieza de contenido para el encabezado, podríamos querer que distintas páginas tengan encabezados diferentes. Por ejemplo, podríamos querer imprimir el nombre del capítulo o usar el número de página. Cuando usamos context, podemos escribir un único bloque de contexto que le indica a Typst que mire dónde está insertado, busque el último título, el número de página actual o cualquier otra cosa, y siga desde ahí. Eso significa que el mismo bloque de contexto, insertado en páginas distintas, puede producir resultados diferentes.

    Para más información, leé sobre context @reference:context[en su documentación] después de completar este tutorial.
  ]
]

= #short-or-long[Columnas y títulos][Agregar columnas y títulos] <columns-and-headings>
Lamentablemente, el trabajo de arriba parece una pared de plomo. Para arreglarlo, agreguemos algunos títulos y pasemos nuestro trabajo a un diseño de dos columnas. Por suerte, es fácil: solo tenemos que ampliar nuestra regla set de `page` con el argumento `columns`.

Al agregar `{columns: 2}` a la lista de argumentos, envolvimos todo el documento en dos columnas. Sin embargo, eso también afectaría al título y a la lista de autores. Para que sigan ocupando todo el ancho de la página, podemos envolverlos en una llamada a la función @place[`{place}`]. Place espera como argumentos posicionales una alineación y el contenido que debe ubicar. Con el argumento con nombre `{scope}`, podemos decidir si los elementos se ubican en relación con la columna actual o con su contenedor padre (la página). Hay una cosa más para configurar: si no se proporcionan otros argumentos, `{place}` saca su contenido del flujo del documento y lo posiciona sobre el resto del contenido, sin afectar el diseño del otro contenido de su contenedor:

```example
#place(
  top + center,
  rect(fill: black),
)
#lorem(30)
```

Si no hubiéramos usado `{place}` acá, el cuadrado estaría en su propia línea, pero así se superpone con las pocas líneas de texto que le siguen. Del mismo modo, ese texto actúa como si no hubiera cuadrado. Para cambiar este comportamiento, podemos pasar el argumento `{float: true}` para asegurarnos de que el espacio que ocupa el elemento ubicado en la parte superior o inferior de la página no sea ocupado por ningún otro contenido.

#example(
  single: true,
  ```
  >>> #set document(title: [
  >>>   Un modelo de dinámica de fluidos
  >>>   para el flujo glaciar
  >>> ])
  >>>
  #set page(
  >>> margin: auto,
    paper: "us-letter",
    header: align(
      right + horizon,
      context document.title,
    ),
    numbering: "1",
    columns: 2,
  )
  >>> #set par(justify: true)
  >>> #set text(font: "Libertinus Serif", 11pt)

  #place(
    top + center,
    float: true,
    scope: "parent",
    clearance: 2em,
  )[
  >>> #show title: set text(size: 17pt)
  >>> #show title: set align(center)
  >>> #show title: set block(below: 1.2em)
  >>>
  >>> #title()
  >>>
  >>> #grid(
  >>>   columns: (1fr, 1fr),
  >>>   [
  >>>     Therese Tungsten \
  >>>     Instituto Artos \
  >>>     #link("mailto:tung@artos.edu")
  >>>   ],
  >>>   [
  >>>     Dr. John Doe \
  >>>     Instituto Artos \
  >>>     #link("mailto:doe@artos.edu")
  >>>   ]
  >>> )
  <<<   ...

    #par(justify: false)[
      *Resumen* \
      #lorem(80)
    ]
  ]

  = Introducción
  #lorem(300)

  = Trabajos relacionados
  #lorem(200)
  ```
)

En este ejemplo, también usamos el argumento `clearance` de la función `{place}` para dar el espacio entre ella y el cuerpo, en lugar de usar la función @v[`{v}`]. También podemos eliminar las llamadas explícitas a `{align(center, ..)}` alrededor de las distintas partes, ya que heredan la alineación centrada de la ubicación.

Ahora solo queda una cosa por hacer: darle estilo a los títulos. Tenemos que centrarlos y usar versalitas. Estas propiedades no están disponibles en la función `heading`, así que vamos a tener que escribir algunas reglas show-set y una regla show:

- Una regla show-set para que los títulos estén centrados
- Una regla show-set para que los títulos midan 13pt y usen el peso regular
- Una regla show para envolver los títulos en una llamada a la función `smallcaps`

#example(
  zoom: (50pt, 250pt, 265pt, 270pt),
  ```
  >>> #set document(title: [
  >>>   Un modelo de dinámica de fluidos
  >>>   para el flujo glaciar
  >>> ])
  >>>
  >>> #set page(
  >>>   "us-letter",
  >>>   margin: auto,
  >>>   header: align(
  >>>     right + horizon,
  >>>     context document.title,
  >>>   ),
  >>>   numbering: "1",
  >>>   columns: 2,
  >>> )
  >>> #set par(justify: true)
  >>> #set text(font: "Libertinus Serif", 11pt)
  #show heading: set align(center)
  #show heading: set text(
    size: 13pt,
    weight: "regular",
  )
  #show heading: smallcaps

  <<< ...
  >>> #place(
  >>>   top + center,
  >>>   float: true,
  >>>   scope: "parent",
  >>>   clearance: 2em,
  >>> )[
  >>>   #show title: set text(size: 17pt)
  >>>   #show title: set align(center)
  >>>   #show title: set block(below: 1.2em)
  >>>
  >>>   #title()
  >>>
  >>>   #grid(
  >>>     columns: (1fr, 1fr),
  >>>     [
  >>>       Therese Tungsten \
  >>>       Instituto Artos \
  >>>       #link("mailto:tung@artos.edu")
  >>>     ],
  >>>     [
  >>>       Dr. John Doe \
  >>>       Instituto Artos \
  >>>       #link("mailto:doe@artos.edu")
  >>>     ]
  >>>   )
  >>>
  >>>   #par(justify: false)[
  >>>     *Resumen* \
  >>>     #lorem(80)
  >>>   ]
  >>> ]

  = Introducción
  <<< ...
  >>> #lorem(35)

  == Motivación
  <<< ...
  >>> #lorem(45)
  ```
)

¡Esto se ve genial! Usamos reglas show que se aplican a todos los títulos. En la última regla show, aplicamos la función `smallcaps` al título completo. Como vamos a ver en el próximo ejemplo, también podemos proporcionar una regla personalizada para sobrescribir por completo el aspecto por defecto de los títulos.

El único problema que queda es que todos los títulos se ven iguales ahora. Las subsecciones "Motivación" y "Planteo del problema" deberían ser títulos en cursiva incorporados al párrafo, pero ahora mismo son indistinguibles de los títulos de sección. Lo podemos arreglar usando un selector `where` en nuestra regla show: es un @reference:scripting:methods[método] que podemos llamar sobre los títulos (y otros elementos) y que nos permite filtrarlos por sus propiedades. Podemos usarlo para diferenciar entre los títulos de sección y de subsección:

#example(
  zoom: (50pt, 250pt, 265pt, 245pt),
  ```
  >>> #set document(title: [
  >>>   Un modelo de dinámica de fluidos
  >>>   para el flujo glaciar
  >>> ])
  >>>
  >>> #set page(
  >>>   "us-letter",
  >>>   margin: auto,
  >>>   header: align(
  >>>     right + horizon,
  >>>     context document.title,
  >>>   ),
  >>>   numbering: "1",
  >>>   columns: 2,
  >>> )
  >>> #set par(justify: true)
  >>> #set text(font: "Libertinus Serif", 11pt)
  >>>
  #show heading.where(level: 1): set align(center)
  #show heading.where(level: 1): set text(size: 13pt, weight: "regular")
  #show heading.where(level: 1): smallcaps

  #show heading.where(level: 2): set text(
    size: 11pt,
    weight: "regular",
    style: "italic",
  )
  #show heading.where(level: 2): it => {
    it.body + [.]
  }
  >>>
  >>> #place(
  >>>   top + center,
  >>>   float: true,
  >>>   scope: "parent",
  >>>   clearance: 2em,
  >>> )[
  >>>   #show title: set text(size: 17pt)
  >>>   #show title: set align(center)
  >>>   #show title: set block(below: 1.2em)
  >>>
  >>>   #title()
  >>>
  >>>   #grid(
  >>>     columns: (1fr, 1fr),
  >>>     [
  >>>       Therese Tungsten \
  >>>       Instituto Artos \
  >>>       #link("mailto:tung@artos.edu")
  >>>     ],
  >>>     [
  >>>       Dr. John Doe \
  >>>       Instituto Artos \
  >>>       #link("mailto:doe@artos.edu")
  >>>     ]
  >>>   )
  >>>
  >>>   #par(justify: false)[
  >>>     *Resumen* \
  >>>     #lorem(80)
  >>>   ]
  >>> ]
  >>>
  >>> = Introduction
  >>> #lorem(35)
  >>>
  >>> == Motivation
  >>> #lorem(45)
  ```
)

En este ejemplo, primero acotamos nuestras reglas anteriores a los títulos de primer nivel usando `{.where(level: 1)}` para hacer el selector más específico. Después, agregamos una regla show-set para el segundo nivel de títulos. Por último, necesitamos una regla show con una función personalizada: los títulos encierran su contenido en un bloque por defecto. Esto hace que el título tenga su propia línea. Sin embargo, queremos que quede incorporado al texto, así que tenemos que proporcionar nuestra propia regla show para deshacernos de este bloque.

A la regla le damos una función que toma el título como parámetro. Por convención, este parámetro se llama `it`, pero puede tener otro nombre. El parámetro se puede usar como contenido y simplemente muestra el título por defecto completo. Como alternativa, cuando queremos construir nuestro propio título, podemos usar sus campos como `body`, `numbering` y `level` para componer un aspecto personalizado. Acá simplemente imprimimos el cuerpo del título con un punto al final y omitimos el bloque que produce la regla show incorporada. Tené en cuenta que este título ya no va a reaccionar a las reglas set de numeración de títulos y similares, porque no usamos explícitamente `it.numbering` en la regla show. Si escribís reglas show como esta y querés que el documento siga siendo personalizable, vas a tener que tener en cuenta estos campos.

¡Esto se ve genial! Escribimos reglas show que se aplican selectivamente a los títulos de primer y segundo nivel. Usamos un selector `where` para filtrar los títulos por su nivel. Después mostramos los títulos de subsección incorporados al párrafo. También agregamos automáticamente un punto al final de los títulos de subsección.

Repasemos la guía de estilo de la conferencia:
#checked-list[
  - La fuente debe ser una fuente con serifas de 11pt
  - El título debe estar en 17pt y en negrita
  - El trabajo contiene un resumen a una columna y un texto principal a dos columnas
  - El resumen debe estar centrado
  - El texto principal debe estar justificado
  - Los títulos de sección de primer nivel deben estar centrados, en versalitas y en 13pt
  - Los títulos de segundo nivel van incorporados al párrafo, en cursiva y con el mismo tamaño que el texto del cuerpo
  - Por último, las páginas deben ser de tamaño carta de EE. UU., numeradas en el centro, y la esquina superior derecha de cada página debe contener el título del trabajo
]

Ahora cumplimos con todos estos estilos y ¡podemos enviar el trabajo a la conferencia! El trabajo terminado se ve así:

#docs-figure(
  "3-advanced-paper.png",
  alt: "El trabajo terminado",
  width: 400,
)

= Review <review>
Ya aprendiste a crear títulos, encabezados y pies de página, a usar funciones, reglas show-set y ámbitos para sobrescribir estilos localmente, a crear diseños más complejos con la función @grid, a acceder a las propiedades de los elementos con context y a escribir reglas show para funciones individuales y para todo el documento. También aprendiste a usar el @reference:styling:show-rules[selector `where`] para filtrar los títulos por su nivel.

¡El trabajo fue un gran éxito! Conociste a muchos investigadores con intereses afines en la conferencia y estás planeando un proyecto que esperás publicar en el mismo lugar el año que viene. Sin embargo, vas a tener que escribir un nuevo trabajo con la misma guía de estilo, así que quizás ahora quieras crear una plantilla que les ahorre tiempo a vos y a tu equipo.

En la próxima sección, vamos a aprender a crear plantillas que se pueden reutilizar en varios documentos. Es un tema más avanzado, así que sentite libre de volver a él más tarde si ahora no tenés ganas.
