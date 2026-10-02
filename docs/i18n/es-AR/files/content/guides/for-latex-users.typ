#import "../../components/index.typ": (
  docs-chapter, docs-table, example, info, short-or-long,
)

#show: docs-chapter.with(
  title: "Guía para usuarios de LaTeX",
  route: "/guides/for-latex-users",
  description: "¿Sos usuario de LaTeX? Esta guía explica las diferencias y similitudes entre Typst y LaTeX para que puedas empezar rápidamente.",
)

Esta página es un buen punto de partida si ya usaste LaTeX y querés probar Typst. Vamos a explorar las principales diferencias entre estos dos sistemas desde la perspectiva del usuario. Aunque Typst no está construido sobre LaTeX y tiene una sintaxis distinta, vas a aprender a aprovechar tus conocimientos de LaTeX para arrancar con ventaja.

Igual que LaTeX, Typst es un sistema de composición tipográfica basado en marcado: componés tu documento en un archivo de texto y lo marcás con comandos y otra sintaxis. Después usás un compilador para componer el archivo fuente en un PDF. Sin embargo, Typst también se diferencia de LaTeX en varios aspectos: por un lado, Typst usa una sintaxis más dedicada (como la que quizás conozcas de Markdown) para las tareas comunes. Los comandos de Typst también son más coherentes: todos funcionan de la misma manera, así que, a diferencia de LaTeX, solo necesitás entender unos pocos conceptos generales en lugar de aprender convenciones distintas para cada paquete. Además, Typst compila más rápido que LaTeX: la compilación suele tardar milisegundos, no segundos, por lo que tanto la app web como el compilador pueden ofrecer vistas previas instantáneas.

A continuación, vamos a cubrir algunas de las preguntas más comunes que tendrá un usuario que pasa de LaTeX al componer un documento en Typst. Si preferís una introducción paso a paso a Typst, mirá nuestro @tutorial[tutorial].

= Instalación <installation>
Tenés dos formas de usar Typst: en #link("https://typst.app/signup/")[nuestra app web] o #link("https://github.com/typst/typst/releases")[instalando el compilador] en tu computadora. Cuando usás la app web, ofrecemos un editor colaborativo con todo incluido y ejecutamos Typst en tu navegador, sin necesidad de instalación.

Si en cambio elegís usar Typst en tu computadora, podés descargar el compilador como un único binario pequeño que cualquier usuario puede ejecutar, sin necesidad de privilegios de administrador. A diferencia de las distribuciones populares de LaTeX, como TeX Live, los paquetes se descargan la primera vez que los usás y después se guardan en caché localmente, lo que mantiene liviana tu instalación de Typst. Con el compilador local, podés usar tu propio editor y decidir dónde guardar tus archivos.

= #short-or-long[Cómo empezar][¿Cómo creo un documento nuevo y vacío?] <getting-started>
Es fácil. Simplemente creás un archivo de texto nuevo y vacío (la extensión del archivo es `.typ`). No hace falta ningún código base para empezar. Simplemente empezá escribiendo tu texto. Se compondrá en una página A4 vacía. Si usás la app web, hacé clic en "+ Empty document" para crear un proyecto nuevo con un archivo y entrar al editor. Los @parbreak[saltos de párrafo] funcionan igual que en LaTeX: simplemente usá una línea en blanco.

```example
Hey there!

Here are two paragraphs. The
output is shown to the right.
```

Si en cambio querés partir de un documento LaTeX preexistente, podés usar #link("https://pandoc.org")[Pandoc] para convertir tu código fuente a marcado de Typst. Esta conversión también está integrada en nuestra app web, así que podés subir tu archivo `.tex` para empezar tu proyecto en Typst.

= #short-or-long[Elementos][¿Cómo creo títulos de sección, énfasis, ...?] <elements>
LaTeX usa el comando `\section` para crear un título de sección. Los títulos anidados se indican con `\subsection`, `\subsubsection`, etcétera. Según tu clase de documento, también existe `\part` o `\chapter`.

En Typst, los @heading[títulos] son menos verbosos: le ponés como prefijo a la línea del título un signo igual y un espacio para obtener un título de primer orden: `[= Introduction]`. Si necesitás un título de segundo orden, usás dos signos igual: `[== In this paper]`. Podés anidar títulos tan profundamente como quieras agregando más signos igual.

El énfasis (que normalmente se renderiza como texto en cursiva) se expresa encerrando el texto entre `[_underscores_]` y el énfasis fuerte (que normalmente se renderiza en negrita) usando en cambio `[*stars*]`.

Esta es una lista de comandos de marcado comunes usados en LaTeX y sus equivalentes en Typst. También podés consultar la @reference:syntax[hoja de referencia completa de la sintaxis].

#docs-table(
  table.header[Elemento][LaTeX][Typst][Ver],

  [Énfasis fuerte],
  [`\textbf{strong}`],
  [`[*strong*]`],
  [@strong],

  [Énfasis],
  [`\emph{emphasis}`],
  [`[_emphasis_]`],
  [@emph],

  [Enlace],
  [`\url{https://typst.app}`],
  [`[https://typst.app/]`],
  [@link],

  [Etiqueta],
  [`\label{intro}`],
  [`[<intro>]`],
  [@label],

  [Referencia],
  [`\ref{intro}`],
  [`[@intro]`],
  [@ref],

  [Cita],
  [`\cite{humphrey97}`],
  [`[@humphrey97]`],
  [@cite],

  [Monoespaciado (máquina de escribir)],
  [`\texttt{mono}`],
  [funciones `text` o `mono`],
  [@text, @math.mono[`mono`]],

  [Código],
  [entorno `lstlisting`],
  [``` [`print(f"{x}")`]```],
  [@raw],

  [Literal],
  [entorno `verbatim`],
  [``` [`#typst-code()`]```],
  [@raw],

  [Lista con viñetas],
  [entorno `itemize`],
  [`[- List]`],
  [@list],

  [Lista numerada],
  [entorno `enumerate`],
  [`[+ List]`],
  [@enum],

  [Lista de términos],
  [entorno `description`],
  [`[/ Term: List]`],
  [@terms],

  [Figura],
  [entorno `figure`],
  [función `figure`],
  [@figure],

  [Tabla],
  [entorno `table`],
  [función `table`],
  [@table],

  [Ecuación],
  [`$x$`, entornos `align` / `equation`],
  [`[$x$]`, `[$ x = y $]`],
  [@math.equation[`equation`]],
)

Las @list[listas] no dependen de entornos en Typst. En cambio, tienen una sintaxis liviana como los títulos. Para crear una lista sin orden (`itemize`), poné como prefijo de cada línea de un elemento un guion:

````example
To write this list in Typst...

```latex
\begin{itemize}
  \item Fast
  \item Flexible
  \item Intuitive
\end{itemize}
```

...just type this:

- Fast
- Flexible
- Intuitive

````

Anidar listas funciona simplemente usando la sangría adecuada. Agregar una línea en blanco entre los elementos da como resultado una lista con un espaciado más @list.tight[amplio].

Para obtener en cambio una @enum[lista numerada] (`enumerate`), usá un `+` en lugar del guion. Para una @terms[lista de términos] (`description`), escribí `[/ Term: Description]`.

Tené en cuenta que la @raw[función `raw`] y su sintaxis (por ejemplo, ``` [`raw`]```) solo funcionan para texto literal (sin formato). Si necesitás formato, podés usar en cambio la @text[función `text`] con una fuente monoespaciada, como en el siguiente ejemplo:

```example
#text(
  font: "DejaVu Sans Mono",
  size: 0.8em,
)[monospace *bold*]
```

= #short-or-long[Comandos][¿Cómo uso un comando?] <commands>
LaTeX depende mucho de los comandos (con prefijo de barra invertida). Usa estas _macros_ para afectar el proceso de composición y para insertar y manipular contenido. Algunos comandos aceptan argumentos, que con mayor frecuencia van entre llaves: `\cite{rasmus}`.

Typst distingue entre el @reference:scripting:blocks[modo marcado y el modo código]. El modo por defecto es el modo marcado, donde componés texto y aplicás construcciones sintácticas como `[*stars for bold text*]`. El modo código, en cambio, es paralelo a los lenguajes de programación como Python y ofrece la opción de ingresar y ejecutar segmentos de código.

Dentro del marcado de Typst, podés cambiar al modo código para un único comando (o, mejor dicho, _expresión_) usando un numeral (`#`). Así es como llamás a funciones para, por ejemplo, dividir tu proyecto en distintos @reference:scripting:modules[archivos] o renderizar texto según alguna @reference:scripting:conditionals[condición]. Dentro del modo código, es posible incluir @content[_contenido_] de marcado normal usando corchetes. Dentro del modo código, este contenido se trata igual que cualquier otro valor normal de una variable.

```example
First, a rectangle:
#rect()

Let me show how to do
#underline([_underlined_ text])

We can also do some maths:
#calc.max(3, 2 * 4)

And finally a little loop:
#for x in range(3) [
  Hi #x.
]
```

Una llamada a función siempre involucra el nombre de la función (@rect, @underline, @calc.max, @array.range[`range`]) seguido de paréntesis (a diferencia de LaTeX, donde los corchetes y las llaves son opcionales si la macro no requiere argumentos). La lista de argumentos esperada que se pasa dentro de esos paréntesis depende de la función concreta y está especificada en la @reference[referencia].

== Argumentos <arguments>
Una función puede tener varios argumentos. Algunos argumentos son posicionales, es decir, simplemente proporcionás el valor: la función `[#lower("SCREAM")]` devuelve su argumento en minúsculas. Muchas funciones usan argumentos con nombre en lugar de argumentos posicionales para aumentar la legibilidad. Por ejemplo, las dimensiones y el trazo de un rectángulo se definen con argumentos con nombre:

```example
#rect(
  width: 2cm,
  height: 1cm,
  stroke: red,
)
```

Un argumento con nombre se especifica ingresando primero su nombre (arriba, `width`, `height` y `stroke`), después dos puntos y, a continuación, el valor (`2cm`, `1cm`, `red`). Podés encontrar los argumentos con nombre disponibles en la @reference[página de referencia] de cada función o en el panel de autocompletado al escribir. Los argumentos con nombre son similares a cómo se configuran algunos entornos de LaTeX; por ejemplo, escribirías `\begin{enumerate}[label={\alph*)}]` para empezar una lista con las etiquetas `a)`, `b)`, etcétera.

A menudo querés proporcionarle algo de @content[contenido] a una función. Por ejemplo, el comando de LaTeX `\underline{Alternative A}` se traduciría en Typst como `[#underline([Alternative A])]`. Los corchetes indican que un valor es @content[contenido]. Dentro de estos corchetes, podés usar marcado normal. Sin embargo, son muchos paréntesis para una construcción bastante simple. Por eso también podés mover los argumentos de contenido finales después de los paréntesis (y omitir los paréntesis si quedarían vacíos).

```example
Typst is an #underline[alternative]
to LaTeX.

#rect(fill: aqua)[Get started here!]
```

== Tipos de datos <data-types>
Probablemente ya notaste que los argumentos tienen tipos de datos distintivos. Typst admite muchos @type[tipos de datos]. A continuación hay una tabla con algunos de los más importantes y cómo escribirlos. ¡Para especificar valores de cualquiera de estos tipos, tenés que estar en modo código!

#docs-table(
  table.header[Tipo de dato][Ejemplo],

  [@content[Contenido]],
  [`{[*fast* typesetting]}`],

  [@str[Cadena de texto]],
  [`{"Pietro S. Author"}`],

  [@int[Entero]],
  [`{23}`],

  [@float[Número de punto flotante]],
  [`{1.459}`],

  [@length[Longitud absoluta]],
  [`{12pt}`, `{5in}`, `{0.3cm}`, ...],

  [@ratio[Longitud relativa]],
  [`{65%}`],
)

La diferencia entre contenido y cadena de texto es que el contenido puede contener marcado, incluidas llamadas a funciones, mientras que una cadena de texto es realmente solo una secuencia simple de caracteres.

Typst ofrece @reference:scripting:conditionals[construcciones de control de flujo] y @reference:scripting:operators[operadores] como `+` para sumar cosas o `==` para comprobar la igualdad entre dos variables.

También podés guardar valores, incluidas funciones, en tus propias @reference:scripting:bindings[variables]. Esto puede ser útil para realizar cálculos con ellos, crear automatizaciones reutilizables o hacer referencia a un valor varias veces. El enlace de variables se logra con la palabra clave let, que funciona de forma similar a `\newcommand`:

```example
// Store the integer `5`.
#let five = 5

// Define a function that
// increments a value.
#let inc(i) = i + 1

// Reference the variables.
I have #five fingers.

If I had one more, I'd have
#inc(five) fingers. Whoa!
```

== #short-or-long[Reglas][Comandos que afectan al resto del documento] <rules>
En LaTeX, algunos comandos como `\textbf{bold text}` reciben un argumento entre llaves y solo lo afectan a él. Otros comandos, como `\bfseries bold text`, actúan como interruptores (LaTeX los llama declaraciones) y alteran el aspecto de todo el contenido posterior dentro del documento o del ámbito actual.

En Typst, la misma función se puede usar tanto para afectar el aspecto del resto del documento, de un bloque (o ámbito) o solo de sus argumentos. Por ejemplo, `[#text(weight: "bold")[bold text]]` solo pondrá en negrita su argumento, mientras que `[#set text(weight: "bold")]` pondrá en negrita todo el texto hasta el final del bloque actual o hasta el final del documento, si no hay ninguno. Los efectos de una función quedan de inmediato en evidencia según se use en una llamada o en una @reference:styling:set-rules[regla set.]

```example
I am starting out with small text.

#set text(14pt)

This is a bit #text(18pt)[larger,]
don't you think?
```

Las reglas set pueden aparecer en cualquier parte del documento. Se pueden pensar como valores por defecto de los argumentos de su función respectiva:

```example
#set enum(numbering: "I.")

Good results can only be obtained by
+ following best practices
+ being aware of current results
  of other researchers
+ checking the data for biases
```

El `+` es azúcar sintáctico (pensalo como una abreviatura) para una llamada a la función @enum[`{enum}`], a la que arriba le aplicamos una regla set. @reference:syntax[La mayor parte de la sintaxis está vinculada de esta manera a una función.] Si necesitás dar estilo a un elemento más allá de lo que permiten sus argumentos, podés redefinir por completo su aspecto con una @reference:styling:show-rules[regla show] (algo comparable a `\renewcommand`).

Podés lograr los efectos de comandos de LaTeX como `\textbf`, `\textsf`, `\rmfamily`, `\mdseries` e `\itshape` con los argumentos @text.font[`font`], @text.style[`style`] y @text.weight[`weight`] de la función `text`. La función text se puede usar en una regla set (estilo declaración) o con un argumento de contenido. Para reemplazar `\textsc`, podés usar la función @smallcaps, que renderiza su argumento de contenido en versalitas. Si querés usarla al estilo declaración (como `\scshape`), podés usar una @reference:styling:show-rules[regla show de _todo_] que aplique la función al resto del ámbito:

```example
#show: smallcaps

Boisterous Accusations
```

= #short-or-long[Plantillas][¿Cómo cargo una clase de documento?] <templates>
En LaTeX, empezás tu archivo `.tex` principal con el comando `\documentclass{article}` para definir cómo debe verse tu documento. En ese comando, quizás hayas reemplazado `article` por otro valor, como `report` o `amsart`, para seleccionar otro aspecto.

Al usar Typst, das estilo a tus documentos con @function[funciones]. Normalmente usás una plantilla que ofrece una función que da estilo a todo tu documento. Primero importás la función desde un archivo de plantilla. Después la aplicás a todo tu documento. Esto se logra con una @reference:styling:show-rules[regla show] que envuelve el documento siguiente en una función dada. El siguiente ejemplo ilustra cómo funciona:

#example(
  single: true,
  ```
  >>> #let conf(
  >>>   title: none,
  >>>   authors: (),
  >>>   abstract: [],
  >>>   doc,
  >>> ) = {
  >>>   set text(font: "Libertinus Serif", 11pt)
  >>>   set par(justify: true)
  >>>   set page(
  >>>     "us-letter",
  >>>     margin: auto,
  >>>     header: align(
  >>>       right + horizon,
  >>>       title
  >>>     ),
  >>>     numbering: "1",
  >>>     columns: 2
  >>>   )
  >>>
  >>>   show heading.where(
  >>>     level: 1
  >>>   ): it => block(
  >>>     align(center,
  >>>       text(
  >>>         13pt,
  >>>         weight: "regular",
  >>>         smallcaps(it.body),
  >>>       )
  >>>     ),
  >>>   )
  >>>   show heading.where(
  >>>     level: 2
  >>>   ): it => box(
  >>>     text(
  >>>       11pt,
  >>>       weight: "regular",
  >>>       style: "italic",
  >>>       it.body + [.],
  >>>     )
  >>>   )
  >>>
  >>>   place(top, float: true, scope: "parent", {
  >>>     set align(center)
  >>>     text(17pt, title)
  >>>
  >>>     let count = calc.min(authors.len(), 3)
  >>>     grid(
  >>>       columns: (1fr,) * count,
  >>>       row-gutter: 24pt,
  >>>       ..authors.map(author => [
  >>>         #author.name \
  >>>         #author.affiliation \
  >>>         #link("mailto:" + author.email)
  >>>       ]),
  >>>     )
  >>>
  >>>     par(justify: false)[
  >>>       *Abstract* \
  >>>       #abstract
  >>>     ]
  >>>   })
  >>>
  >>>   set align(left)
  >>>   doc
  >>> }
  <<< #import "conf.typ": conf
  #show: conf.with(
    title: [
      Towards Improved Modelling
    ],
    authors: (
      (
        name: "Theresa Tungsten",
        affiliation: "Artos Institute",
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

  Let's get started writing this
  article by putting insightful
  paragraphs right here!
  >>> #lorem(500)
  ```
)

La sentencia @reference:scripting:modules[`{import}`] pone a disposición @function[funciones] (y otras definiciones) de otro archivo. En este ejemplo, importa la función `conf` del archivo `conf.typ`. Esta función da formato a un documento como un artículo de conferencia. Usamos una regla show para aplicarla al documento y también configurar algunos metadatos del artículo. Después de aplicar la regla show, ¡podemos empezar a escribir nuestro artículo de inmediato!

También podés usar plantillas de Typst Universe (el equivalente de CTAN en Typst) con una sentencia de importación como esta: `[#import "@preview/elsearticle:0.2.1": elsearticle]`. Consultá la documentación de cada plantilla para conocer el nombre de su función de plantilla. Las plantillas y los paquetes de Typst Universe se descargan automáticamente la primera vez que los usás.

En la app web, podés elegir crear un proyecto a partir de una plantilla de Typst Universe o incluso crear la tuya con el asistente de plantillas. De forma local, podés usar la CLI `typst init` para crear un proyecto nuevo a partir de una plantilla. Mirá la #link("https://typst.app/universe/search/?kind=templates")[lista de plantillas] publicadas en Typst Universe. También podés echarle un vistazo al #link("https://github.com/qjcg/awesome-typst")[repositorio `awesome-typst`] para encontrar plantillas de la comunidad que no están disponibles a través de Universe.

También podés @tutorial:making-a-template[crear tus propias plantillas personalizadas.] Son más cortas y más legibles que los archivos `.sty` de LaTeX correspondientes por órdenes de magnitud, ¡así que probalo!

#info[
  Las funciones son los "comandos" de Typst y pueden transformar sus argumentos en un valor de salida, incluido _contenido_ del documento. Las funciones son "puras", lo que significa que no pueden tener ningún efecto más allá de crear un valor / contenido de salida. Esto contrasta marcadamente con las macros de LaTeX, que pueden tener efectos arbitrarios sobre tu documento.

  Para que una función dé estilo a todo tu documento, la regla show procesa todo lo que viene después y llama a la función especificada después de los dos puntos con el resultado como argumento. La parte `.with` es un _método_ que toma la función `conf` y preconfigura algunos de sus argumentos antes de pasársela a la regla show.
]

= #short-or-long[Paquetes][¿Cómo cargo paquetes?] <packages>
Typst viene con "todo incluido", así que el equivalente de muchos paquetes populares de LaTeX está integrado. A continuación armamos una tabla con los paquetes que se cargan con frecuencia y sus funciones correspondientes de Typst.

#docs-table(
  table.header[Paquete de LaTeX][Alternativa en Typst],

  [graphicx, svg],
  [función @image],

  [tabularx, tabularray],
  [funciones @table, @grid],

  [fontenc, inputenc, unicode-math],
  [¡Simplemente empezá a escribir!],

  [babel, polyglossia],
  [función @text.lang[`text`]: `[#set text(lang: "zh")]`],

  [amsmath],
  [@math[Modo matemático]],

  [amsfonts, amssymb],
  [módulo @reference:symbols[`sym`] y @reference:syntax:math[sintaxis]],

  [geometry, fancyhdr],
  [función @page],

  [xcolor],
  [función @text.fill[`text`]: `[#set text(fill: rgb("#0178A4"))]`],

  [hyperref],
  [función @link],

  [bibtex, biblatex, natbib],
  [funciones @cite, @bibliography],

  [lstlisting, minted],
  [función y sintaxis @raw],

  [parskip],
  [funciones @block.spacing[`block`] y @par.first-line-indent[`par`]],

  [csquotes],
  [Establecé el idioma en @text.lang[`text`] y escribí `["]` o `[']`],

  [caption],
  [función @figure],

  [enumitem],
  [funciones @list, @enum, @terms],

  [nicefrac],
  [propiedad @math.frac.style[`frac.style`]],
)

Aunque _muchas_ cosas están integradas, no todo puede estarlo. Por eso Typst tiene su propio #link("https://typst.app/universe")[ecosistema de paquetes], donde la comunidad comparte sus creaciones y automatizaciones. Tomemos, por ejemplo, el paquete _CeTZ_: este paquete te permite crear dibujos y gráficos complejos. Para usar CeTZ en tu documento, simplemente podés escribir:

```typ
#import "@preview/cetz:0.4.1"
```

(El `@preview` es un _espacio de nombres_ que se usa mientras el gestor de paquetes todavía está en un estado temprano y experimental. Se reemplazará en el futuro.)

Además del centro oficial de paquetes, también podés echarle un vistazo al #link("https://github.com/qjcg/awesome-typst")[repositorio awesome-typst], que reúne una lista curada de recursos creados para Typst.

Si necesitás cargar funciones y variables de otro archivo de tu proyecto, por ejemplo para usar una plantilla, podés usar la misma sentencia @reference:scripting:modules[`import`] con un nombre de archivo en lugar de una especificación de paquete. Para en cambio incluir el contenido textual de otro archivo, podés usar una sentencia @reference:scripting:modules[`include`]. Obtendrá el contenido del archivo especificado y lo pondrá en tu documento.

= #short-or-long[Matemática][¿Cómo escribo matemática?] <maths>
Para entrar en el modo matemático en Typst, simplemente encerrá tu ecuación entre signos de pesos. Podés entrar en el modo de visualización (display) agregando espacios o saltos de línea entre el contenido de la ecuación y los signos de pesos que la encierran.

```example
The sum of the numbers from
$1$ to $n$ is:

$ sum_(k=1)^n k = (n(n+1))/2 $
```

El @math[modo matemático] funciona de manera distinta que el marcado normal o el modo código. Los números y los caracteres sueltos se muestran literalmente, mientras que varios caracteres consecutivos (que no sean números) se interpretarán como variables de Typst.

Typst predefine muchas variables útiles en modo matemático. Todas las letras griegas (`alpha`, `beta`, ...) y algunas hebreas (`aleph`, `beth`, ...) están disponibles por su nombre. Algunos símbolos también están disponibles mediante atajos, como `<=`, `>=` y `->`.

Consultá las @reference:symbols[páginas de símbolos] para ver la lista completa de símbolos. Si falta un símbolo, también podés acceder a él mediante una @reference:syntax:escapes[secuencia de escape Unicode].

Las formas alternativas y relacionadas de los símbolos a menudo se pueden seleccionar @symbol[agregando un modificador] después de un punto. Por ejemplo, `arrow.l.squiggly` inserta una flecha ondulada que apunta hacia la izquierda. Si en cambio querés insertar texto de varias letras en tu expresión, encerralo entre comillas dobles:

```example
$ delta "if" x <= 5 $
```

En Typst, los delimitadores se escalan automáticamente según sus expresiones, igual que si se insertaran implícitamente los comandos `\left` y `\right` en LaTeX. Podés personalizar el comportamiento de los delimitadores con la @math.lr[función `lr`]. Para evitar que un par de delimitadores se escale, podés escaparlos con barras invertidas.

Typst compondrá automáticamente como fracción los términos alrededor de una barra `/`, respetando la precedencia de operadores. Todos los paréntesis redondos que la fracción no vuelva redundantes aparecerán en la salida. Las fracciones se componen verticalmente, salvo que se personalicen con @math.frac.style[`frac.style`]. También podés producir una barra tal cual escapándola con una barra invertida (`\/`).

```example
$ f(x) = (x + 1) / x $
```

Los @math.attach[subíndices y superíndices] funcionan de manera similar en Typst y en LaTeX. `{$x^2$}` produce un superíndice y `{$x_2$}` da un subíndice. Si querés incluir más de un valor en un subíndice o superíndice, encerrá su contenido entre paréntesis: `{$x_(a -> epsilon)$}`.

Como las variables en modo matemático no necesitan un `#` como prefijo (ni una `\` como en LaTeX), también podés llamar a funciones sin estos caracteres especiales:

```example
$ f(x, y) := cases(
  1 "if" (x dot y)/2 <= 0,
  2 "if" x "is even",
  3 "if" x in NN,
  4 "else",
) $
```

El ejemplo anterior usa la @math.cases[función `cases`] para describir f. Dentro de la función cases, los argumentos se delimitan con comas y los argumentos también se interpretan como matemática. Si necesitás en cambio interpretar los argumentos como valores de Typst, ponéles un `#` como prefijo:

```example
$ (a + b)^2
  = a^2
  + text(fill: #maroon, 2 a b)
  + b^2 $
```

Podés usar todas las funciones de Typst dentro del modo matemático e insertar cualquier contenido. Si querés que funcionen normalmente, con el modo código en la lista de argumentos, podés poner un `#` como prefijo de su llamada. Ya nadie puede impedirte usar rectángulos o emojis como tus variables:

```example
$ sum^10_(🤓=1)
  #rect(width: 4mm, height: 2mm)/🤓
  = 🧠 maltese $
```

Si querés ingresar tus símbolos matemáticos directamente como Unicode, ¡eso también es posible!

Las llamadas matemáticas pueden tener listas de argumentos bidimensionales usando `;` como delimitador. El uso más común es la @math.mat[función `mat`], que crea matrices:

```example
$ mat(
  1, 2, ..., 10;
  2, 2, ..., 10;
  dots.v, dots.v, dots.down, dots.v;
  10, 10, ..., 10;
) $
```

= #short-or-long[Aspecto LaTeX][¿Cómo consigo el "aspecto LaTeX"?] <latex-look>
Los trabajos compuestos en LaTeX tienen un aspecto inconfundible. Esto se debe sobre todo a su fuente, Computer Modern, a la justificación, al interlineado ajustado y a los márgenes amplios.

El siguiente ejemplo
- establece @page.margin[márgenes] amplios
- habilita la @par.justify[justificación], las @par.leading[líneas más juntas] y la @par.first-line-indent[sangría de primera línea]
- @text.font[establece la fuente] "New Computer Modern", un derivado OpenType de Computer Modern, tanto para el texto como para los @raw[bloques de código]
- reduce el @text.weight[peso de la fuente] en el modo matemático
- desactiva el @block.spacing[espaciado] de párrafo
- aumenta el @block.spacing[espaciado] alrededor de los @heading[títulos]

```typ
#set page(margin: 1.75in)
#set par(leading: 0.55em, spacing: 0.55em, first-line-indent: 1.8em, justify: true)
#set text(font: "New Computer Modern")
#show raw: set text(font: "New Computer Modern Mono")
#show math.equation: set text(weight: "regular")
#show heading: set block(above: 1.4em, below: 1em)
```

¡Este debería ser un buen punto de partida! Si querés ir más allá, ¿por qué no crear una plantilla reutilizable?

= Bibliografías <bibliographies>
Typst incluye un sistema de bibliografía completo que es compatible con archivos BibTeX. Podés seguir usando tus bibliotecas de literatura `.bib` cargándolas con la función @bibliography. Otra posibilidad es usar el #link("https://github.com/typst/hayagriva/blob/main/docs/file-format.md")[formato nativo de Typst basado en YAML].

Typst usa Citation Style Language para definir y procesar los estilos de citas y bibliografía. Podés comparar los archivos CSL con los archivos `.bbx` de BibLaTeX. El compilador ya incluye @bibliography.style[más de 80 estilos de citas], pero podés usar cualquier estilo compatible con CSL del #link("https://github.com/citation-style-language/styles")[repositorio de CSL] o escribir el tuyo.

Podés citar una entrada de tu bibliografía o hacer referencia a una etiqueta de tu documento con la misma sintaxis: `[@key]` (esto haría referencia a una entrada llamada `key`). Como alternativa, podés usar la función @cite.

Las formas alternativas de tu cita, como solo el año y las citas para uso natural en prosa (cf. `\citet` y `\textcite`), están disponibles con @cite.form[`[#cite(<key>, form: "prose")]`].

Podés encontrar más información en la página de documentación de la función @bibliography.

= #short-or-long[Limitaciones][¿Qué limitaciones tiene Typst actualmente en comparación con LaTeX?] <limitations>
Aunque hoy Typst puede reemplazar a LaTeX para muchas personas, todavía hay características que Typst (aún) no admite. Esta es una lista de ellas que, cuando corresponde, contiene posibles soluciones alternativas.

- *Un ecosistema de gráficos bien establecido.* Los usuarios de LaTeX a menudo crean gráficos elaborados junto con sus documentos en PGF/TikZ. El ecosistema de Typst todavía no ofrece la misma amplitud de opciones disponibles, pero el ecosistema alrededor del #link("https://typst.app/universe/package/cetz")[paquete `cetz`] se está poniendo al día rápidamente.

- *Cambiar los márgenes de página sin un salto de página.* En LaTeX, los márgenes siempre se pueden ajustar, incluso sin un salto de página. Para cambiar los márgenes en Typst, usás la @page[función `page`], que fuerza un salto de página. Si solo querés que unos pocos párrafos se extiendan hacia los márgenes y luego volver a los márgenes anteriores, podés usar la @pad[función `pad`] con relleno negativo.
