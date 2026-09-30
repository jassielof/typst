#import "../../../components/index.typ": docs-chapter, docs-table, short-or-long

#show: docs-chapter.with(
  title: "Sintaxis",
  route: "/reference/syntax",
  description: "Una referencia compacta de la sintaxis de Typst. Conocé más sobre el lenguaje en los modos marcado, matemático y código.",
)

Typst es un lenguaje de marcado. Esto significa que podés usar una sintaxis simple para resolver tareas comunes de diseño. La sintaxis de marcado liviana se complementa con reglas set y show, que te permiten dar estilo a tu documento de forma fácil y automática. Todo esto está respaldado por un lenguaje de scripting estrechamente integrado, con funciones incorporadas y definidas por el usuario.

= Modos <modes>
Typst tiene tres modos sintácticos: marcado, matemático y código. El modo marcado es el que se usa por defecto en un documento de Typst, el modo matemático te permite escribir fórmulas matemáticas y el modo código te permite usar las funciones de scripting de Typst.

Podés cambiar a un modo específico en cualquier momento consultando la siguiente tabla:

#docs-table(
  table.header[Modo nuevo][Sintaxis][Ejemplo],

  [Código],
  [Anteponé `#` al código],
  [`[Number: #(1 + 2)]`],

  [Matemática],
  [Rodeá la ecuación con `[$..$]`],
  [`[$-x$ is the opposite of $x$]`],

  [Marcado],
  [Rodeá el marcado con `[[..]]`],
  [`{let name = [*Typst!*]}`],
)

Una vez que entraste al modo código con `#`, no necesitás usar más numerales, a menos que hayas vuelto al modo marcado o matemático en el medio.

= Marcado <markup>
Typst ofrece marcado incorporado para los elementos de documento más comunes. La mayoría de los elementos de sintaxis son simples atajos de la función correspondiente. La tabla de abajo enumera todo el marcado disponible y enlaza al mejor lugar para aprender más sobre su sintaxis y uso.

#docs-table(
  table.header[Nombre][Ejemplo][Ver],

  [Salto de párrafo],
  [Línea en blanco],
  [@parbreak],

  [Énfasis fuerte],
  [`[*strong*]`],
  [@strong],

  [Énfasis],
  [`[_emphasis_]`],
  [@emph],

  [Texto sin formato (raw)],
  [``` [`print(1)`]```],
  [@raw],

  [Enlace],
  [`[https://typst.app/]`],
  [@link],

  [Etiqueta],
  [`[<intro>]`],
  [@label],

  [Referencia],
  [`[@intro]`],
  [@ref],

  [Título],
  [`[= Heading]`],
  [@heading],

  [Lista con viñetas],
  [`[- item]`],
  [@list],

  [Lista numerada],
  [`[+ item]`],
  [@enum],

  [Lista de términos],
  [`[/ Term: description]`],
  [@terms],

  [Matemática],
  [`[$x^2$]`],
  [@math[[Matemática]],

  [Salto de línea],
  [`[\]`],
  [@linebreak],

  [Comillas inteligentes],
  [`['single' or "double"]`],
  [@smartquote],

  [Atajo de símbolo],
  [`[~]`, `[---]`],
  [@reference:symbols:shorthands[[Símbolos]],

  [Expresión de código],
  [`[#rect(width: 1cm)]`],
  [@reference:scripting:expressions[[Scripting]],

  [Escape de carácter],
  [`[Tweet at us \#ad]`],
  [@reference:syntax:escapes[[Más abajo]],

  [Comentario],
  [`[/* block */]`, `[// line]`],
  [@reference:syntax:comments[[Más abajo]],
)

= #short-or-long[Matemática][Modo matemático] <math>
El modo matemático es un modo de marcado especial que se usa para componer fórmulas matemáticas. Se activa envolviendo una ecuación entre caracteres `[$]`. Funciona tanto en marcado como en código. La ecuación se compone en su propio bloque si empieza y termina con al menos un espacio (por ejemplo, `[$ x^2 $]`). Se puede producir matemática en línea omitiendo los espacios (por ejemplo, `[$x^2$]`). A continuación, una descripción general de la sintaxis específica del modo matemático:

#docs-table(
  table.header[Nombre][Ejemplo][Ver],

  [Matemática en línea],
  [`[$x^2$]`],
  [@math[[Matemática]],

  [Matemática en bloque],
  [`[$ x^2 $]`],
  [@math[[Matemática]],

  [Adjunto inferior],
  [`[$x_1$]`],
  [@math:attach[`attach`]],

  [Adjunto superior],
  [`[$x^2$]`],
  [@math:attach[`attach`]],

  [Fracción],
  [`[$1 + (a+b)/5$]`],
  [@math.frac[`frac`]],

  [Salto de línea],
  [`[$x \ y$]`],
  [@linebreak],

  [Punto de alineación],
  [`[$x &= 2 \ &= 3$]`],
  [@math[[Matemática]],

  [Acceso a variable],
  [`[$#x$, $pi$]`],
  [@math[[Matemática]],

  [Acceso a campo],
  [`[$arrow.r.long$]`],
  [@reference:scripting:fields[[Scripting]],

  [Multiplicación implícita],
  [`[$x y$]`],
  [@math[[Matemática]],

  [Atajo de símbolo],
  [`[$->$]`, `[$!=$]`],
  [@reference:symbols:shorthands[[Símbolos]],

  [Texto/cadena en matemática],
  [`[$a "is natural"$]`],
  [@math[[Matemática]],

  [Llamada a función matemática],
  [`[$floor(x)$]`],
  [@math[[Matemática]],

  [Expresión de código],
  [`[$#rect(width: 1cm)$]`],
  [@reference:scripting:expressions[[Scripting]],

  [Escape de carácter],
  [`[$x\^2$]`],
  [@reference:syntax:escapes[[Más abajo]],

  [Comentario],
  [`[$/* comment */$]`],
  [@reference:syntax:comments[[Más abajo]],
)

= #short-or-long[Código][Modo código] <code>
Dentro de los bloques y las expresiones de código, se pueden iniciar expresiones nuevas sin un carácter `#` inicial. Muchos elementos sintácticos son específicos de las expresiones. A continuación, una tabla con toda la sintaxis disponible en el modo código:

#docs-table(
  table.header[Nombre][Ejemplo][Ver],

  [Ninguno],
  [`{none}`],
  [@none],

  [Auto],
  [`{auto}`],
  [@auto],

  [Booleano],
  [`{false}`, `{true}`],
  [@bool],

  [Entero],
  [`{10}`, `{0xff}`],
  [@int],

  [Número de punto flotante],
  [`{3.14}`, `{1e5}`],
  [@float],

  [Longitud],
  [`{2pt}`, `{3mm}`, `{1em}`, ..],
  [@length],

  [Ángulo],
  [`{90deg}`, `{1rad}`],
  [@angle],

  [Fracción],
  [`{2fr}`],
  [@fraction],

  [Proporción],
  [`{50%}`],
  [@ratio],

  [Cadena de texto],
  [`{"hello"}`],
  [@str],

  [Etiqueta],
  [`{<intro>}`],
  [@label],

  [Matemática],
  [`[$x^2$]`],
  [@math[[Matemática]],

  [Texto sin formato (raw)],
  [``` [`print(1)`]```],
  [@raw],

  [Acceso a variable],
  [`{x}`],
  [@reference:scripting:blocks[[Scripting]],

  [Bloque de código],
  [`{{ let x = 1; x + 2 }}`],
  [@reference:scripting:blocks[[Scripting]],

  [Bloque de contenido],
  [`{[*Hello*]}`],
  [@reference:scripting:blocks[[Scripting]],

  [Expresión entre paréntesis],
  [`{(1 + 2)}`],
  [@reference:scripting:blocks[[Scripting]],

  [Array],
  [`{(1, 2, 3)}`],
  [@array[[Array]],

  [Diccionario],
  [`{(a: "hi", b: 2)}`],
  [@dictionary[[Diccionario]],

  [Operador unario],
  [`{-x}`],
  [@reference:scripting:operators[[Scripting]],

  [Operador binario],
  [`{x + y}`],
  [@reference:scripting:operators[[Scripting]],

  [Asignación],
  [`{x = 1}`],
  [@reference:scripting:operators[[Scripting]],

  [Acceso a campo],
  [`{x.y}`],
  [@reference:scripting:fields[[Scripting]],

  [Llamada a método],
  [`{x.flatten()}`],
  [@reference:scripting:methods[[Scripting]],

  [Llamada a función],
  [`{min(x, y)}`],
  [@function[[Función]],

  [Expansión de argumentos],
  [`{min(..nums)}`],
  [@arguments[[Argumentos]],

  [Función sin nombre],
  [`{(x, y) => x + y}`],
  [@function:unnamed[[Función]],

  [Enlace let],
  [`{let x = 1}`],
  [@reference:scripting:bindings[[Scripting]],

  [Función con nombre],
  [`{let f(x) = 2 * x}`],
  [@function[[Función]],

  [Regla set],
  [`{set text(14pt)}`],
  [@reference:styling:set-rules[[Estilos]],

  [Regla set-if],
  [`{set text(..) if .. }`],
  [@reference:styling:set-rules[[Estilos]],

  [Regla show-set],
  [`{show heading: set block(..)}`],
  [@reference:styling:show-rules[[Estilos]],

  [Regla show con función],
  [`{show raw: it => {..}}`],
  [@reference:styling:show-rules[[Estilos]],

  [Regla show de todo],
  [`{show: template}`],
  [@reference:styling:show-rules[[Estilos]],

  [Expresión de contexto],
  [`{context text.lang}`],
  [@reference:context[[Contexto]],

  [Condicional],
  [`{if x == 1 {..} else {..}}`],
  [@reference:scripting:conditionals[[Scripting]],

  [Bucle for],
  [`{for x in (1, 2, 3) {..}}`],
  [@reference:scripting:loops[[Scripting]],

  [Bucle while],
  [`{while x < 10 {..}}`],
  [@reference:scripting:loops[[Scripting]],

  [Control de flujo del bucle],
  [`{break, continue}`],
  [@reference:scripting:loops[[Scripting]],

  [Retorno de una función],
  [`{return x}`],
  [@function[[Función]],

  [Incluir un módulo],
  [`{include "bar.typ"}`],
  [@reference:scripting:modules[[Scripting]],

  [Importar un módulo],
  [`{import "bar.typ"}`],
  [@reference:scripting:modules[[Scripting]],

  [Importar elementos de un módulo],
  [`{import "bar.typ": a, b, c}`],
  [@reference:scripting:modules[[Scripting]],

  [Comentario],
  [`{/* block */}`, `{// line}`],
  [@reference:syntax:comments[[Más abajo]],
)

= Comentarios <comments>
Typst ignora los comentarios y no los incluye en la salida. Esto es útil para excluir versiones viejas o para agregar anotaciones. Para comentar una sola línea, empezala con `//`:

```example
// our data barely supports
// this claim

We show with $p < 0.05$
that the difference is
significant.
```

Los comentarios también se pueden envolver entre `/*` y `*/`. En ese caso, el comentario puede abarcar varias líneas:

```example
Our study design is as follows:
/* Somebody write this up:
   - 1000 participants.
   - 2x2 data design. */
```

= #short-or-long[Escapes][Secuencias de escape] <escapes>
Las secuencias de escape se usan para insertar caracteres especiales que son difíciles de escribir o que tienen un significado especial en Typst. Para escapar un carácter, anteponele una barra invertida. Para insertar cualquier punto de código Unicode, podés escribir una secuencia de escape hexadecimal: `[\u{1f600}]`. El mismo tipo de secuencias de escape también funciona en las @str[cadenas de texto].

```example
I got an ice cream for
\$1.50! \u{1f600}
```

= Identifiers <identifiers>
Los nombres de variables, funciones, etcétera (_identificadores_) pueden contener letras, números, guiones (`-`) y guiones bajos (`_`). Tienen que empezar con una letra o un guion bajo.

Más específicamente, la sintaxis de los identificadores en Typst se basa en el #link("https://www.unicode.org/reports/tr31/")[Anexo Nº 31 del Estándar Unicode], con dos extensiones: permitir `_` como carácter inicial y permitir tanto `_` como `-` como caracteres de continuación.

Para los identificadores de varias palabras, la convención de mayúsculas y minúsculas recomendada es el #link("https://en.wikipedia.org/wiki/Letter_case#Kebab_case")[kebab case]. En kebab case, las palabras se escriben en minúsculas y separadas por guiones (como en `top-edge`). Esto es especialmente relevante cuando desarrollás módulos y paquetes para que otros los usen, ya que mantiene las cosas predecibles.

```example
#let kebab-case = [Using hyphen]
#let _schön = "😊"
#let 始料不及 = "😱"
#let π = calc.pi

#kebab-case
#if -π < 0 { _schön } else { 始料不及 }
// -π means -1 * π,
// so it's not a valid identifier
```
