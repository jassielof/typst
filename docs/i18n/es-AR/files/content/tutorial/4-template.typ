#import "../../components/index.typ": docs-chapter, example, short-or-long

#show: docs-chapter.with(
  title: "Crear una plantilla",
  route: "/tutorial/making-a-template",
  description: "Tutorial de Typst.",
)

En los tres capítulos anteriores de este tutorial, aprendiste a escribir un documento en Typst, a aplicar estilos básicos y a personalizar su aspecto en profundidad para cumplir con la guía de estilo de una editorial. Como el trabajo que escribiste en el capítulo anterior fue un éxito rotundo, te pidieron que escribas un artículo de seguimiento para la misma conferencia. Esta vez querés tomar el estilo que creaste en el capítulo anterior y convertirlo en una plantilla reutilizable. En este capítulo vas a aprender a crear una plantilla que vos y tu equipo puedan usar con una sola regla show. ¡Empecemos!

= #short-or-long[Variables][Reutilizar datos con variables] <variables>
En los capítulos anteriores, la mayor parte del contenido del documento se ingresó a mano. En el tercer capítulo usamos el elemento `document` y context para reducir la repetición e ingresar el título una sola vez. Pero en la práctica puede haber muchas más cosas que aparecen varias veces en tu documento. Hay varias buenas razones para definir estos valores repetidos una sola vez:

+ Hace que cambiarlos más adelante sea más fácil
+ Te permite encontrar rápidamente todos los lugares donde usaste algo
+ Facilita mantener la coherencia en todo el documento
+ Para segmentos repetidos largos o difíciles de escribir, suele ser más cómodo tipear un nombre de variable más corto

Si estuvieras usando un procesador de texto convencional, podrías recurrir a un valor provisorio para buscarlo más tarde. En Typst, en cambio, podés usar variables para guardar contenido de forma segura y reutilizarlo en todo tu documento mediante el nombre de la variable.

La técnica de usar context para reproducir la propiedad de un elemento que aprendimos antes no siempre es la más apropiada para esto: los elementos incorporados de Typst se centran en propiedades semánticas, como el título y la descripción de un documento, o en cosas que se relacionan directamente con la composición tipográfica, como el tamaño del texto.

Para nuestro ejemplo, queremos ver la pronunciación de Typst. Una de las mejores formas de transcribir la pronunciación es el Alfabeto Fonético Internacional (AFI, o IPA por sus siglas en inglés). Pero como usa caracteres que no se encuentran en los teclados comunes, escribir IPA repetidamente puede volverse engorroso. Entonces, definamos una variable a la que podamos hacer referencia varias veces.

```typ
#let ipa = [taɪpst]
```

Acá usamos una palabra clave nueva, `{let}`, para indicar la definición de una variable. Después ponemos el nombre de nuestra variable, en este caso, `ipa`. Por último, escribimos un signo igual y el valor de nuestra variable. Va entre corchetes porque es contenido, igual que cuando llamás a una función que acepta contenido. En otras palabras, esta sintaxis refleja la frase _"Sea la variable `ipa` con el valor `{[taɪpst]}`."_

Ahora podemos usar la variable en nuestro documento:

```example
#let ipa = [taɪpst]

La forma canónica de
pronunciar Typst es #ipa.

#table(
  columns: (1fr, 1fr),
  [Nombre], [Typst],
  [Pronunciación], ipa,
)
```

En el ejemplo podés ver que la variable se puede usar tanto en el marcado (con el prefijo `#`) como en una llamada a función (escribiendo solo su nombre). Por supuesto, podemos cambiar el valor de la variable y todas sus apariciones van a cambiar automáticamente. Hagamos un poco más claro qué es IPA y qué es prosa normal, mostrando el IPA en cursiva. También usamos barras, que por convención suelen encerrar el IPA.

```example
#let ipa = text(
  style: "italic",
<<< )[/taɪpst/]
>>> box[/taɪpst/])

La forma canónica de
pronunciar Typst es #ipa.

#table(
  columns: (1fr, 1fr),
  [Nombre], [Typst],
  [Pronunciación], ipa,
)
```

Acá llamamos a la función text y asignamos su _valor de retorno_ a la variable. Cuando llamás a una función, ella procesa sus argumentos y después devuelve otro valor (a menudo, contenido). Hasta ahora, en este tutorial llamamos a la mayoría de las funciones directamente en el marcado, así: `[#text(fill: red)[CRIMSON!]]`. Esta llamada a la función text devuelve el texto rojo como valor de retorno. Como la pusimos en el marcado, su valor de retorno se insertó de inmediato en el contenido que escribimos. Con las variables, en cambio, podemos guardarlo para usarlo más tarde o componerlo con otros valores.

Las variables no se limitan a guardar contenido: pueden guardar cualquier tipo de dato que Typst conozca. A lo largo de este tutorial usaste muchos tipos de datos cuando se los pasaste a las funciones incorporadas de Typst. Este es un ejemplo que asigna cada uno de ellos a una variable:

```typ
// Contenido con marcado adentro
#let blind-text = [_Lorem ipsum_ dolor sit amet]

// Cadenas de texto sin formato
#let funny-font = "MS Comic Sans"

// Longitudes absolutas (mirá también pt, in, ...)
#let mile = 160934cm

// Longitudes relativas al tamaño de la fuente
#let double-space = 2em

// Proporciones
#let progress = 80%

// Números enteros
#let answer = 42

// Booleanos
#let truth = false

// Alineación horizontal y vertical
#let focus = center
```

En este capítulo del tutorial vas a aprovechar las variables y tus propias funciones para construir plantillas que se puedan reutilizar en varios documentos.

= #short-or-long[Plantilla de juguete][Una plantilla de juguete] <toy-template>
En Typst, las plantillas son funciones en las que podés envolver todo tu documento. Para aprender a hacerlo, primero repasemos cómo escribir tus propias funciones. Pueden hacer lo que quieras, así que ¿por qué no volvernos un poco locos?

```example
#let amazed(term) = box[✨ #term ✨]

Sos #amazed[genial]!
```

Si comparás esto con la sección anterior, quizás notaste que se parece mucho a una definición de variable con `{let}`. Tu instinto es correcto: las funciones son simplemente otro tipo de dato. Acá definimos la variable `amazed` y le asignamos una función que toma un solo argumento, `term`, y devuelve contenido con el `term` rodeado de destellos. También pusimos todo dentro de un @box para que el término que nos asombra no pueda separarse de sus destellos por un salto de línea. La sintaxis especial de definición de funciones hace la definición más corta y legible, pero también podés usar la sintaxis normal de definición de variables (mirá @reference:scripting:bindings[la referencia de scripting] para más detalles). Después de su definición, podemos llamar a la función igual que a todas las funciones incorporadas.

Muchas de las funciones que vienen con Typst tienen parámetros con nombre opcionales. Nuestras funciones también pueden tenerlos. Agreguemos a nuestra función un parámetro que nos permita elegir el color del texto. Tenemos que proporcionar un color por defecto por si no se indica el parámetro.

```example
#let amazed(term, color: blue) = {
  text(color, box[✨ #term ✨])
}

Sos #amazed[genial]!
Esto es #amazed(color: purple)[asombroso]!
```

Las plantillas ahora funcionan envolviendo todo nuestro documento en una función personalizada como `amazed`. ¡Pero envolver un documento entero en una llamada a una función gigante sería engorroso! En cambio, podemos usar una regla show de "todo" para lograr lo mismo con un código más limpio. Para escribir una regla show así, poné dos puntos justo después de la palabra clave show y proporcioná una función. A esta función se le pasa el resto del documento como parámetro. La función puede hacer entonces lo que quiera con ese contenido. Como la función `amazed` se puede llamar con un único argumento de contenido, podemos simplemente pasarla por nombre a la regla show. Probémoslo:

```example
>>> #let amazed(term, color: blue) = {
>>>   text(color, box[✨ #term ✨])
>>> }
#show: amazed
Elijo concentrarme en lo bueno
de mi vida y soltar cualquier
pensamiento o creencia negativa.
De hecho, ¡soy increíble!
```

Ahora todo nuestro documento se va a pasar a la función `amazed`, como si la hubiéramos envuelto alrededor de él. Por supuesto, esto no es especialmente útil con esta función en particular, pero combinado con reglas set y argumentos con nombre puede ser muy potente.

= #short-or-long[Reglas set y show][Incorporar reglas set y show] <set-and-show-rules>
Para aplicar algunas reglas set y show a nuestra plantilla, podemos usar `set` y `show` dentro de un bloque de contenido en nuestra función y después insertar el documento en ese bloque de contenido.

```example
#let template(doc) = [
  #set text(font: "Inria Serif")
  #show "algo genial": [Typst]
  #doc
]

#show: template
Hoy estoy aprendiendo algo genial.
¡Hasta ahora viene yendo muy bien!
```

Igual que ya descubrimos en el capítulo anterior, las reglas set se aplican a todo lo que está dentro de su bloque de contenido. Como la regla show de "todo" le pasa nuestro documento completo a la función `template`, la regla set de text y la regla show de cadena de nuestra plantilla se aplican a todo el documento. Usemos este conocimiento para crear una plantilla que reproduzca el estilo del cuerpo del trabajo que escribimos en el capítulo anterior.

```example
#let conf(title, doc) = {
  set page(
    paper: "us-letter",
>>> margin: auto,
    header: align(
      right + horizon,
      title
    ),
>>> numbering: "1",
    columns: 2,
<<<     ...
  )
  set par(justify: true)
  set text(
    font: "Libertinus Serif",
    size: 11pt,
  )

  // Reglas show de los títulos.
<<<   ...
>>> show heading.where(level: 1): set align(center)
>>> show heading.where(level: 1): set text(size: 13pt, weight: "regular")
>>> show heading.where(level: 1): smallcaps
>>>
>>> show heading.where(level: 2): set text(
>>>   size: 11pt,
>>>   weight: "regular",
>>>   style: "italic",
>>> )
>>> show heading.where(
>>>   level: 2
>>> ): it => {
>>>   it.body + [.]
>>> }

  doc
}

#show: doc => conf(
  [Título del trabajo],
  doc,
)

= Introducción
<<< ...
>>> #lorem(90)
>>>
>>> == Motivación
>>> #lorem(140)
>>>
>>> == Planteo del problema
>>> #lorem(50)
>>>
>>> = Trabajos relacionados
>>> #lorem(200)
```

Copiamos y pegamos la mayor parte de ese código del capítulo anterior. Las dos diferencias son estas:

+ Envolvimos todo en la función `conf` usando una regla show de "todo". La función aplica algunas reglas set y show y, al final, devuelve el contenido que recibió.

+ Además, usamos un bloque de código entre llaves en lugar de un bloque de contenido. De esta manera, no necesitamos poner el prefijo `#` a todas las reglas set y llamadas a funciones. A cambio, ya no podemos escribir marcado directamente en el bloque de código.

Fijate también de dónde viene el título: antes lo teníamos dentro de una variable. Ahora lo recibimos como primer parámetro de la función de la plantilla. Para hacerlo, le pasamos una clausura (es decir, una función sin nombre que se usa de inmediato) a la regla show de "todo". Lo hicimos porque la función `conf` espera dos argumentos posicionales, el título y el cuerpo, pero la regla show solo pasa el cuerpo. Por lo tanto, agregamos una nueva definición de función que nos permite establecer el título del trabajo y usar el único parámetro de la regla show.

= #short-or-long[Argumentos con nombre][Plantillas con argumentos con nombre] <named-arguments>
Nuestro trabajo del capítulo anterior tenía un título y una lista de autores. Podemos mantener el título como metadato de @document, pero nuestra plantilla también debería aceptar una lista de autores con sus filiaciones y el resumen del trabajo. Los vamos a agregar como argumentos con nombre. Al final, queremos que funcione así:

```typ
#set document(title: [
  Un modelo de dinámica de fluidos para
  el flujo glaciar
])

#show: doc => conf(
  authors: (
    (
      name: "Theresa Tungsten",
      affiliation: "Instituto Artos",
      email: "tung@artos.edu",
    ),
    (
      name: "Eugene Deklan",
      affiliation: "Honduras State",
      email: "e.deklan@hstate.hn",
    ),
  ),
  abstract: lorem(80),
  doc,
)

...
```

Construyamos esta nueva función de plantilla. El título se puede mostrar con la función @title y se accede a él mediante `document.title`, así que la plantilla solo necesita los parámetros con nombre `authors` y `abstract`, con valores por defecto vacíos. A continuación, copiamos en la plantilla el código que genera el título, el resumen y los autores del capítulo anterior, reemplazando los datos fijos por los parámetros.

El nuevo parámetro `authors` espera un @array[array] de @dictionary[diccionarios] con las claves `name`, `affiliation` y `email`. Como podemos tener una cantidad arbitraria de autores, determinamos dinámicamente si necesitamos una, dos o tres columnas para la lista de autores. Primero, determinamos la cantidad de autores usando el método @array.len[`.len()`] sobre el array `authors`. Después, establecemos la cantidad de columnas como el mínimo entre esa cantidad y tres, de modo que nunca creemos más de tres columnas. Si hay más de tres autores, se inserta una fila nueva. Para eso, también agregamos un parámetro `row-gutter` a la función `grid`. De lo contrario, las filas quedarían demasiado juntas. Para extraer los datos de los autores del diccionario, usamos la @reference:scripting:fields[sintaxis de acceso a campos].

Todavía tenemos que proporcionar un argumento a la grilla por cada autor: acá es donde resulta útil el @array.map[método `map`] del array. Toma como argumento una función que se llama con cada elemento del array. Le pasamos una función que da formato a los datos de cada autor y devuelve un nuevo array con valores de contenido. Ahora tenemos un array de valores que queremos usar como múltiples argumentos de la grilla. Podemos hacerlo con el @arguments[operador `spread`]. Toma un array y aplica cada uno de sus elementos como un argumento separado de la función.

La función de plantilla resultante se ve así:

```typ
#let conf(
  authors: (),
  abstract: [],
  doc,
) = {
  // Las reglas set y show de antes.
  // ...

  place(
    top + center,
    float: true,
    scope: "parent",
    clearance: 2em,
    {
      title()

      let count = authors.len()
      let ncols = calc.min(count, 3)
      grid(
        columns: (1fr,) * ncols,
        row-gutter: 24pt,
        ..authors.map(author => [
          #author.name \
          #author.affiliation \
          #link("mailto:" + author.email)
        ]),
      )

      par(justify: false)[
        *Resumen* \
        #abstract
      ]

    }
  )

  doc
}
```

= #short-or-long[Archivo separado][Un archivo separado] <separate-file>
La mayoría de las veces, una plantilla se especifica en otro archivo y luego se importa en el documento. De este modo, el archivo principal en el que escribís se mantiene ordenado y tu plantilla se reutiliza fácilmente. Creá un archivo de texto nuevo en el panel de archivos haciendo clic en el botón de más y llamalo `conf.typ`. Mové la definición de la función `conf` dentro de ese archivo nuevo. Ahora podés acceder a ella desde tu archivo principal agregando una importación antes de la regla show. Especificá la ruta del archivo entre la palabra clave `{import}` y dos puntos, y después nombrá la función que querés importar.

Otra cosa que podés hacer para que aplicar plantillas sea un poco más elegante es usar el método @function.with[`.with`] de las funciones para completar de antemano todos los argumentos con nombre. De esta manera, evitás escribir una clausura y agregar el argumento de contenido al final de la lista de tu plantilla. Las plantillas de #link("https://typst.app/universe")[Typst Universe] están diseñadas para funcionar con este estilo de llamada a función.

#example(
  single: true,
  ```
  >>> #let conf(
  >>>   authors: (),
  >>>   abstract: [],
  >>>   doc,
  >>> ) = {
  >>>   set page(
  >>>     "us-letter",
  >>>     margin: auto,
  >>>     header: align(
  >>>       right + horizon,
  >>>       context document.title,
  >>>     ),
  >>>     numbering: "1",
  >>>     columns: 2,
  >>>   )
  >>>   set par(justify: true)
  >>>   set text(font: "Libertinus Serif", 11pt)
  >>>   show title: set text(size: 17pt)
  >>>   show title: set align(center)
  >>>   show title: set block(below: 1.2em)
  >>>
  >>>   show heading.where(level: 1): set align(center)
  >>>   show heading.where(level: 1): set text(size: 13pt, weight: "regular")
  >>>   show heading.where(level: 1): smallcaps
  >>>
  >>>   show heading.where(level: 2): set text(
  >>>     size: 11pt,
  >>>     weight: "regular",
  >>>     style: "italic",
  >>>   )
  >>>   show heading.where(
  >>>     level: 2
  >>>   ): it => {
  >>>     it.body + [.]
  >>>   }
  >>>
  >>>   show heading.where(
  >>>     level: 2
  >>>   ): it => text(
  >>>     size: 11pt,
  >>>     weight: "regular",
  >>>     style: "italic",
  >>>     it.body + [.],
  >>>   )
  >>>
  >>>   place(
  >>>     top + center,
  >>>     float: true,
  >>>     scope: "parent",
  >>>     clearance: 2em,
  >>>     {
  >>>       title()
  >>>
  >>>       let count = authors.len()
  >>>       let ncols = calc.min(count, 3)
  >>>       grid(
  >>>         columns: (1fr,) * ncols,
  >>>         row-gutter: 24pt,
  >>>         ..authors.map(author => [
  >>>           #author.name \
  >>>           #author.affiliation \
  >>>           #link("mailto:" + author.email)
  >>>         ]),
  >>>       )
  >>>
  >>>       par(justify: false)[
  >>>         *Resumen* \
  >>>         #abstract
  >>>       ]
  >>>     }
  >>>   )
  >>>
  >>>   doc
  >>> }
  <<< #import "conf.typ": conf

  #set document(title: [
    Un modelo de dinámica de fluidos para
    el flujo glaciar
  ])

  #show: conf.with(
    authors: (
      (
        name: "Theresa Tungsten",
        affiliation: "Instituto Artos",
        email: "tung@artos.edu",
      ),
      (
        name: "Eugene Deklan",
        affiliation: "Honduras State",
        email: "e.deklan@hstate.hn",
      ),
    ),
    abstract: lorem(80),
  )

  = Introduction
  #lorem(90)

  == Motivación
  #lorem(140)

  == Planteo del problema
  #lorem(50)

  = Trabajos relacionados
  #lorem(200)
  ```
)

¡Ya convertimos el trabajo de la conferencia en una plantilla reutilizable para esa conferencia! ¿Por qué no compartirla en el #link("https://forum.typst.app/")[foro] o en el #link("https://discord.gg/2uDybryKPe")[servidor de Discord de Typst] para que otros también puedan usarla?

= Review <review>
¡Felicitaciones, completaste el tutorial de Typst! En esta sección aprendiste a definir tus propias funciones y a crear y aplicar plantillas que definen estilos de documento reutilizables. Llegaste lejos y aprendiste mucho. Ahora podés usar Typst para escribir tus propios documentos y compartirlos con otros.

Todavía somos un proyecto muy joven y estamos buscando comentarios. Si tenés preguntas, sugerencias o encontraste un error, contanos en el #link("https://forum.typst.app/")[foro], en nuestro #link("https://discord.gg/2uDybryKPe")[servidor de Discord], en #link("https://github.com/typst/typst/")[GitHub] o mediante el formulario de comentarios de la app web (siempre disponible en el menú Ayuda).

¿Y entonces qué estás esperando? #link("https://typst.app")[Registrate] ¡y escribí algo!
