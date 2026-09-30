#import "../../../components/index.typ": docs-category, scope

#let math-definitions = dictionary(math)
#let math-items(..keys) = {
  keys.pos().map(k => (k, math-definitions.at(k))).to-dict()
}

#show: docs-category.with(
  title: "Matemática",
  description: "Documentación del modo matemático y del módulo `math`, que juntos permiten una composición matemática de alta calidad.",
  category: "math",
  scope: scope(std, "math"),
  groups: (
    (
      name: "variants",
      title: "Variantes",
      definitions: math-items("serif", "sans", "frak", "mono", "bb", "cal", "scr"),
      description: "Documentación de las funciones que permiten cambiar a tipografías matemáticas alternativas.",
      docs: [
        Tipografías alternativas dentro de las fórmulas.

        Estas funciones son distintas de la función @text porque las fuentes matemáticas contienen varias variantes de cada letra.
      ],
    ),
    (
      name: "styles",
      title: "Estilos",
      definitions: math-items("upright", "italic", "bold"),
      description: "Documentación de las funciones que permiten cambiar a formas de letras matemáticas alternativas.",
      docs: [
        Formas de letras alternativas dentro de las fórmulas.

        Estas funciones son distintas de la función @text porque las fuentes matemáticas contienen varias variantes de cada letra.
      ],
    ),
    (
      name: "sizes",
      title: "Tamaños",
      definitions: math-items("display", "inline", "script", "sscript"),
      description: "Documentación de las funciones que permiten cambiar a tamaños de texto matemático alternativos.",
      docs: [
        Estilos de tamaño forzado para las expresiones dentro de las fórmulas.

        Estas funciones permiten configurar manualmente el tamaño de los elementos de una ecuación para que se vean como en una ecuación de visualización (display) o en línea, o como si se usaran en una raíz o en subíndices/superíndices.
      ],
    ),
    (
      name: "underover",
      title: "Debajo/Encima",
      definitions: math-items(
        "underline",
        "overline",
        "underbrace",
        "overbrace",
        "underbracket",
        "overbracket",
        "underparen",
        "overparen",
        "undershell",
        "overshell",
      ),
      description: "Documentación de las funciones que agregan delimitadores encima o debajo de partes de una ecuación.",
      docs: [
        Delimitadores encima o debajo de partes de una ecuación.

        Además, las llaves y los corchetes te permiten agregar una anotación opcional debajo o encima de ellos.

        Estas funciones están pensadas específicamente para agregar delimitadores. Si querés ubicar dos partes arbitrarias de una ecuación una encima o debajo de la otra, sin delimitadores, usá en cambio la función @math.attach[`attach`].
      ],
    ),
    (
      name: "roots",
      title: "Raíces",
      definitions: math-items("root", "sqrt"),
      description: "Documentación de las funciones que componen raíces matemáticas.",
      docs: [
        Raíces cuadradas y no cuadradas.

        = Example <example>
        ```example
        $ sqrt(3 - 2 sqrt(2)) = sqrt(2) - 1 $
        $ root(3, x) $
        ```
      ],
    ),
    (
      name: "attach",
      title: "Adjuntos",
      definitions: math-items("attach", "scripts", "limits"),
      description: "Documentación de las funciones que permiten adjuntar con precisión subíndices, superíndices y límites a partes de una ecuación.",
      docs: [
        Subíndices, superíndices y límites.

        Los adjuntos se pueden mostrar como subíndices/superíndices o como límites. Typst decide automáticamente cuál es más adecuado según la base, pero también podés controlarlo manualmente con las funciones `scripts` y `limits`.

        Si querés que la base se estire para ajustarse a adjuntos superiores e inferiores largos (por ejemplo, una flecha con texto encima), usá la función @math.stretch[`stretch`].

        = Example <example>
        ```example
        $ sum_(i=0)^n a_i = 2^(1+i) $
        ```

        = Syntax <syntax>
        Esta función también tiene una sintaxis dedicada para los adjuntos después de la base: usá el guion bajo (`_`) para indicar un subíndice, es decir, un adjunto inferior, y el acento circunflejo (`^`) para indicar un superíndice, es decir, un adjunto superior.
      ],
    ),
    (
      name: "lr",
      title: "Izquierda/Derecha",
      definitions: math-items("lr", "mid", "abs", "norm", "floor", "ceil", "round"),
      description: "Documentación de las funciones que permiten componer delimitadores emparejados, potencialmente escalados.",
      docs: [
        Emparejamiento de delimitadores.

        La función `lr` te permite emparejar dos delimitadores y escalarlos con el contenido que encierran. Si bien esto también ocurre automáticamente con los delimitadores que se emparejan sintácticamente, `lr` te permite emparejar dos delimitadores arbitrarios y controlar exactamente su tamaño. Además de la función `lr`, Typst ofrece algunas funciones más que crean pares de delimitadores para valores absolutos, redondeados hacia arriba y hacia abajo, así como para normas.

        Para evitar que Typst empareje un delimitador y, por lo tanto, lo escale automáticamente, escapalo con una barra invertida. Para desactivar por completo el escalado automático, usá `{set math.lr(size: 1em)}`.

        = Example <example>
        ```example
        $ [a, b/2] $
        $ lr(]sum_(x=1)^n], size: #50%) x $
        $ abs((x + y) / 2) $
        $ \{ (x / y) \} $
        #set math.lr(size: 1em)
        $ { (a / b), a, b in (0; 1/2] } $
        ```
      ],
    ),
    (
      name: "spaces",
      title: "Espacios",
      definitions: math-items("thin", "med", "thick", "quad", "wide"),
      description: "Documentación de los espacios matemáticos.",
      docs: [
        Espacios matemáticos predefinidos de varios anchos.
      ],
    ),
  ),
)

Typst tiene una @reference:syntax:math[sintaxis] especial y funciones de biblioteca para componer fórmulas matemáticas. Las fórmulas matemáticas se pueden mostrar en línea con el texto o como bloques separados. Se compondrán en su propio bloque si empiezan y terminan con al menos un espacio (por ejemplo, `[$ x^2 $]`).

= Variables <variables>
En matemática, las letras sueltas siempre se muestran tal cual. Las secuencias de varias letras, en cambio, se interpretan como variables y funciones. Para mostrar varias letras literalmente, podés ponerlas entre comillas y, para acceder a variables de una sola letra, podés usar la @reference:scripting:expressions[sintaxis con numeral].

```example
$ A = pi r^2 $
$ "area" = pi dot "radius"^2 $
$ cal(A) :=
    { x in RR | x "is natural" } $
#let x = 5
$ #x < 17 $
```

= Símbolos <symbols>
El modo matemático pone a disposición una amplia selección de @sym[símbolos], como `pi`, `dot` o `RR`. Muchos símbolos matemáticos están disponibles en distintas variantes. Podés elegir entre las distintas variantes aplicando @symbol[modificadores] al símbolo. Además, Typst reconoce varias secuencias abreviadas, como `=>`, que aproximan un símbolo. Cuando existe una abreviatura así, la documentación del símbolo la enumera.

```example
$ x < y => x gt.eq.not y $
```

= Saltos de línea <line-breaks>
Las fórmulas también pueden contener saltos de línea. Cada línea puede contener uno o varios _puntos de alineación_ (`&`) que luego se alinean.

```example
$ sum_(k=0)^n k
    &= 1 + ... + n \
    &= (n(n+1)) / 2 $
```

= Llamadas a funciones <function-calls>
El modo matemático admite llamadas a funciones especiales sin el prefijo de numeral. En estas "llamadas matemáticas", la lista de argumentos funciona un poco distinto que en el código:

- Dentro de ellas, Typst sigue en "modo matemático". Por lo tanto, podés escribir matemática directamente en ellas, pero necesitás usar la sintaxis con numeral para pasar expresiones de código (excepto las cadenas de texto, que están disponibles en la sintaxis matemática).
- Admiten argumentos posicionales y con nombre, así como la expansión de argumentos, pero no admiten bloques de contenido finales.
- Ofrecen sintaxis adicional para listas de argumentos bidimensionales. El punto y coma (`;`) reúne en un argumento de tipo array los argumentos anteriores separados por comas.

```example
$ frac(a^2, 2) $
$ vec(1, 2, delim: "[") $
$ mat(1, 2; 3, 4) $
$ mat(..#range(1, 5).chunks(2)) $
$ lim_x =
    op("lim", limits: #true)_x $
```

Para escribir una coma o un punto y coma literales en una llamada matemática, escapalos con una barra invertida. Los dos puntos, en cambio, solo se reconocen de manera especial si están inmediatamente precedidos por un identificador, así que, para mostrarlos literalmente en esos casos, podés simplemente insertar un espacio antes.

Las llamadas a funciones precedidas por un numeral son llamadas normales a funciones de código y no se ven afectadas por estas reglas.

= Alineación <alignment>
Cuando las ecuaciones incluyen varios _puntos de alineación_ (`&`), esto crea bloques de columnas alineadas alternadamente a la derecha y a la izquierda. En el siguiente ejemplo, la expresión `(3x + y) / 7` está alineada a la derecha y `= 9` está alineado a la izquierda. La palabra "given" también está alineada a la izquierda porque `&&` crea dos puntos de alineación seguidos, alternando dos veces la alineación. `& &` y `&&` se comportan exactamente igual. Mientras tanto, "multiply by 7" está alineado a la derecha porque solo lo precede un `&`. Cada punto de alineación simplemente alterna entre alineado a la derecha y alineado a la izquierda.

```example
$ (3x + y) / 7 &= 9 && "given" \
  3x + y &= 63 & "multiply by 7" \
  3x &= 63 - y && "subtract y" \
  x &= 21 - y/3 & "divide by 3" $
```

= Fuentes matemáticas <math-fonts>
Podés establecer la fuente matemática con una @reference:styling:show-rules[regla show-set], como se demuestra a continuación. Tené en cuenta que solo las fuentes matemáticas especiales de OpenType son adecuadas para la composición matemática.

```example
#show math.equation: set text(font: "Pennstander Math")
$ sum_(i in NN) 1 + i $
```

= Módulo math <math-module>
Todas las funciones matemáticas forman parte del @reference:scripting:modules[módulo] `math`, que está disponible por defecto en las ecuaciones. Fuera de las ecuaciones, se puede acceder a ellas con el prefijo `math.`.

= Accesibilidad <accessibility>
Para que la matemática sea accesible, tenés que proporcionar descripciones alternativas de las ecuaciones en lenguaje natural con el @math.equation.alt[parámetro `alt` de `math.equation`]. Para más información, mirá la @guides:accessibility:textual-representations[sección de representaciones textuales de la guía de accesibilidad].

```example
#math.equation(
  alt: "d S equals delta q divided by T",
  block: true,
  $ dif S = (delta q) / T $,
)
```

En el futuro, Typst hará accesibles automáticamente las ecuaciones sin descripciones alternativas en la exportación a HTML y a PDF 2.0.
