#import "../../../components/index.typ": docs-chapter, docs-table, short-or-long

#show: docs-chapter.with(
  title: "Scripting",
  route: "/reference/scripting",
  description: "Automatizá tu documento con las capacidades de scripting de Typst.",
)

Typst incorpora un potente lenguaje de scripting. Podés automatizar tus documentos y crear estilos más sofisticados con código. A continuación, una descripción general de los conceptos de scripting.

= Expresiones <expressions>
En Typst, el marcado y el código están fusionados. Todos los elementos, salvo los más comunes, se crean con _funciones._ Para que esto sea lo más cómodo posible, Typst ofrece una sintaxis compacta para incrustar una expresión de código en el marcado: una expresión se introduce con un numeral (`#`) y el análisis normal del marcado se retoma cuando la expresión termina. Si un carácter continuaría la expresión pero debe interpretarse como texto, se puede terminar la expresión a la fuerza con un punto y coma (`;`). Podés @reference:syntax:escapes[escapar un `#` o un `;` literal con una barra invertida].

```example
#emph[Hello] \
#emoji.face \
#"hello".len()
```

El ejemplo anterior muestra algunas de las expresiones disponibles, incluidas las @function[llamadas a funciones], los @reference:scripting:fields[accesos a campos] y las @reference:scripting:methods[llamadas a métodos]. En el resto de este capítulo se tratan más tipos de expresiones. Algunos tipos de expresiones no son compatibles con la sintaxis del numeral (por ejemplo, las expresiones con operadores binarios). Para incrustarlas en el marcado, podés usar paréntesis, como en `[#(1 + 2)]`.

= Bloques <blocks>
Para estructurar tu código e incrustarle marcado, Typst ofrece dos tipos de _bloques:_

- *Bloque de código:* `{{ let x = 1; x + 2 }}` \
  Cuando escribís código, probablemente quieras dividir tu cómputo en varias sentencias, crear algunas variables intermedias, etcétera. Los bloques de código te permiten escribir varias expresiones donde se espera una. Las expresiones individuales de un bloque de código deben separarse con saltos de línea o punto y coma. Los valores de salida de las expresiones individuales de un bloque de código se unen para determinar el valor del bloque. Las expresiones sin salida útil, como los enlaces `{let}`, devuelven `{none}`, que se puede unir a cualquier valor sin efecto.

- *Bloque de contenido:* `{[*Hey* there!]}` \
  Con los bloques de contenido, podés manejar marcado/contenido como un valor programático, guardarlo en variables y pasarlo a @function[funciones]. Los bloques de contenido están delimitados por corchetes y pueden contener marcado arbitrario. Un bloque de contenido da como resultado un valor de tipo @content[contenido]. Se puede pasar una cantidad arbitraria de bloques de contenido como argumentos finales de funciones. Es decir, `{list([A], [B])}` equivale a `{list[A][B]}`.

Los bloques de contenido y de código se pueden anidar arbitrariamente. En el siguiente ejemplo, `{[hello ]}` se une con la salida de `{a + [ the ] + b}`, lo que da `{[hello from the *world*]}`.

```example
#{
  let a = [from]
  let b = [*world*]
  [hello ]
  a + [ the ] + b
}
```

= #short-or-long[Enlaces][Enlaces y desestructuración] <bindings>
Como ya se demostró arriba, las variables se pueden definir con enlaces `{let}`. A la variable se le asigna el valor de la expresión que sigue al signo `=`. Un @reference:syntax:identifiers[nombre de variable válido] puede contener `-`, pero no puede empezar con `-`. La asignación de un valor es opcional: si no se asigna ningún valor, la variable se inicializa como `{none}`. La palabra clave `{let}` también se puede usar para crear una @function:defining-functions[función personalizada con nombre]. Se puede acceder a las variables durante el resto del bloque que las contiene (o durante el resto del archivo, si no hay un bloque que las contenga).

```example
#let name = "Typst"
This is #name's documentation.
It explains #name.

#let my-add(x, y) = x + y
Sum is #my-add(2, 3).
```

Los enlaces let también se pueden usar para desestructurar @array[arrays] y @dictionary[diccionarios]. En ese caso, la estructura del lado izquierdo de la asignación debe reflejar el array o el diccionario: con enlaces que se corresponden por posición en los arrays y por nombre de clave en los diccionarios. El operador `..` se puede usar una vez en el patrón para recolectar el resto de los elementos del array o del diccionario.

```example
#let (x, y) = (1, 2)
The coordinates are #x, #y.

#let (a, .., b) = (1, 2, 3, 4)
The first element is #a.
The last element is #b.

#let books = (
  Shakespeare: "Hamlet",
  Homer: "The Odyssey",
  Austen: "Persuasion",
)

#let (Austen,) = books
Austen wrote #Austen.

#let (Homer: h) = books
Homer wrote #h.

#let (Homer, ..other) = books
#for (author, title) in other [
  #author wrote #title.
]
```

Podés usar el guion bajo para descartar elementos en un patrón de desestructuración:

```example
#let (_, y, _) = (1, 2, 3)
The y coordinate is #y.
```

La desestructuración también funciona en las listas de argumentos de funciones ...

```example
#let left = (2, 4, 5)
#let right = (3, 2, 6)
#left.zip(right).map(
  ((a,b)) => a + b
)
```

... y en el lado izquierdo de las asignaciones normales. Esto puede ser útil, entre otras cosas, para intercambiar variables.

```example
#{
  let a = 1
  let b = 2
  (a, b) = (b, a)
  [a = #a, b = #b]
}
```

= Condicionales <conditionals>
Con un condicional, podés mostrar o calcular cosas distintas según se cumpla o no una condición. Typst admite las expresiones `{if}`, `{else if}` y `{else}`. Cuando la condición se evalúa como `{true}`, el condicional devuelve el valor que resulta del cuerpo del if. De lo contrario, devuelve el valor que resulta del cuerpo del else.

```example
#if 1 < 2 [
  This is shown
] else [
  This is not.
]
```

Cada rama puede tener como cuerpo un bloque de código o de contenido.

- `{if condition {..}}`
- `{if condition [..]}`
- `{if condition [..] else {..}}`
- `{if condition [..] else if condition {..} else [..]}`

= Bucles <loops>
Con los bucles, podés repetir contenido o calcular algo de forma iterativa. Typst admite dos tipos de bucles: `{for}` y `{while}`. Los primeros iteran sobre una colección especificada, mientras que los segundos iteran mientras se siga cumpliendo una condición. Igual que los bloques, los bucles _unen_ los resultados de cada iteración en un solo valor.

En el siguiente ejemplo, las tres oraciones creadas por el bucle for se unen en un único valor de contenido y los arrays de longitud 1 del bucle while se unen en un array más grande.

```example
#for c in "ABC" [
  #c is a letter.
]

#let n = 2
#while n < 10 {
  n = (n * 2) - 1
  (n,)
}
```

Los bucles for pueden iterar sobre una variedad de colecciones:

- `{for value in array {..}}` \
  Itera sobre los elementos del @array[array]. Acá también se puede usar la sintaxis de desestructuración descrita en @reference:scripting:bindings[Enlace let].

- `{for pair in dict {..}}` \
  Itera sobre los pares clave-valor del @dictionary[diccionario]. Los pares también se pueden desestructurar usando `{for (key, value) in dict {..}}`. Es más eficiente que `{for pair in dict.pairs() {..}}` porque no crea un array temporal con todos los pares clave-valor.

- `{for letter in "abc" {..}}` \
  Itera sobre los caracteres de la @str[cadena de texto]. Técnicamente, itera sobre los grupos de grafemas de la cadena. La mayoría de las veces, un grupo de grafemas es un solo punto de código. Sin embargo, un grupo de grafemas puede contener varios puntos de código, como un emoji de bandera.

- `{for byte in bytes("😀") {..}}` \
  Itera sobre los @bytes[bytes], que se pueden convertir a partir de una @str[cadena de texto] o @read[leer] de un archivo sin codificación. Cada valor de byte es un @int[entero] entre `{0}` y `{255}`.

Para controlar la ejecución del bucle, Typst ofrece las sentencias `{break}` y `{continue}`. La primera sale anticipadamente del bucle, mientras que la segunda salta a la siguiente iteración.

```example
#for letter in "abc nope" {
  if letter == " " {
    break
  }

  letter
}
```

El cuerpo de un bucle puede ser un bloque de código o de contenido:

- `{for .. in collection {..}}`
- `{for .. in collection [..]}`
- `{while condition {..}}`
- `{while condition [..]}`

= Campos <fields>
Podés usar la _notación con punto_ para acceder a los campos de un valor. Para los valores de tipo @content, también podés usar la función @content.fields[`fields`] para listar los campos.

El valor en cuestión puede ser:
- un @dictionary[diccionario] que tiene la clave especificada,
- un @symbol[símbolo] que tiene el modificador especificado,
- un @module[módulo] que contiene la definición especificada,
- @content[contenido] que consiste en un elemento que tiene el campo especificado. Los campos disponibles coinciden con los argumentos de la @function:element-functions[función de elemento] que se dieron cuando se construyó el elemento.

```example
#let it = [= Heading]
#it.body \
#it.depth \
#it.fields()

#let dict = (greet: "Hello")
#dict.greet \
#emoji.face

```

= Métodos <methods>
Una _llamada a método_ es una forma cómoda de llamar a una función que pertenece al ámbito del @type[tipo] de un valor. Por ejemplo, podemos llamar a la función @str.len de las dos maneras equivalentes siguientes:

```example
#str.len("abc") is the same as
#"abc".len()
```

La estructura de una llamada a método es `{value.method(..args)}` y su llamada a función completa equivalente es `{type(value).method(value, ..args)}`. La documentación de cada tipo enumera las funciones de su ámbito. Actualmente no podés definir tus propios métodos.

```example
#let values = (1, 2, 3, 4)
#values.pop() \
#values.len() \

#("a, b, c"
    .split(", ")
    .join[ --- ])

#"abc".len() is the same as
#str.len("abc")
```

Hay algunas funciones especiales que modifican el valor sobre el que se las llama (por ejemplo, @array.push). Estas funciones _deben_ llamarse en forma de método. En algunos casos, cuando el método se llama solo por su efecto secundario, su valor de retorno se debe ignorar (y no participar en la unión). La forma canónica de descartar un valor es con un enlace let: `{let _ = array.remove(1)}`.

= Módulos <modules>
Podés dividir tus proyectos de Typst en varios archivos llamados _módulos._ Un módulo puede referirse al contenido y a las definiciones de otro módulo de varias maneras:

- *Inclusión:* `{include "bar.typ"}` \
  Evalúa el archivo en la @path[ruta] `bar.typ` y devuelve el @content[contenido] resultante.

- *Importación:* `{import "bar.typ"}` \
  Evalúa el archivo en la @path[ruta] `bar.typ` e inserta el @module[módulo] resultante en el ámbito actual como `bar` (nombre de archivo sin extensión). Podés usar la palabra clave `as` para renombrar el módulo importado: `{import "bar.typ" as baz}`. Podés importar elementos anidados con la notación con punto: `{import "bar.typ": baz.a}`.

- *Importación de elementos:* `{import "bar.typ": a, b}` \
  Evalúa el archivo en la @path[ruta] `bar.typ`, extrae los valores de las variables `a` y `b` (que tienen que estar definidas en `bar.typ`, por ejemplo mediante enlaces `{let}`) y los define en el archivo actual. Reemplazar `a, b` por `*` carga todas las variables definidas en un módulo. Podés usar la palabra clave `as` para renombrar cada elemento: `{import "bar.typ": a as one, b as two}`

En lugar de una cadena de texto o una @path[ruta], también podés usar un @module[valor de módulo], como se muestra en el siguiente ejemplo:

```example
#import emoji: face
#face.grin
```

= Paquetes <packages>
Para reutilizar bloques de construcción entre proyectos, también podés crear e importar _paquetes_ de Typst. La importación de un paquete se especifica como una tripla formada por un espacio de nombres, un nombre y una versión.

```example
>>> #let add(x, y) = x + y
<<< #import "@preview/example:0.1.0": add
#add(2, 7)
```

El espacio de nombres `preview` contiene paquetes compartidos por la comunidad. Podés encontrar todos los paquetes de la comunidad disponibles en #link("https://typst.app/universe")[Typst Universe].

Si usás Typst de forma local, también podés crear tus propios paquetes locales del sistema. Para más detalles, mirá el #link("https://github.com/typst/packages")[repositorio de paquetes].

= Operadores <operators>
La siguiente tabla enumera todos los operadores unarios y binarios disponibles, con su efecto, su aridad (unario, binario) y su nivel de precedencia (los más altos se asocian con más fuerza). Algunas operaciones, como el @calc.rem-euclid[módulo], no tienen una sintaxis especial y se pueden lograr con funciones del módulo @calc.

#docs-table(
  table.header[Operador][Efecto][Aridad][Precedencia],

  [`{-}`],
  [Negación],
  [Unario],
  [7],

  [`{+}`],
  [Sin efecto (existe por simetría)],
  [Unario],
  [7],

  [`{*}`],
  [Multiplicación],
  [Binario],
  [6],

  [`{/}`],
  [División],
  [Binario],
  [6],

  [`{+}`],
  [Suma],
  [Binario],
  [5],

  [`{-}`],
  [Resta],
  [Binario],
  [5],

  [`{==}`],
  [Verifica igualdad],
  [Binario],
  [4],

  [`{!=}`],
  [Verifica desigualdad],
  [Binario],
  [4],

  [`{<}`],
  [Verifica menor que],
  [Binario],
  [4],

  [`{<=}`],
  [Verifica menor o igual que],
  [Binario],
  [4],

  [`{>}`],
  [Verifica mayor que],
  [Binario],
  [4],

  [`{>=}`],
  [Verifica mayor o igual que],
  [Binario],
  [4],

  [`{in}`],
  [Verifica si está en una colección],
  [Binario],
  [4],

  [`{not in}`],
  [Verifica si no está en una colección],
  [Binario],
  [4],

  [`{not}`],
  ["No" lógico],
  [Unario],
  [3],

  [`{and}`],
  ["Y" lógico con cortocircuito],
  [Binario],
  [3],

  [`{or}`],
  ["O" lógico con cortocircuito],
  [Binario],
  [2],

  [`{=}`],
  [Asignación],
  [Binario],
  [1],

  [`{+=}`],
  [Asignación con suma],
  [Binario],
  [1],

  [`{-=}`],
  [Asignación con resta],
  [Binario],
  [1],

  [`{*=}`],
  [Asignación con multiplicación],
  [Binario],
  [1],

  [`{/=}`],
  [Asignación con división],
  [Binario],
  [1],
)
