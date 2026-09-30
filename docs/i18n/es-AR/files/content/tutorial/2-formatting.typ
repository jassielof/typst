#import "../../components/index.typ": (
  docs-chapter, docs-figure, info, kbd, short-or-long,
)

#show: docs-chapter.with(
  title: "Formato",
  route: "/tutorial/formatting",
  description: "Tutorial de Typst.",
)

Hasta ahora escribiste un informe con algo de texto, unas cuantas ecuaciones e imágenes. Sin embargo, todavía se ve muy simple. Tu docente auxiliar aún no sabe que estás usando un nuevo sistema de composición tipográfica, y querés que tu informe encaje con las entregas del resto de los estudiantes. En este capítulo vamos a ver cómo dar formato a tu informe con el sistema de estilos de Typst.

= Reglas set <set-rules>
Como vimos en el capítulo anterior, Typst tiene funciones que _insertan_ contenido (por ejemplo, la función @image) y otras que _manipulan_ el contenido que reciben como argumentos (por ejemplo, la función @align). El primer impulso que podrías tener cuando querés, por ejemplo, cambiar la fuente, es buscar una función que lo haga y envolver el documento completo con ella.

```example
#text(font: "New Computer Modern")[
  = Antecedentes
  En el caso de los glaciares, se pueden
  usar los principios de la dinámica de
  fluidos para entender cómo el movimiento
  y el comportamiento del hielo están
  influidos por factores como la
  temperatura, la presión y la presencia
  de otros fluidos (como el agua).
]
```

Un momento: ¿no deberían especificarse todos los argumentos de una función entre paréntesis? ¿Por qué hay un segundo par de corchetes con contenido _después_ de los paréntesis? La respuesta es que, como pasarle contenido a una función es algo tan común en Typst, hay una sintaxis especial para eso: en lugar de poner el contenido dentro de la lista de argumentos, podés escribirlo entre corchetes justo después de los argumentos normales, ahorrando puntuación.

Como vimos arriba, eso funciona. Con la función @text podemos ajustar la fuente de todo el texto que contiene. Sin embargo, envolver el documento en innumerables funciones y aplicar estilos de forma selectiva y puntual puede volverse engorroso rápidamente.

Por suerte, Typst tiene una solución más elegante. Con las _reglas set,_ podés aplicar propiedades de estilo a todas las apariciones de un tipo de contenido. Una regla set se escribe con la palabra clave `{set}`, seguida del nombre de la función cuyas propiedades querés establecer y una lista de argumentos entre paréntesis.

```example
#set text(
  font: "New Computer Modern"
)

= Antecedentes
En el caso de los glaciares, se pueden
usar los principios de la dinámica de
fluidos para entender cómo el movimiento
y el comportamiento del hielo están
influidos por factores como la
temperatura, la presión y la presencia
de otros fluidos (como el agua).
```

#info[
  ¿Querés saber en términos más técnicos qué está pasando acá?

  Las reglas set se pueden concebir como la definición de valores por defecto para algunos de los parámetros de una función, para todos los usos futuros de esa función.
]

= #short-or-long[Autocompletado][El panel de autocompletado] <autocomplete>
Si seguiste el tutorial y probaste algunas cosas en la app, es posible que hayas notado que siempre que ingresás un carácter `#` aparece un panel que te muestra las funciones disponibles y, dentro de una lista de argumentos, los parámetros disponibles. Ese es el panel de autocompletado. Puede ser muy útil mientras escribís tu documento: podés aplicar sus sugerencias presionando la tecla Enter o navegar hasta la opción deseada con las flechas. El panel se puede cerrar presionando la tecla Escape y volver a abrir escribiendo `#` o presionando #kbd("Ctrl") + #kbd("Espacio"). Usá el panel de autocompletado para descubrir los argumentos correctos de las funciones. La mayoría de las sugerencias vienen con una pequeña descripción de lo que hacen.

#docs-figure(
  "2-formatting-autocomplete.png",
  alt: "Panel de autocompletado",
  shadow: false,
)

= #short-or-long[Configurar página][Configurar la página] <page-setup>
Volviendo a las reglas set: cuando escribís una regla, elegís la función según el tipo de elemento al que querés darle estilo. Esta es una lista de algunas funciones que se usan comúnmente en las reglas set:

- @text para establecer la familia de fuente, el tamaño, el color y otras propiedades del texto
- @page para establecer el tamaño de página, los márgenes, los encabezados, activar columnas y los pies de página
- @par para justificar párrafos, establecer el interlineado y más
- @heading para establecer el aspecto de los títulos y activar la numeración
- @document para establecer los metadatos que contiene el PDF de salida, como el título y el autor

No todos los parámetros de una función se pueden establecer. En general, solo se pueden establecer los parámetros que le dicen a una función _cómo_ hacer algo, no los que le dicen _con qué_ hacerlo. Las páginas de referencia de las funciones indican qué parámetros son configurables.

Agreguemos algunos estilos más a nuestro documento. Queremos márgenes más grandes y una fuente con serifas. A los fines del ejemplo, también vamos a establecer otro tamaño de página.

```example
#set page(
  paper: "a6",
  margin: (x: 1.8cm, y: 1.5cm),
)
#set text(
  font: "New Computer Modern",
  size: 10pt
)
#set par(
  justify: true,
  leading: 0.52em,
)

= Introducción
En este informe, exploraremos los
diversos factores que influyen en la
dinámica de fluidos en los glaciares
y cómo contribuyen a la formación y
al comportamiento de estas
estructuras naturales.

>>> El desplazamiento de un glaciar está
>>> influido por varios factores, entre ellos
>>> + El clima
>>> + La topografía
>>> + La geología
>>>
>>> Este informe presentará un modelo
>>> físico del desplazamiento y la dinámica
>>> de los glaciares, y explorará la
>>> influencia de estos factores en el
>>> movimiento de grandes masas de hielo.
<<< ...

#align(center + bottom)[
  #image("glacier.jpg", width: 70%)

  *Los glaciares son una parte
  importante del sistema
  climático de la Tierra.*
]
```

Hay algunas cosas para destacar acá.

Primero, la regla set de @page. Recibe dos argumentos: el tamaño de la página y los márgenes. El tamaño de página es una cadena de texto. Typst acepta @page.paper[muchos tamaños de página estándar,] pero también podés especificar un tamaño personalizado. Los márgenes se especifican como un @dictionary[diccionario.] Los diccionarios son colecciones de pares clave-valor. En este caso, las claves son `x` e `y`, y los valores son los márgenes horizontal y vertical, respectivamente. También podríamos haber especificado márgenes separados para cada lado pasando un diccionario con las claves `{left}`, `{right}`, `{top}` y `{bottom}`.

Lo siguiente es la regla set de @text. Acá establecemos el tamaño de fuente en `{10pt}` y la familia de fuente en `{"New Computer Modern"}`. La app de Typst viene con muchas fuentes que podés probar en tu documento. Cuando estás dentro de la lista de argumentos de la función text, podés descubrir las fuentes disponibles en el panel de autocompletado.

También establecimos el espaciado entre líneas (también llamado interlineado o _leading_): se especifica como un valor de @length[longitud], y usamos la unidad `em` para indicar el interlineado relativo al tamaño de la fuente: `{1em}` equivale al tamaño de fuente actual (que por defecto es `{11pt}`).

Por último, alineamos la imagen abajo agregando una alineación vertical a nuestra alineación centrada. Las alineaciones vertical y horizontal se pueden combinar con el operador `{+}` para obtener una alineación 2D.

= #short-or-long[Sofisticación][Un toque de sofisticación] <sophistication>
Para estructurar nuestro documento con más claridad, ahora queremos numerar los títulos. Podemos hacerlo estableciendo el parámetro `numbering` de la función @heading.

```example
>>> #set text(font: "New Computer Modern")
#set heading(numbering: "1.")

= Introducción
#lorem(10)

== Antecedentes
#lorem(12)

== Métodos
#lorem(15)
```

Especificamos la cadena `{"1."}` como parámetro numbering. Esto le indica a Typst que numere los títulos con números arábigos y que ponga un punto entre el número de cada nivel. También podemos usar @numbering[letras, números romanos y símbolos] para nuestros títulos:

```example
>>> #set text(font: "New Computer Modern")
#set heading(numbering: "1.a")

= Introducción
#lorem(10)

== Antecedentes
#lorem(12)

== Métodos
#lorem(15)
```

Este ejemplo también usa la función @lorem para generar texto de relleno. Esta función toma un número como argumento y genera esa cantidad de palabras de texto _Lorem Ipsum_.

#info[
  ¿Te preguntaste por qué las reglas set de text y heading se aplican a todo el texto y a todos los títulos, aunque no se produzcan con las funciones respectivas?

  Typst llama internamente a la función `heading` cada vez que escribís `[= Conclusion]`. De hecho, la llamada a función `[#heading[Conclusion]]` equivale al marcado de título de arriba. Otros elementos de marcado funcionan de manera similar: son solo _azúcar sintáctico_ de las llamadas a funciones correspondientes.
]

= Reglas show <show-rules>
Ya estás bastante conforme con cómo quedó. Pero falta arreglar una última cosa: el informe que estás escribiendo es parte de un proyecto más grande, y el nombre de ese proyecto siempre tiene que ir acompañado de un logo, incluso en la prosa.

Evaluás tus opciones. Podrías agregar una llamada `[#image("logo.svg")]` antes de cada aparición del logo usando buscar y reemplazar. Eso suena muy tedioso. En cambio, quizás podrías @function:defining-functions[definir una función personalizada] que siempre devuelva el logo con su imagen. Sin embargo, hay una forma todavía más fácil:

Con las reglas show, podés redefinir cómo Typst muestra ciertos elementos. Especificás qué elementos tiene que mostrar Typst de forma diferente y cómo deben verse. Las reglas show se pueden aplicar a instancias de texto, a muchas funciones e incluso a todo el documento.

```example
#show "ArtosFlow": name => box[
  #box(image(
    "logo.svg",
    height: 0.7em,
  ))
  #name
]

Este informe está incluido en el
proyecto ArtosFlow. ArtosFlow es un
proyecto del Instituto Artos.
```

Hay mucha sintaxis nueva en este ejemplo: escribimos la palabra clave `{show}`, seguida de una cadena de texto que queremos mostrar de forma diferente y de dos puntos. Después, escribimos una función que recibe como argumento el contenido que se va a mostrar. Acá llamamos `name` a ese argumento. Ahora podemos usar la variable `name` en el cuerpo de la función para imprimir el nombre ArtosFlow. Nuestra regla show agrega la imagen del logo delante del nombre y pone el resultado en un box para evitar que se produzcan saltos de línea entre el logo y el nombre. La imagen también se pone dentro de un box, para que no aparezca en su propio párrafo.

Las llamadas a la primera función box y a la función image no necesitaron un `#` inicial porque no estaban incrustadas directamente en el marcado. Cuando Typst espera código en lugar de marcado, el `#` inicial no hace falta para acceder a funciones, palabras clave y variables. Esto se puede observar en las listas de parámetros, en las definiciones de funciones y en los @reference:scripting[bloques de código].

= Repaso <review>
Ahora sabés cómo aplicar formato básico a tus documentos de Typst. Aprendiste a establecer la fuente, justificar los párrafos, cambiar las dimensiones de la página y agregar numeración a los títulos con reglas set. También aprendiste a usar una regla show básica para cambiar cómo aparece el texto en todo tu documento.

Entregaste tu informe. ¡A tu supervisor le gustó tanto que quiere adaptarlo como un trabajo para una conferencia! En la próxima sección, vamos a aprender a dar formato a tu documento como un trabajo científico usando reglas show y funciones más avanzadas.
