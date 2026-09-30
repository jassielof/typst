#import "../../components/index.typ": (
  docs-chapter, docs-figure, info, short-or-long,
)

#show: docs-chapter.with(
  title: "Escribir en Typst",
  route: "/tutorial/writing-in-typst",
  description: "Tutorial de Typst.",
)

¡Empecemos! Supongamos que te asignaron escribir un informe técnico para la universidad. Va a tener prosa, matemática, títulos y figuras. Para arrancar, creás un proyecto nuevo en la app de Typst. Vas a llegar al editor, donde ves dos paneles: un panel de código, donde componés tu documento, y un panel de vista previa, donde ves el documento renderizado.

#docs-figure(
  "1-writing-app.png",
  alt: "Captura de pantalla de la app de Typst",
  shadow: false,
)

Ya tenés un buen enfoque para tu informe. Así que empecemos escribiendo la introducción. Ingresá algo de texto en el panel del editor. Vas a notar que el texto aparece de inmediato en la página de la vista previa.

```example
In this report, we will explore the
various factors that influence fluid
dynamics in glaciers and how they
contribute to the formation and
behaviour of these natural structures.
```

_A lo largo de este tutorial, vamos a mostrar ejemplos de código como este. Igual que en la app, el primer panel contiene el marcado y el segundo muestra una vista previa. Achicamos la página para que entren los ejemplos y puedas ver lo que pasa._

El siguiente paso es agregar un título y resaltar algo de texto. Typst usa un marcado simple para las tareas de formato más comunes. Para agregar un título, escribí el carácter `=`, y para resaltar texto en cursiva, encerralo entre `[_underscores_]`.

```example
= Introduction
In this report, we will explore the
various factors that influence _fluid
dynamics_ in glaciers and how they
contribute to the formation and
behaviour of these natural structures.
```

¡Qué fácil! Para agregar un párrafo nuevo, simplemente dejá una línea en blanco entre dos líneas de texto. Si ese párrafo necesita un subtítulo, lo generás escribiendo `==` en lugar de `=`. La cantidad de caracteres `=` determina el nivel de anidación del título.

Ahora queremos enumerar algunas de las circunstancias que influyen en la dinámica de los glaciares. Para eso usamos una lista numerada. Para cada ítem de la lista, escribimos un carácter `+` al principio de la línea. Typst numera los ítems automáticamente.

```example
+ The climate
+ The topography
+ The geology
```

Si quisiéramos agregar una lista con viñetas, usaríamos el carácter `-` en lugar del carácter `+`. También podemos anidar listas: por ejemplo, podemos agregar una sublista al primer ítem de la lista anterior indentándola.

```example
+ The climate
  - Temperature
  - Precipitation
+ The topography
+ The geology
```

= #short-or-long[Figura][Agregar una figura] <figure>
Pensás que tu informe se beneficiaría con una figura. Agreguemos una. Typst admite imágenes en los formatos PNG, JPEG, GIF, SVG, PDF y WebP. Para agregar un archivo de imagen a tu proyecto, primero abrí el _panel de archivos_ haciendo clic en el ícono de la caja en la barra lateral izquierda. Ahí ves la lista de todos los archivos de tu proyecto. Por ahora hay uno solo: el archivo principal de Typst en el que estás escribiendo. Para subir otro archivo, hacé clic en el botón con la flecha en la esquina superior derecha. Se abre el diálogo de carga, en el que podés elegir los archivos de tu computadora que querés subir. Seleccioná un archivo de imagen para tu informe.

#docs-figure(
  "1-writing-upload.png",
  alt: "Diálogo de carga",
  shadow: false,
)

Ya vimos que ciertos símbolos (llamados _marcado_) tienen un significado específico en Typst. Podemos usar `=`, `-`, `+` y `_` para crear títulos, listas y texto resaltado, respectivamente. Sin embargo, tener un símbolo especial para todo lo que queremos insertar en el documento se volvería enseguida críptico y engorroso. Por eso, Typst reserva los símbolos de marcado solo para las cosas más comunes. Todo lo demás se inserta con _funciones._ Para que nuestra imagen aparezca en la página, usamos la función @image de Typst.

```example
#image("glacier.jpg")
```

En general, una función produce algún resultado a partir de un conjunto de _argumentos_. Cuando _llamás_ a una función dentro del marcado, le pasás los argumentos y Typst inserta el resultado (el _valor de retorno_ de la función) en el documento. En nuestro caso, la función `image` toma un solo argumento: la ruta del archivo de imagen. Para llamar a una función en el marcado, primero escribimos el carácter `#`, seguido inmediatamente del nombre de la función. Después, encerramos los argumentos entre paréntesis. Typst reconoce muchos tipos de datos distintos en las listas de argumentos. Nuestra ruta de archivo es una @str[cadena de texto] corta, así que tenemos que encerrarla entre comillas dobles.

La imagen insertada ocupa todo el ancho de la página. Para cambiar eso, pasale el argumento `width` a la función `image`. Es un argumento _con nombre_ y, por lo tanto, se especifica como un par `name: value`. Si hay varios argumentos, se separan con comas, así que primero tenemos que poner una coma después de la ruta.

```example
#image("glacier.jpg", width: 70%)
```

El argumento `width` es una @relative[longitud relativa]. En nuestro caso, especificamos un porcentaje, que determina que la imagen ocupe el `{70%}` del ancho de la página. También podríamos haber especificado un valor absoluto como `{1cm}` o `{0.7in}`.

Igual que el texto, la imagen queda alineada a la izquierda de la página por defecto. Además, le falta un epígrafe. Arreglemos eso con la función @figure[figure]. Esta función toma el contenido de la figura como argumento posicional y un epígrafe opcional como argumento con nombre.

Dentro de la lista de argumentos de la función `figure`, Typst ya está en modo código. Esto significa que ahora tenés que sacar el numeral antes de la llamada a la función image. El numeral solo hace falta directamente en el marcado (para distinguir el texto de las llamadas a funciones).

El epígrafe consiste en marcado arbitrario. Para pasarle marcado a una función, lo encerramos entre corchetes. Esta construcción se llama _bloque de contenido._

```example
#figure(
  image("glacier.jpg", width: 70%),
  caption: [
    _Glaciers_ form an important part
    of the earth's climate system.
  ],
)
```

Seguís escribiendo tu informe y ahora querés hacer referencia a la figura. Para eso, primero adjuntale una etiqueta a la figura. Una etiqueta identifica de forma única un elemento de tu documento. Agregá una después de la figura encerrando algún nombre entre paréntesis angulares. Después podés referenciar la figura en tu texto escribiendo un símbolo `[@]` seguido de ese nombre. Los títulos y las ecuaciones también se pueden etiquetar para que sean referenciables.

```example
Glaciers as the one shown in
@glaciers will cease to exist if
we don't take action soon!

#figure(
  image("glacier.jpg", width: 70%),
  caption: [
    _Glaciers_ form an important part
    of the earth's climate system.
  ],
) <glaciers>
```

#info[
  Hasta ahora, les pasamos a nuestras funciones bloques de contenido (marcado entre corchetes) y cadenas de texto (texto entre comillas dobles). Los dos parecen contener texto. ¿Cuál es la diferencia?

  Un bloque de contenido puede contener texto, pero también cualquier otro tipo de marcado, llamadas a funciones y más, mientras que una cadena es simplemente una _secuencia de caracteres_ y nada más.

  Por ejemplo, la función image espera una ruta a un archivo de imagen. No tendría sentido pasarle, por ejemplo, un párrafo de texto u otra imagen como ruta de la imagen. Por eso acá solo se permiten cadenas. En cambio, las cadenas funcionan en cualquier lugar donde se espere contenido, porque el texto es un tipo válido de contenido.
]

= #short-or-long[Bibliography][Adding a bibliography] <bibliography>
As you write up your report, you need to back up some of your claims. You can add a bibliography to your document with the @bibliography function. This function expects a path to a bibliography file.

Typst's native bibliography format is #link("https://github.com/typst/hayagriva/blob/main/docs/file-format.md")[Hayagriva], but for compatibility you can also use BibLaTeX files. As your classmate has already done a literature survey and sent you a `.bib` file, you'll use that one. Upload the file through the file panel to access it in Typst.

Once the document contains a bibliography, you can start citing from it. Citations use the same syntax as references to a label. As soon as you cite a source for the first time, it will appear in the bibliography section of your document. Typst supports different citation and bibliography styles. Consult the @bibliography.style[reference] for more details.

```example
= Methods
We follow the glacier melting models
established in @glacier-melt.

#bibliography("works.bib")
```

= Maths <maths>
After fleshing out the methods section, you move on to the meat of the document: Your equations. Typst has built-in mathematical typesetting and uses its own math notation. Let's start with a simple equation. We wrap it in `[$]` signs to let Typst know it should expect a mathematical expression:

```example
The equation $Q = rho A v + C$
defines the glacial flow rate.
```

The equation is typeset inline, on the same line as the surrounding text. If you want to have it on its own line instead, you should insert a single space at its start and end:

```example
The flow rate of a glacier is
defined by the following equation:

$ Q = rho A v + C $
```

We can see that Typst displayed the single letters `Q`, `A`, `v`, and `C` as-is, while it translated `rho` into a Greek letter. Math mode will always show single letters verbatim. Multiple letters, however, are interpreted as symbols, variables, or function names. To imply a multiplication between single letters, put spaces between them.

If you want to have a variable that consists of multiple letters, you can enclose it in quotes:

```example
The flow rate of a glacier is given
by the following equation:

$ Q = rho A v + "time offset" $
```

You'll also need a sum formula in your paper. We can use the `sum` symbol and then specify the range of the summation in sub- and superscripts:

```example
Total displaced soil by glacial flow:

$ 7.32 beta +
  sum_(i=0)^nabla Q_i / 2 $
```

To add a subscript to a symbol or variable, type a `_` character and then the subscript. Similarly, use the `^` character for a superscript. If your sub- or superscript consists of multiple things, you must enclose them in round parentheses.

The above example also showed us how to insert fractions: Simply put a `/` character between the numerator and the denominator and Typst will automatically turn it into a fraction. Parentheses are smartly resolved, so you can enter your expression as you would into a calculator and Typst will replace parenthesized sub-expressions with the appropriate notation.

```example
Total displaced soil by glacial flow:

$ 7.32 beta +
  sum_(i=0)^nabla
    (Q_i (a_i - epsilon)) / 2 $
```

Not all math constructs have special syntax. Instead, we use functions, just like the `image` function we have seen before. For example, to insert a column vector, we can use the @math.vec[`vec`] function. Within math mode, function calls don't need to start with the `#` character.

```example
$ v := vec(x_1, x_2, x_3) $
```

Some functions are only available within math mode. For example, the @math.cal[`cal`] function is used to typeset calligraphic letters commonly used for sets. The @math[math section of the reference] provides a complete list of all functions that math mode makes available.

One more thing: Many symbols, such as the arrow, have a lot of variants. You can select among these variants by appending a dot and a modifier name to a symbol's name:

```example
$ a arrow.squiggly b $
```

This notation is also available in markup mode, but the symbol name must be preceded with `#sym.` there. See the @sym[symbols section] for a list of all available symbols.

= Review <review>
You have now seen how to write a basic document in Typst. You learned how to emphasize text, write lists, insert images, align content, and typeset mathematical expressions. You also learned about Typst's functions. There are many more kinds of content that Typst lets you insert into your document, such as @table[tables], @reference:visualize[shapes], and @raw[code blocks]. You can peruse the @reference[reference] to learn more about these and other features.

For the moment, you have completed writing your report. You have already saved a PDF by clicking on the download button in the top right corner. However, you think the report could look a bit less plain. In the next section, we'll learn how to customize the look of our document.
