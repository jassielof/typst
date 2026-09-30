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
En este informe, exploraremos los
diversos factores que influyen en la
dinámica de fluidos en los glaciares
y cómo contribuyen a la formación y
al comportamiento de estas
estructuras naturales.
```

_A lo largo de este tutorial, vamos a mostrar ejemplos de código como este. Igual que en la app, el primer panel contiene el marcado y el segundo muestra una vista previa. Achicamos la página para que entren los ejemplos y puedas ver lo que pasa._

El siguiente paso es agregar un título y resaltar algo de texto. Typst usa un marcado simple para las tareas de formato más comunes. Para agregar un título, escribí el carácter `=`, y para resaltar texto en cursiva, encerralo entre `[_underscores_]`.

```example
= Introducción
En este informe, exploraremos los
diversos factores que influyen en la
_dinámica de fluidos_ en los glaciares
y cómo contribuyen a la formación y
al comportamiento de estas
estructuras naturales.
```

¡Qué fácil! Para agregar un párrafo nuevo, simplemente dejá una línea en blanco entre dos líneas de texto. Si ese párrafo necesita un subtítulo, lo generás escribiendo `==` en lugar de `=`. La cantidad de caracteres `=` determina el nivel de anidación del título.

Ahora queremos enumerar algunas de las circunstancias que influyen en la dinámica de los glaciares. Para eso usamos una lista numerada. Para cada ítem de la lista, escribimos un carácter `+` al principio de la línea. Typst numera los ítems automáticamente.

```example
+ El clima
+ La topografía
+ La geología
```

Si quisiéramos agregar una lista con viñetas, usaríamos el carácter `-` en lugar del carácter `+`. También podemos anidar listas: por ejemplo, podemos agregar una sublista al primer ítem de la lista anterior indentándola.

```example
+ El clima
  - Temperatura
  - Precipitación
+ La topografía
+ La geología
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
    Los _glaciares_ son una parte importante
    del sistema climático de la Tierra.
  ],
)
```

Seguís escribiendo tu informe y ahora querés hacer referencia a la figura. Para eso, primero adjuntale una etiqueta a la figura. Una etiqueta identifica de forma única un elemento de tu documento. Agregá una después de la figura encerrando algún nombre entre paréntesis angulares. Después podés referenciar la figura en tu texto escribiendo un símbolo `[@]` seguido de ese nombre. Los títulos y las ecuaciones también se pueden etiquetar para que sean referenciables.

```example
¡Glaciares como el que se muestra en
@glaciers dejarán de existir si
no actuamos pronto!

#figure(
  image("glacier.jpg", width: 70%),
  caption: [
    Los _glaciares_ son una parte importante
    del sistema climático de la Tierra.
  ],
) <glaciers>
```

#info[
  Hasta ahora, les pasamos a nuestras funciones bloques de contenido (marcado entre corchetes) y cadenas de texto (texto entre comillas dobles). Los dos parecen contener texto. ¿Cuál es la diferencia?

  Un bloque de contenido puede contener texto, pero también cualquier otro tipo de marcado, llamadas a funciones y más, mientras que una cadena es simplemente una _secuencia de caracteres_ y nada más.

  Por ejemplo, la función image espera una ruta a un archivo de imagen. No tendría sentido pasarle, por ejemplo, un párrafo de texto u otra imagen como ruta de la imagen. Por eso acá solo se permiten cadenas. En cambio, las cadenas funcionan en cualquier lugar donde se espere contenido, porque el texto es un tipo válido de contenido.
]

= #short-or-long[Bibliografía][Agregar una bibliografía] <bibliography>
Mientras escribís tu informe, necesitás respaldar algunas de tus afirmaciones. Podés agregar una bibliografía a tu documento con la función @bibliography. Esta función espera la ruta de un archivo de bibliografía.

El formato nativo de bibliografía de Typst es #link("https://github.com/typst/hayagriva/blob/main/docs/file-format.md")[Hayagriva], pero, por compatibilidad, también podés usar archivos BibLaTeX. Como tu compañero ya hizo un relevamiento bibliográfico y te mandó un archivo `.bib`, vas a usar ese. Subí el archivo desde el panel de archivos para acceder a él en Typst.

Una vez que el documento contiene una bibliografía, podés empezar a citarla. Las citas usan la misma sintaxis que las referencias a una etiqueta. Apenas citás una fuente por primera vez, aparece en la sección de bibliografía de tu documento. Typst admite distintos estilos de citas y de bibliografía. Consultá la @bibliography.style[referencia] para más detalles.

```example
= Métodos
Seguimos los modelos de derretimiento
de glaciares establecidos en @glacier-melt.

#bibliography("works.bib")
```

= Matemática <maths>
Después de desarrollar la sección de métodos, pasás a lo central del documento: tus ecuaciones. Typst tiene composición matemática integrada y usa su propia notación matemática. Empecemos con una ecuación simple. La encerramos entre signos `[$]` para que Typst sepa que tiene que esperar una expresión matemática:

```example
La ecuación $Q = rho A v + C$
define el caudal glacial.
```

La ecuación se compone en línea, en la misma línea que el texto que la rodea. Si en cambio querés que quede en su propia línea, tenés que insertar un solo espacio al principio y al final:

```example
El caudal de un glaciar está
definido por la siguiente ecuación:

$ Q = rho A v + C $
```

Podemos ver que Typst mostró las letras sueltas `Q`, `A`, `v` y `C` tal cual, mientras que tradujo `rho` a una letra griega. El modo matemático siempre muestra las letras sueltas literalmente. En cambio, las secuencias de varias letras se interpretan como símbolos, variables o nombres de funciones. Para indicar una multiplicación entre letras sueltas, poné espacios entre ellas.

Si querés tener una variable formada por varias letras, podés encerrarla entre comillas:

```example
El caudal de un glaciar está dado
por la siguiente ecuación:

$ Q = rho A v + "desfase temporal" $
```

También vas a necesitar una fórmula de sumatoria en tu trabajo. Podemos usar el símbolo `sum` y después especificar el rango de la sumatoria en subíndices y superíndices:

```example
Total de suelo desplazado por el flujo glacial:

$ 7.32 beta +
  sum_(i=0)^nabla Q_i / 2 $
```

Para agregar un subíndice a un símbolo o variable, escribí un carácter `_` y después el subíndice. De manera similar, usá el carácter `^` para un superíndice. Si tu subíndice o superíndice está formado por varias cosas, tenés que encerrarlas entre paréntesis.

El ejemplo anterior también nos mostró cómo insertar fracciones: simplemente poné un carácter `/` entre el numerador y el denominador, y Typst lo convierte automáticamente en una fracción. Los paréntesis se resuelven de forma inteligente, así que podés ingresar tu expresión como lo harías en una calculadora y Typst reemplaza las subexpresiones entre paréntesis por la notación adecuada.

```example
Total de suelo desplazado por el flujo glacial:

$ 7.32 beta +
  sum_(i=0)^nabla
    (Q_i (a_i - epsilon)) / 2 $
```

No todas las construcciones matemáticas tienen una sintaxis especial. En su lugar, usamos funciones, igual que la función `image` que vimos antes. Por ejemplo, para insertar un vector columna, podemos usar la función @math.vec[`vec`]. Dentro del modo matemático, las llamadas a funciones no necesitan empezar con el carácter `#`.

```example
$ v := vec(x_1, x_2, x_3) $
```

Algunas funciones solo están disponibles dentro del modo matemático. Por ejemplo, la función @math.cal[`cal`] se usa para componer letras caligráficas, que se usan comúnmente para conjuntos. La @math[sección de matemática de la referencia] ofrece una lista completa de todas las funciones que el modo matemático pone a disposición.

Una cosa más: muchos símbolos, como la flecha, tienen muchas variantes. Podés elegir entre estas variantes agregando un punto y el nombre de un modificador al nombre del símbolo:

```example
$ a arrow.squiggly b $
```

Esta notación también está disponible en el modo marcado, pero ahí el nombre del símbolo tiene que estar precedido por `#sym.`. Mirá la @sym[sección de símbolos] para ver una lista de todos los símbolos disponibles.

= Repaso <review>
Ya viste cómo escribir un documento básico en Typst. Aprendiste a resaltar texto, escribir listas, insertar imágenes, alinear contenido y componer expresiones matemáticas. También aprendiste sobre las funciones de Typst. Hay muchos más tipos de contenido que Typst te permite insertar en tu documento, como @table[tablas], @reference:visualize[formas] y @raw[bloques de código]. Podés recorrer la @reference[referencia] para aprender más sobre estas y otras características.

Por el momento, terminaste de escribir tu informe. Ya guardaste un PDF haciendo clic en el botón de descarga de la esquina superior derecha. Sin embargo, pensás que el informe podría verse un poco menos simple. En la próxima sección, vamos a aprender a personalizar el aspecto de tu documento.
