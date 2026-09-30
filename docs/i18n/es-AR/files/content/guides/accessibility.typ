#import "../../components/index.typ": (
  docs-chapter, docs-figure, docs-table, short-or-long, side-by-side,
)

#show: docs-chapter.with(
  title: "Guía de accesibilidad",
  route: "/guides/accessibility",
  description: "Aprendé a crear documentos accesibles con Typst. Esta guía cubre el marcado semántico, el orden de lectura, el texto alternativo, el contraste de color, la configuración del idioma y el cumplimiento de PDF/UA, para que tus archivos funcionen para todos los lectores y para las tecnologías de asistencia.",
  class: "a11y",
)

Hacer accesible un documento significa que todos puedan usarlo y entenderlo. Eso no incluye solo a las personas con discapacidades permanentes o temporales, sino también a quienes usan otros dispositivos o tienen otras preferencias. Para subrayar por qué es importante la accesibilidad, pensá que tu documento puede leerse en más contextos de los que esperabas:

- Alguien puede imprimir el documento en papel
- Alguien puede leer tu documento en un celular, con el reflujo activado en su lector de PDF
- Alguien puede hacer que su computadora le lea el documento en voz alta
- Alguien puede pedirle a una inteligencia artificial que le resuma tu documento
- Alguien puede convertir tu documento a otro formato, como HTML, que le resulte más accesible

Para atender a todas estas personas y escenarios, tendrías que diseñar tu documento para el *Acceso universal.* El Acceso universal es un principio simple pero poderoso: en lugar de adaptar un proyecto para que sea accesible una vez terminado, diseñalo desde el principio para que funcione con la mayor variedad posible de personas y situaciones. ¡Esto mejora la experiencia de todos los lectores!

Typst puede ayudarte a crear archivos accesibles que se lean bien con lectores de pantalla, que se vean bien incluso al reflujarse para otro tamaño de pantalla y que pasen los verificadores automáticos de accesibilidad. Sin embargo, para crear archivos accesibles vas a tener que tener presentes algunas reglas. Esta guía te ayuda a conocer qué problemas afectan la accesibilidad, cómo diseñar para el Acceso universal y qué herramientas te da Typst para lograrlo. Gran parte de las recomendaciones valen para todos los formatos de exportación, pero la guía se centra en la exportación a PDF. Las diferencias importantes con la exportación a HTML se señalan aparte.

= #short-or-long[Conceptos básicos][Conceptos básicos de accesibilidad] <basics>
Los archivos accesibles permiten que el software haga más que simplemente renderizarlos. Tu computadora puede entender qué representa cada parte del documento y usar esa información para presentárselo al usuario.

Distintos programas consumen esta información para dar acceso. Al exportar un PDF desde Typst, el _visor de PDF_ (a veces llamado también lector) muestra las páginas del documento tal como las diseñaste en la vista previa de Typst. Algunas personas dependen de _tecnologías de asistencia_ (TA), como lectores de pantalla, pantallas braille, magnificadores de pantalla y más, para consumir archivos PDF. En ese caso, la información semántica del archivo se usa para adaptar su contenido a texto hablado o escrito, o a otra representación visual. Otras personas hacen que el visor de PDF reflujee el archivo para crear un diseño similar al de una página web: el contenido se ajusta al ancho de la ventana y se desplaza de forma continua. Por último, algunos usuarios reutilizan el PDF en otro formato, por ejemplo texto plano para dárselo a un Modelo de Lenguaje Grande (LLM) o HTML. Una forma especial de reutilización es copiar y pegar, donde los usuarios usan el portapapeles para extraer contenido de un archivo y usarlo en otra aplicación.

El soporte de accesibilidad varía según el visor y la TA. Algunas combinaciones funcionan mejor que otras. En nuestras pruebas, #link("https://www.adobe.com/acrobat.html")[Adobe Acrobat] junto con #link("https://www.nvaccess.org/download/")[NVDA] en Windows y #link("https://support.apple.com/guide/voiceover/welcome/mac")[VoiceOver] en macOS ofrecieron el soporte de accesibilidad más completo. Con la exportación a HTML, los navegadores brindan una base de accesibilidad más consistente que los lectores de PDF.

Solo la exportación a PDF y a HTML produce archivos accesibles. Ni los PNG ni los SVG son accesibles por sí solos. Ambos formatos pueden usarse dentro de una obra mayor que sea accesible si les proporcionás una @guides:accessibility:textual-representations[representación textual].

= Mantener la semántica <maintaining-semantics>
Para agregar a un archivo la información semántica correcta para las TA y la reutilización, Typst necesita saber qué rol semántico cumple cada parte. Por ejemplo, esto significa que un título en un PDF compilado no debería ser simplemente texto grande y en negrita. En cambio, el archivo debería contener la información explícita (conocida como _etiqueta_, o _tag_) de que cierto texto constituye un título. Entonces un lector de pantalla lo anunciará como título y le permitirá al usuario navegar entre títulos.

Si usás Typst de forma idiomática, con el marcado y los elementos integrados, Typst agrega automáticamente etiquetas con información semántica rica a tus archivos. Veamos dos ejemplos de código:

```example
// ❌ Don't do this
#text(
  size: 16pt,
  weight: "bold",
)[Heading]
```

```example
// ✅ Do this
#show heading: set text(size: 16pt)
= Heading
```

Los dos ejemplos se ven igual. Ambos contienen el texto "Heading" en negrita, con tamaño de 16 puntos. Sin embargo, solo el segundo es accesible. Al usar el marcado de título, Typst sabe que el significado semántico de este texto es el de un título y puede propagar esa información al PDF final. En el primer ejemplo, solo sabe que tiene que usar negrita y un cuerpo más grande en un texto que, por lo demás, es normal, y no puede asumir que querías un título y no una decisión de estilo u otro elemento, como una cita.

Usar semántica no se limita a los títulos. Estos son algunos ejemplos más de elementos que tenés que usar:

- Usá guiones bajos / @emph en lugar de la función @text para poner texto en énfasis
- Usá asteriscos / @strong en lugar de la función text para dar énfasis fuerte al texto
- Usá listas (@list, @enum, @terms) en lugar de texto normal con saltos de línea cuando trabajes con contenido enumerado u ordenado
- Usá @quote para las citas en línea y en bloque
- Usá las funciones integradas @bibliography y @cite en lugar de imprimir la bibliografía a mano
- Usá etiquetas y @ref o `[@references]` para referenciar otras partes de tus documentos en lugar de escribir la referencia a mano
- Usá el @figure.caption[argumento `caption` del elemento `figure`] para agregar epígrafes en lugar de ponerlos como texto debajo de la llamada a la función

Si querés cambiar la apariencia predeterminada de un elemento, no lo reemplaces por tu propia función. En cambio, usá @reference:styling:set-rules[reglas set], reglas show-set y @reference:styling:show-rules[reglas show] para personalizar su aspecto. Este es un ejemplo de cómo cambiar el aspecto del énfasis fuerte en tu documento:

```example
// Change how text inside of strong emphasis looks
#show strong: set text(tracking: 0.2em, fill: blue, weight: "black")

When setting up your tents, *never forget* to secure the pegs.
```

La regla show-set cambia por completo la apariencia predeterminada del elemento @strong, pero conserva su significado semántico. Si necesitás todavía más personalización, podés darles a las reglas show código de diseño totalmente propio y Typst seguirá reteniendo el propósito semántico del elemento.

= Orden de lectura <reading-order>
Para que las TA lean el contenido de un documento en el orden correcto, y para las aplicaciones de reutilización, los archivos accesibles deben hacer explícito su orden de lectura. Esto se debe a que el orden lógico de lectura puede diferir del orden del diseño. Las figuras flotantes son un ejemplo común de esa diferencia: una figura puede ser relevante para un párrafo en el centro de la página pero aparecer en el borde superior o inferior. En los archivos no accesibles, los lectores de PDF y las TA tienen que asumir que el orden del diseño es igual al orden lógico de lectura, lo que suele confundir a los usuarios de TA. Cuando el orden de lectura está bien definido, los lectores de pantalla leen una nota al pie o una figura flotante justo donde tiene sentido.

Por suerte, el marcado de Typst ya implica un único orden de lectura. Podés asumir que los documentos de Typst se leen en el orden en que el contenido fue colocado en el marcado. Para la mayoría de los documentos, eso alcanza. Sin embargo, cuando usás las funciones @place y @move o @figure.placement[figuras flotantes], tenés que prestar especial atención a poner la llamada a la función en un lugar apropiado del orden lógico de lectura en el marcado, aunque eso no tenga consecuencias en el diseño. Simplemente preguntate dónde querrías que un lector de pantalla anuncie el contenido que estás colocando.

= Contenedores de diseño <layout-containers>
Typst ofrece algunos contenedores de diseño, como @grid, @stack, @box, @columns y @block, para organizar visualmente tu contenido. Ninguno de estos contenedores tiene significado semántico asociado. Typst conserva algunos de ellos durante el reflujo del PDF y descarta otros.

Al diseñar para el Acceso universal, tenés que tener presente que los usuarios de TA a menudo no pueden ver el diseño visual que crea el contenedor. En cambio, la TA solo lee su contenido, así que lo mejor es pensar en estos contenedores como transparentes en términos de accesibilidad. Por ejemplo, el contenido de una grilla se leerá de forma plana, en el orden en que agregaste las celdas en el código fuente. Si el diseño que creaste es meramente visual y decorativo, no hay problema. Pero si el diseño tiene un significado semántico evidente para quien ve el archivo en un lector de PDF común, entonces no es accesible. En ese caso, creá una representación alternativa de tu contenido que aproveche el texto, o envolvé tu contenedor en el elemento @figure para dar una descripción textual alternativa.

No uses el contenedor grid para representar datos tabulares. En su lugar, usá @table. Las tablas son accesibles para los usuarios de TA: su TA les permite navegar la tabla en dos dimensiones. Las tablas se conservan durante el reflujo y la reutilización. Al crear tablas, usá los elementos @table.header y @table.footer para marcar los roles semánticos de cada fila. La documentación de table contiene una @table:accessibility[sección de accesibilidad] con más información sobre cómo hacer accesibles tus tablas. Tené en cuenta que, aunque los usuarios de TA pueden acceder a las tablas, muchas veces les resulta engorroso: las tablas están optimizadas para el consumo visual. Que te lean el contenido de un conjunto de celdas y tener que recordar su fila y su columna genera una carga mental adicional. Considerá hacer accesible la conclusión principal de la tabla como texto o como epígrafe en otro lugar.

Del mismo modo, si usás funciones como @rotate, @scale y @skew, fijate de que esa transformación no tenga significado semántico o de que el significado esté disponible en otro lado para los usuarios de TA, por ejemplo en el @guides:accessibility:textual-representations[texto alternativo] de una figura o en un epígrafe.

= Artefactos <artifacts>
Algunas cosas de una página no tienen significado semántico y son irrelevantes para el contenido del documento. A estos elementos los llamamos _artefactos._ Los artefactos se ocultan a las TA y a la reutilización, y desaparecen durante el reflujo. Algunos ejemplos de artefactos:

- Los guiones que inserta la separación silábica automática al final de una línea
- Los encabezados y pies de página de cada página
- Una imagen de fondo de página puramente decorativa

En general, para que un documento se considere accesible, cada elemento de una página tiene que tener alguna forma de ser anunciado por la TA o ser un artefacto.

Typst marca automáticamente como artefactos muchos elementos de diseño, como encabezados, pies de página, fondos y primeros planos de página, y la separación silábica automática. Sin embargo, si querés agregar contenido puramente decorativo a tu documento, podés usar la función @pdf.artifact para marcar un fragmento de contenido como artefacto. Si no estás seguro de si tenés que marcar un elemento como artefacto, preguntate lo siguiente: ¿sería simplemente molesto que un lector de pantalla te anunciara el elemento? Entonces puede ser un artefacto. Si, en cambio, podría ser útil que se anuncie, entonces no es un artefacto.

Por razones técnicas, una vez dentro de un artefacto, el contenido no puede volver a ser semántico. Para apilar artefactos y contenido semántico, usá @place para superponer los contenidos.

Tené en cuenta que Typst marca como artefactos las formas y trazados como @square y @circle, mientras que su contenido sigue siendo semánticamente relevante y accesible para las TA. Si tus formas tienen un significado semántico, envolvelas en el elemento @figure para dar una descripción textual alternativa.

= Uso del color y contraste <color-use-and-contrast>
El Acceso universal no solo significa que tus documentos funcionen con TA, reflujo y reutilización, sino también que el acceso visual sea posible para todos, incluidas las personas con problemas de visión. No solo es frecuente que la vista empeore con la edad: una parte significativa de la población tiene problemas para diferenciar colores. Alrededor del 8 % de los hombres y el 0,5 % de las mujeres son daltónicos.

#side-by-side(
  docs-figure(
    "chart-bad-regular.png",
    alt: "Gráfico de barras que muestra la producción de energía en Alemania por tipo, en teravatios-hora, en el eje X, y el año en el eje Y. Cada barra tiene hasta cuatro segmentos: Nuclear (violeta), Renovables (verde), Combustibles fósiles (rojo) y Otros (azul). Hay una leyenda en la esquina superior derecha que asocia los colores de los segmentos con sus etiquetas",
    width: 300,
  ),
  docs-figure(
    "chart-bad-deuteranopia.png",
    alt: "El mismo gráfico de barras con los colores cambiados: los segmentos de Nuclear y Otros tienen un azul oscuro muy parecido, y los segmentos vecinos de Renovables y Combustibles fósiles tienen dos tonos de amarillo enfermizo casi indistinguibles",
    width: 300,
  ),
)

Esto significa que el color no debe ser la única manera de hacer accesible la información para los usuarios videntes en tus documentos. Como ejemplo, pensá en un gráfico de barras apiladas con varios segmentos de colores por barra. Nuestro ejemplo muestra un gráfico de la producción doméstica de energía en Alemania por tipo #footnote[Conjunto de datos de la Oficina Federal de Estadística de Alemania (Statistisches Bundesamt, Destatis). #link("https://www.destatis.de/DE/Themen/Branchen-Unternehmen/Energie/Erzeugung/bar-chart-race.html")["Bruttostromerzeugung nach Energieträgern in Deutschland ab 1990"], 2025, disponible bajo la _Data licence Germany – attribution – version 2.0._]. En la imagen podés ver el gráfico tal como se vería normalmente y una simulación de cómo lo verían las personas con daltonismo de tipo deuteranopía. Se ve que los dos pares formados por el primer y el último segmento parecen azules y el par central parece amarillento. El primer desafío para el usuario daltónico es, entonces, distinguir el límite entre la barra "Renovables" y la de "Combustibles fósiles". Después, tiene que llevar la cuenta de cuál es cuál solo por su orden, lo que suma carga mental. Una forma de hacer este gráfico todavía menos accesible sería que el orden de los segmentos no coincidiera con el de la leyenda.

¿Cómo podemos mejorar el gráfico? Primero, asegurarnos de que ninguna información se comunique únicamente mediante el color. Una posibilidad es agregarle un patrón a cada barra. Después, podemos ayudar al usuario a distinguir los límites de cada segmento agregando un borde de alto contraste. Nuestro gráfico podría quedar así:

#docs-figure(
  "chart-good.png",
  alt: "El mismo gráfico de barras con los colores originales. Esta vez se agregan contornos negros alrededor de cada segmento. Además, cada segmento tiene un patrón único.",
  width: 400,
)

Se podría mejorar todavía más eligiendo colores que se diferencien para las personas con los tipos más comunes de daltonismo. También podrías seguir iterando el diseño con patrones de dos tonos, alineándolos con las barras o cambiando el uso de la tipografía.

Podés revisar tu diseño en la app web usando el simulador de daltonismo integrado. Para usarlo, abrí el menú "View" y elegí el modo deseado en el menú "Simulate color blindness". Si no usás nuestra app web, también podés usar otras herramientas de la web para #link("https://daltonlens.org/colorblindness-simulator")[simular la percepción del color de los distintos tipos de daltonismo].

Considerá también el contraste de color entre el fondo y el primer plano. Por ejemplo, si usás texto gris claro para las notas al pie, pueden volverse difíciles de leer. Otra situación que a menudo lleva a un contraste bajo es superponer texto sobre una imagen.

#docs-figure(
  "color-contrast.png",
  alt: "Dos cuadros de aviso con el texto 'Precaución: mantené las manos lejos de la abrochadora activa' y diseños distintos. Cada cuadro tiene debajo un medidor de contraste para su texto y sus elementos gráficos. El cuadro de la izquierda tiene un fondo rojo claro y el texto es de un rojo común. Tiene un contraste de texto de 2,8:1 y un contraste gráfico de 1,4:1. El cuadro de la derecha es blanco con un contorno rojo y texto rojo oscuro. Tiene un contraste de texto de 5,9:1 y un contraste gráfico de 3,9:1.",
  width: 400,
)

En nuestro ejemplo, vemos dos diseños de cuadros de aviso. Como estos cuadros buscan ayudar al usuario a evitar un peligro, es fundamental que realmente pueda leerlos. Sin embargo, en el primer cuadro el fondo es bastante claro, lo que dificulta distinguirlo. Peor todavía: el texto rojo es difícil de leer sobre el fondo rojo claro. El texto tiene una relación de contraste de 2,8:1, por debajo del mínimo de 4,5:1 que fijan las Pautas de Accesibilidad para el Contenido Web (WCAG). Del mismo modo, el cuadro tiene una relación de contraste de 1,4:1 con el fondo blanco de la página, por debajo del umbral de 3:1 para objetos gráficos.

Los colores del segundo ejemplo se ajustaron para cumplir los umbrales de contraste WCAG nivel AA. ¡Tendría que ser notablemente más fácil leer el texto del cuadro, incluso si tenés buena vista!

Existen #link("https://webaim.org/resources/contrastchecker/")[herramientas para comparar cuánto contraste tiene un par de colores] como primer plano y fondo. La más común es la relación de contraste de color de WCAG. Para un tamaño de fuente dado, un par de colores puede no pasar la prueba, alcanzar el nivel AA o llegar al nivel AAA, más alto. Apuntá a un contraste AA como mínimo para todas tus combinaciones de colores.

#docs-table(
  table.header[Contenido][Relación AA][Relación AAA],

  [Texto grande (≥18 pt, o en negrita y ≥14 pt)],
  [3:1],
  [4.5:1],

  [Texto pequeño],
  [4.5:1],
  [7:1],

  [Contenido que no es texto],
  [3:1],
  [3:1],
)

Tené en cuenta que los marcos de accesibilidad comunes, como WCAG, hacen una excepción para el texto puramente decorativo y los logotipos: por su carácter gráfico, pueden tener relaciones de contraste que no alcancen el contraste AA.

= Representaciones textuales <textual-representations>
Para dar soporte al uso de TA y a algunos flujos de reutilización, todos los elementos con significado semántico deben tener una representación textual. Pensalo en términos de Acceso universal: si un elemento no es un @guides:accessibility:artifacts[artefacto], tiene significado semántico. Pero si la TA no puede procesarlo, el significado semántico completo del documento no está disponible para los usuarios de TA. Por lo tanto, para brindar Acceso universal, usá los mecanismos integrados en Typst para proporcionar representaciones alternativas.

Cuando agregues una imagen, asegurate de usar el @image.alt[argumento `alt` de la función image] para describir lo que se ve en ella. Esta descripción alternativa (conocida a veces como texto alternativo) tiene que transmitir lo esencial de la imagen: pensá cómo se la describirías a un amigo si lo llamaras por teléfono. Para escribir buenas descripciones alternativas, considerá el contexto en el que aparece la imagen:

```example
#image("heron.jpg", alt: "?")

Herons have feet with interdigital
webbing, allowing for good mobility
when swimming, and wings that span
up to 2.3 m.
```

¿Cuál podría ser una buena descripción alternativa para #link("https://commons.wikimedia.org/wiki/File:Reiher_im_Flug.jpg")[esta imagen]? Veamos algunos ejemplos de lo que _no_ hay que hacer:

- `{"Imagen de una garza"}` \
  ❌ El lector de pantalla ya anuncia la imagen por su cuenta, así que decir que es una imagen es redundante. En este ejemplo, el usuario de TA escucharía "Imagen, Imagen de una garza".

- `{"Un pájaro"}` \
  ❌ La descripción alternativa no es lo bastante específica. Por ejemplo, es relevante para el usuario que la imagen muestra una garza y que se ven tanto sus patas como sus alas.

- `{"Garza gris en vuelo. Foto de Makasch1966 en Wikimedia Commons, licencia CC Attribution 4.0 International"}` \
  ❌ La descripción alternativa no debe incluir detalles que no se ven en la imagen, como atribuciones, chistes o metadatos. Tené presente que eso no es accesible para los usuarios videntes. Esa información va en otro lugar.

- `{"Garza gris volando bajo, de derecha a izquierda. Tiene las patas extendidas y apuntando levemente hacia abajo, y toca un horizonte desenfocado donde se distingue un bosque oscuro. Las alas del ave están extendidas y forman un arco hacia arriba. En la esquina inferior izquierda de la imagen se ven ramas fuera de foco."}` \
  ❌ La descripción alternativa es demasiado extensa. Usá tu criterio y determiná qué tan importante es la imagen para el contenido. Pensá cuánto tiempo la miraría realmente un usuario vidente; tu texto alternativo debería demandar un esfuerzo parecido para "consumirlo". Por ejemplo, la descripción anatómica de arriba podría ser apropiada para una discusión más extensa en un libro de texto de zoología, mientras que la información de composición es útil al escribir sobre fotografía. El contexto que acompaña a la imagen de ejemplo es relativamente breve, así que escribí una descripción más corta.

En cambio, en el ejemplo dado, podrías usar este texto alternativo:

- `{"Garza en vuelo con las patas y las alas extendidas"}` \
  ✅ Esta descripción alternativa describe la imagen, es relevante para el contexto y guarda proporción con su brevedad.

Hay recursos disponibles en la web #link("https://webaim.org/techniques/alttext/")[para aprender más sobre cómo escribir buenas descripciones alternativas]. El requisito de agregar texto alternativo a las imágenes se aplica a todos los formatos de imagen. Actualmente, Typst no conserva en el documento compilado las etiquetas de una imagen PDF, incluso si el archivo PDF de la imagen era accesible por sí solo.

No uses imágenes de texto; del mismo modo, no uses operaciones de trazado para dibujar texto a mano. Typst no va a poder procesar el texto de las imágenes para hacerlo accesible de la misma manera que el texto nativo. Hay una excepción a esta regla: usá una imagen de texto cuando la apariencia del texto sea esencial para el significado semántico del documento y no pueda reproducirse de forma nativa con Typst. En ese caso, tenés que describir en la descripción alternativa tanto el contenido textual como las características visuales esenciales.

Igual que la función image, la función figure tiene un @figure.alt[atributo `alt`]. Cuando usás este atributo, muchos lectores de pantalla y otras TA no anuncian el contenido de la figura y leen solo la descripción alternativa. Tu descripción alternativa tiene que ser lo bastante completa como para que el usuario de TA no necesite acceder al cuerpo de la figura. Usá la descripción alternativa solo si el contenido de la figura no es accesible de otra manera. Por ejemplo, no uses el atributo `alt` de una figura si contiene un elemento `table`, pero sí usalo si dentro usaste formas que tienen un significado semántico. Si especificás tanto `alt` como `caption`, las TA leerán ambos. Cuando tu figura contiene una imagen, poné la descripción alternativa en @image.alt[la imagen misma], no en la figura. No pongas ambas, porque la descripción de la figura reemplazaría a la de la imagen.

```typ
#figure(
  alt: "Star with a blue outline",
  curve(
    stroke: blue,
    curve.move((25pt, 0pt)),
    curve.line((10pt, 50pt)),
    curve.line((50pt, 20pt)),
    curve.line((0pt, 20pt)),
    curve.line((40pt, 50pt)),
    curve.close(),
  ),
)
```

Por último, podés especificar una descripción alternativa para las fórmulas con @math.equation. Describí tu fórmula como si la leyeras en voz alta en lenguaje natural. Actualmente, agregar una descripción alternativa es obligatorio para tener matemática accesible en todos los formatos de exportación. Si no agregás una descripción alternativa a tu fórmula, la exportación a PDF/UA-1 falla. En el futuro, Typst va a hacer accesible la matemática automáticamente en HTML y PDF 2.0 gracias a la tecnología MathML.

```typ
#math.equation(
  alt: "a squared plus b squared equals c squared",
  block: true,
  $ a^2 + b^2 = c^2 $,
)
```

Otro elemento que se representa a sí mismo como texto son los enlaces. Lo mejor es evitar textos de enlace poco descriptivos, como _acá_ o _ir._ Estos textos también perjudican el posicionamiento en buscadores (SEO), si es algo que te importa en tu documento. En cambio, intentá que el enlace contenga texto sobre adónde apunta. Tené en cuenta que, a menos que busques el máximo nivel de accesibilidad, también está bien que el enlace no sea descriptivo en sí mismo mientras su propósito pueda entenderse por el contenido que lo rodea inmediatamente.

= Idioma natural <natural-language>
Para que los lectores de pantalla pronuncien bien tu documento y el software de traducción funcione correctamente, tenés que indicar en qué idioma natural está escrito. Usá la regla @text.lang[`[#set text(lang: "..")]`] al comienzo de tu documento, o la capacidad de tu plantilla para configurar el idioma. Si no lo hacés, Typst va a asumir que tu contenido está en inglés. El idioma natural que elijas no solo afecta la accesibilidad, sino también cómo Typst aplica la separación silábica, qué convenciones tipográficas se aplican, las etiquetas de figuras y referencias y, en la app web, qué idioma se usa para el corrector ortográfico.

Si usás un idioma con variaciones importantes entre regiones, como el chino o el inglés, usá también @text.region[el argumento `region`]. Por ejemplo, el chino hablado en Hong Kong se vería así:

```typ
#set text(lang: "zh", region: "HK")
```

Para especificar tu idioma, usá los códigos ISO 639. Para las regiones, usá el código #link("https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2")[ISO 3166-1 alpha-2]. ISO 639 contiene tres variantes: una para códigos de idioma de dos letras, como "de" para alemán #link("https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes")[(ISO 639-1)], y dos para códigos de tres letras, como "deu" (#link("https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes")[ISO 639-2] e #link("https://en.wikipedia.org/wiki/List_of_ISO_639-3_codes")[ISO 639-3]). Si tu idioma tiene un código ISO 639-1 de dos letras, preferilo siempre. ISO 639-2 e ISO 639-3 comparten la mayoría de los códigos, pero hay algunas diferencias. Cuando el código de tu idioma difiere entre los dos estándares, usá ISO 639-2 al exportar a PDF 1.7 (el predeterminado de Typst) y anteriores, e ISO 639-3 para exportar a PDF 2.0 y HTML.

Hay tres códigos de idioma especiales definidos tanto por ISO 639-2 como por ISO 639-3 que podés usar cuando es difícil indicar un código de idioma normal:

- `zxx` para texto que no está en un idioma natural
- `und` para texto cuyo idioma natural no podés determinar
- `mis` para texto en idiomas a los que no se les asignó un código de idioma

Si tu documento contiene texto en varios idiomas, podés usar la función text o una regla set de text con alcance acotado para encerrar los fragmentos en otros idiomas:

```example
This is #text(lang: "fr")[français].

#[
  #set text(lang: "es")
  Este es un fragmento más largo
  del texto en español.
]
```

= Título del documento y títulos de sección <document-title-and-headings>
Ponerle título a tu documento facilita encontrarlo y navegar entre él y otros documentos, tanto para los usuarios de TA como para los usuarios comunes de visores de PDF. Por eso los estándares de accesibilidad como WCAG y PDF/UA exigen que establezcas un título legible por máquina para tu documento.

Para hacerlo en Typst, colocá esta regla set en tu documento antes de cualquier contenido:

```typ
#set document(title: [GlorboCorp Q1 2023 Revenue Report])
```

Esto establece el @document.title[título en los metadatos del documento] y en la barra de título del visor de PDF o del navegador web. Si esto produce un error al usar una plantilla, fijate si tu plantilla ofrece otra forma de establecer el título del documento.

Lo más probable es que también quieras incluir el título de forma visible en tu documento. Para eso, usá el elemento @title. Cuando llamás al elemento title sin argumentos, imprime el contenido que estableciste como título del documento. Como alternativa, podés personalizar el título pasando contenido como argumento posicional de cuerpo. No uses el elemento title más de una vez en tu documento.

Nunca uses un título de sección (heading) para el título del documento; usá el elemento title. Si tenés experiencia con HTML, es importante recordar que la semántica del elemento heading en Typst difiere de la de los títulos de HTML. En Typst se recomienda usar varios títulos de primer nivel para las secciones. Al exportar a HTML, un @title[title] se serializa como una etiqueta `h1`, mientras que un @heading.level[título de primer nivel] se serializa como una etiqueta `h2`. En la exportación a PDF, el título y los títulos de sección se etiquetan correctamente según la versión de PDF elegida.

Es importante que la secuencia de títulos sea correlativa: nunca saltees un nivel al ir más profundo. Esto significa que un título de tercer nivel tiene que ir seguido de uno de nivel cuatro o inferior, pero nunca de uno de nivel cinco o superior.

```typ
// ❌ Don't do this:
= First level heading
=== Third level heading
```

Tené en cuenta que, para pasar la #link("https://helpx.adobe.com/acrobat/using/create-verify-pdf-accessibility.html#Bookmarks")[verificación automática de accesibilidad de Adobe Acrobat], los documentos de 21 páginas o más deben contener títulos en el esquema (marcadores).

= Estándares y legislación de accesibilidad <accessibility-standards-and-legislation>
Typst puede ayudarte a afirmar que tu documento es accesible verificándolo contra estándares internacionales. Para la exportación a PDF hay varios estándares de archivos accesibles, sobre todo el estándar PDF/UA. Su primera parte (PDF/UA-1) ya está soportada por Typst, mientras que el soporte para la segunda (PDF/UA-2) está planeado para el futuro. A continuación encontrás una explicación de todos los estándares relevantes:

- *PDF etiquetado (Tagged PDF):* Los PDF etiquetados contienen datos legibles por máquina sobre la estructura semántica de un documento, que las TA pueden interpretar. Typst escribe PDF etiquetados de forma predeterminada, pero tené presente que solo puede escribir las etiquetas adecuadas si conoce la estructura semántica de tu documento. Consultá la sección @guides:accessibility:maintaining-semantics[_Mantener la semántica_] para aprender a usar los elementos de Typst para comunicar semántica. Para ofrecer Acceso universal, también sos responsable de proporcionar por tu cuenta una representación textual del contenido que no es texto.

- *PDF/UA-1:* El estándar PDF/UA explica cómo escribir un archivo PDF 1.7 optimizado para el Acceso universal. Implica PDF etiquetado, exige descripciones alternativas para imágenes y matemática, requiere un título del documento e introduce reglas sobre cómo estructurar los contenidos, como las tablas. Si seguís esta guía, ya estás evitando la mayoría de los errores del compilador que pueden ocurrir durante la exportación a PDF/UA-1.

- *PDF/UA-2:* También existe la parte más reciente, PDF/UA-2, que apunta a archivos PDF 2.0. Mejora la accesibilidad de la matemática y de algunos elementos semánticos. El soporte para PDF/UA-2 todavía no está disponible en Typst, pero está planeado.

- *Well Tagged PDF (WTPDF):* Es un estándar de la industria muy similar a PDF/UA-2. Igual que PDF/UA-2, Typst no lo soporta actualmente. Originalmente se redactó porque las dos partes de la especificación PDF/UA solo estaban disponibles a un costo alto a través de la Organización Internacional de Normalización. Por eso, #link("https://pdfa.org/wtpdf/")[WTPDF] se diseñó de modo que todos los archivos conformes también puedan declarar conformidad con PDF/UA-2. Hoy, #link("https://pdfa.org/sponsored-standards/")[ambas partes de la especificación PDF/UA están disponibles sin cargo], lo que reduce la relevancia de WTPDF.

- *PDF/A-1a:* El estándar PDF/A describe cómo producir archivos PDF aptos para archivo a largo plazo. Las partes uno a tres del estándar PDF/A tienen varios niveles de conformidad. El nivel más estricto, A, contiene reglas de accesibilidad, ya que solo los archivos que las cumplen siguen siendo utilizables para la mayor variedad de personas en un futuro lejano. El nivel A implica conformidad con PDF etiquetado y te obliga a proporcionar descripciones alternativas para las imágenes. También se aplican otras reglas de PDF/A no relacionadas con la accesibilidad, por ejemplo sobre transparencia, colores y más. Esta parte del estándar PDF/A se basa en la desactualizada especificación PDF 1.4. Usala solo si tu ámbito lo exige o si necesitás un archivo muy compatible. De lo contrario, PDF/UA-1 y la segunda y tercera parte de PDF/A son mejores alternativas.

- *PDF/A-2a* y *PDF/A-3a:* Igual que la primera parte de PDF/A, estos estándares se enfocan en crear archivos aptos para archivo y almacenamiento a largo plazo. Ambos apuntan a la versión más nueva, PDF 1.7, en lugar de PDF 1.4. También acá el nivel de conformidad más estricto, A, contiene reglas de accesibilidad. Además de las reglas de PDF/A-1a, estos estándares prohíben el uso de caracteres de la #link("https://en.wikipedia.org/wiki/Private_Use_Areas")[Zona de uso privado de Unicode], cuyo significado no está definido universalmente. Las mejoras respecto de PDF/A-1 incluyen la posibilidad de usar transparencia y un mejor reflujo. Al elegir entre estas dos partes del estándar PDF/A, elegí PDF/A-2a a menos que necesites @pdf.attach[adjuntar] otros archivos. Tené en cuenta que el nivel de conformidad A se eliminó de PDF/A-4 a favor del estándar PDF/UA específico.

La @pdf.standard[página de referencia de PDF] contiene más información sobre cada estándar soportado. Para habilitar PDF/UA, PDF/A-2a o PDF/A-3a, usá el @pdf:command-line[indicador correspondiente en la CLI] o usá el menú desplegable de exportación y hacé clic en PDF en la app web. Podés combinar estándares PDF/A y PDF/UA que sean compatibles. Para documentos centrados en la accesibilidad, recomendamos combinar PDF/UA-1 con PDF/A-2a o PDF/A-3a.

Cuando seleccionás uno de estos estándares para la exportación a PDF, Typst detecta si estás infringiendo sus reglas y hace fallar la exportación con un mensaje de error descriptivo. Para la verificación de accesibilidad más estricta disponible actualmente, elegí PDF/UA-1. No desactives el etiquetado a menos que tengas una buena razón, ya que las etiquetas aportan una base de accesibilidad en todos los documentos que exportás.

Quizás ya notaste que algunos de los factores del Acceso universal son difíciles de verificar automáticamente. Por ejemplo, Typst actualmente no comprueba automáticamente que tus contrastes de color sean suficientes ni que el idioma natural configurado coincida con el idioma natural real (aunque la cantidad de errores del corrector ortográfico debería darte una pista si usás la app web). Hay dos estándares internacionales que abordan con más detalle algunos de estos factores humanos:

- Las *#link("https://www.w3.org/TR/WCAG21/")[Pautas de Accesibilidad para el Contenido Web (WCAG)]*: Diseñadas por el W3C, un gran consorcio internacional detrás de las tecnologías que hacen funcionar internet, describen cómo hacer accesible un sitio web. Todas estas reglas son aplicables a la salida HTML de Typst, y muchas se aplican a su salida PDF. WCAG separa sus reglas en tres niveles: A, AA y AAA. Se recomienda que los documentos normales apunten a AA. Si tenés altas exigencias de Acceso universal, también podés considerar los criterios de éxito AAA. Sin embargo, Typst todavía no expone todas las funciones de PDF necesarias para cumplir AAA, por ejemplo una forma accesible para las TA de definir las expansiones de abreviaturas.
- La *#link("https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf")[Norma Europea EN 301 549]*: Su sección 9 describe cómo crear sitios web accesibles y su sección 10 describe qué reglas se aplican a los documentos que no son web, incluidos los PDF creados por Typst. Señala qué cláusulas de WCAG son también aplicables a los PDF. Cumplir esta norma es un buen comienzo para cumplir las leyes de accesibilidad de la UE y nacionales.

Tené en cuenta que, para cumplir con EN 301 549 y las disposiciones relevantes de WCAG, tu documento debe estar etiquetado. Si apuntás a la conformidad, te sugerimos firmemente usar PDF/UA-1 para la exportación, de modo de automatizar muchas de las comprobaciones de los criterios de éxito que contiene.

Muchos territorios tienen legislación de accesibilidad que en algunas circunstancias exige crear archivos accesibles. Estos son solo algunos ejemplos:

- *#link("https://eur-lex.europa.eu/eli/dir/2019/882/oj")[Ley Europea de Accesibilidad (EAA, UE 2019/882)]*: Este reglamento se aplica a libros electrónicos, servicios bancarios para consumidores, servicios de comercio electrónico y más. Exige que los archivos distribuidos en estas aplicaciones sean accesibles.
- *Ley de Estadounidenses con Discapacidades (ADA)*: El Departamento de Justicia va a #link("https://www.ada.gov/law-and-regs/regulations/title-ii-2010-regulations/")[exigir a las organizaciones del sector público que proporcionen archivos] conformes con WCAG bajo el Título II de la ADA a partir de 2026. Asimismo, #link("https://www.boia.org/blog/the-robles-v.-dominos-settlement-and-why-it-matters")[las organizaciones privadas pueden ser consideradas responsables] por servicios digitales inaccesibles según la ADA y las leyes estatales.

Usar esta guía puede ayudarte a cumplir con cualquiera de las dos regulaciones.

= Pruebas de accesibilidad <testing-for-accessibility>
Para probar si tu documento PDF es accesible, podés usar herramientas automáticas y pruebas manuales. Algunos estándares, como PDF/UA y PDF/A, pueden verificarse exclusivamente con herramientas automáticas, mientras que algunas reglas de WCAG y otros estándares requieren comprobaciones manuales. Typst supera automáticamente muchas de las comprobaciones automatizables cuando el PDF etiquetado está habilitado. Para muchas otras comprobaciones automatizables, podés habilitar la exportación a PDF/UA-1 para que Typst las ejecute. Las herramientas automáticas solo pueden ofrecer una base de accesibilidad. Para un Acceso universal de verdad, lo mejor es que pruebes el documento vos mismo con una TA.

Esta es una lista de verificadores automáticos para probar la conformidad:

- *#link("https://verapdf.org")[veraPDF]:* Esta herramienta de código abierto puede comprobar si tu archivo PDF cumple con las partes de los estándares PDF/A y PDF/UA con las que declaró conformidad. Usala si elegiste uno de estos estándares al exportar. Las fallas se consideran errores de Typst y deberían #link("https://github.com/typst/typst/issues")[reportarse en GitHub].

- *#link("https://pac.pdf-accessibility.org/en")[PDF Accessibility Checker (PAC)]:* El programa gratuito PAC comprueba si tu documento cumple las reglas de PDF/UA y WCAG. Cuando recibís un error grave en la pestaña PDF/UA, se considera un error de Typst y debería #link("https://github.com/typst/typst/issues")[reportarse en GitHub]. Las advertencias en las pestañas PDF/UA y Quality pueden ser errores, problemas de tu documento o ninguna de las dos cosas. Consultá en el #link("https://forum.typst.app/")[foro] o en #link("https://discord.gg/2uDybryKPe")[Discord] si tenés dudas. Los errores y advertencias en la pestaña WCAG indican problemas de tu documento.

- *#link("https://helpx.adobe.com/acrobat/using/create-verify-pdf-accessibility.html")[Accessibility Check en Adobe Acrobat Pro]:* El verificador de accesibilidad de la versión paga de Adobe Acrobat revisa todos los documentos PDF en busca de problemas. En lugar de comprobar el cumplimiento de un estándar internacional o de la industria conocido, Adobe creó su propio conjunto de pruebas. Como las reglas detrás de estas pruebas a veces contradicen estándares internacionales como PDF/UA, es esperable que algunas comprobaciones de Acrobat fallen para documentos de Typst #footnote[Por ejemplo, al usar notas al pie, es esperable que falle la comprobación "Lbl and LBody must be children of LI" de la sección "List".]. Otras comprobaciones, como la de contraste, son útiles e indican problemas de tu documento.

Para las comprobaciones manuales, podés empezar con una lista de verificación. Si tu organización hace hincapié en la accesibilidad, a veces tiene la propia. Si no, podés probar listas de universidades como la #link("https://www.uni-bremen.de/fileadmin/user_upload/universitaet/Digitale_Transformation/Projekt_BALLON/Checklisten/2._Auflage_englisch/Checklist_for_accessible_PDF_ENG-US_ver2.pdf")[Universität Bremen (en inglés)] o de gobiernos, como la de #link("https://a11y.canada.ca/en/pdf-accessibility-checklist/")[Canadá] o la de la #link("https://www.ssa.gov/accessibility/checklists/PDF_508_Compliance_Checklist.pdf")[Administración del Seguro Social de EE. UU.]. Aunque estas listas difieren en su nivel de detalle, todas cubren las comprobaciones manuales más esenciales. Muchas de las comprobaciones técnicas que incluyen pueden omitirse si elegís la exportación a PDF/UA-1 en Typst. Si no sabés qué lista usar, elegí una de una organización culturalmente parecida a la tuya.

Sin embargo, para alcanzar el mayor nivel de accesibilidad en documentos de amplia circulación, considerá revisar tu documento con una TA. Aunque hay muchos productos de TA y visores de PDF, normalmente alcanza con probar una sola combinación. Cuál es la mejor depende de tu sistema operativo:

- Windows: Probá con #link("https://www.adobe.com/acrobat.html")[Adobe Acrobat] y #link("https://www.nvaccess.org/download/")[NVDA]. NVDA es software libre y de código abierto. Hay una versión gratuita de Acrobat disponible.
- macOS: Probá con #link("https://www.adobe.com/acrobat.html")[Adobe Acrobat] y #link("https://support.apple.com/guide/voiceover/welcome/mac")[VoiceOver]. VoiceOver es el lector de pantalla integrado en macOS y otras plataformas de Apple.
- Linux: Probá con #link("https://wiki.gnome.org/Apps/Evince/")[Evince] u #link("https://okular.kde.org/")[Okular] y #link("https://orca.gnome.org")[Orca]. Las tres herramientas son software libre y de código abierto. Sin embargo, el soporte de TA en las plataformas Linux está por detrás del disponible en Windows y macOS. Del mismo modo, Evince y Okular tienen menos soporte de accesibilidad que Acrobat. Te sugerimos firmemente probar con Acrobat.

Cuando recién empieces a hacer pruebas, considerá completar el programa de capacitación interactivo que ofrezca tu lector de pantalla, si lo tiene. Ganar confianza con un lector de pantalla te ayuda a vivir tu documento como lo haría un usuario habitual de lector de pantalla. Al revisar tu documento, verificá que no solo haga accesible toda la información disponible para un usuario vidente, sino que además sea fácil de navegar. La experiencia de tus usuarios va a variar según la combinación de visor de PDF y TA que usen.

= Límites y consideraciones sobre los formatos de exportación <limits-and-considerations-for-export-formats>
Aun cuando diseñes tu documento pensando en la accesibilidad, tenés que conocer las limitaciones de tu formato de exportación. En esencia, dar soporte de TA a los archivos PDF es más difícil que a otros formatos, como HTML. El PDF se concibió en 1993 para renderizar con fidelidad documentos impresos en una computadora. Las funciones de accesibilidad se agregaron por primera vez con PDF 1.4 en 2001 y mejoraron en PDF 1.5 (2003) y PDF 2.0 (2017). En cambio, HTML ofrece un modelo semántico más rico y más flexibilidad, por lo que el soporte de TA en los navegadores generalmente supera lo posible en los visores de PDF.

Tené en cuenta también que los archivos PDF son mayormente estáticos. Esto te permite ignorar muchas reglas de WCAG y EN 301 549 pensadas para contenido interactivo y multimedia. Sin embargo, la falta de interactividad también hace más difícil que los usuarios adapten el diseño de un documento a sus necesidades.

Por ejemplo, el #link("https://www.w3.org/WAI/WCAG21/Understanding/text-spacing.html")[criterio de éxito 1.4.12 de WCAG] (codificado en la cláusula 10.1.4.12 de EN 301 549) establece que el usuario debe poder aumentar el espaciado entre caracteres, letras, líneas y párrafos a valores muy amplios. Esto beneficia a usuarios con visión reducida o dislexia. El criterio de éxito no te exige diseñar tu documento con esos parámetros de diseño. Solo exige un mecanismo mediante el cual los usuarios puedan aumentarlos al leer el documento. En los archivos HTML es fácil cumplir este criterio porque el navegador le permite al usuario anular estos parámetros de espaciado en una página. En PDF, la situación es más matizada: en teoría, Typst agrega a un archivo etiquetas y atributos pensados para el reflujo. Un lector de PDF, al reflujar, podría permitirle al usuario aumentar los espaciados más allá de lo codificado en esas etiquetas. En la práctica, no conocemos ningún visor de PDF con esa función. En cambio, este criterio de éxito puede satisfacerse reutilizando el PDF como un archivo HTML y abriéndolo en un navegador.

En la práctica, incluso si tu archivo cumple técnicamente, no podés esperar que tus usuarios conozcan estas soluciones alternativas. Por lo tanto, si apuntás a cumplir los estándares más altos de Acceso universal, considerá distribuir una versión HTML de tu documento junto con el PDF. Exportá este archivo directamente con la @html[exportación a HTML] de Typst (en vista previa). Aunque la exportación a HTML no conserva muchos aspectos de tu diseño visual, produce un archivo que aprovecha HTML semántico y tecnologías como #link("https://www.w3.org/TR/dpub-aria-1.1/")[Digital Publishing ARIA] para ofrecer Acceso universal. Va a tener una calidad superior a la de un PDF reutilizado como HTML.

Por último, tené presente que los PDF están pensados para imprimirse. Por lo tanto, no des por sentado que las funciones interactivas, como los enlaces, estén disponibles para los usuarios que decidan imprimir tu documento.

Como se mencionó antes, los archivos creados con la exportación a PNG y SVG no son accesibles.
