#import "../../../components/index.typ": docs-chapter

#show: docs-chapter.with(
  title: "Contexto",
  route: "/reference/context",
  description: "Cómo tratar el contenido que reacciona a su ubicación en el documento.",
)

A veces queremos crear contenido que reaccione a su ubicación en el documento. Puede ser una frase localizada que dependa del idioma de texto configurado o algo tan simple como el número de un título que imprime el valor correcto según cuántos títulos vinieron antes. Sin embargo, el código de Typst no es directamente consciente de su ubicación en el documento. Un código al principio del texto fuente podría producir contenido que termine al final del documento.

Para producir contenido que reaccione a su entorno, tenemos entonces que indicárselo específicamente a Typst. Lo hacemos con la palabra clave `{context}`, que precede a una expresión y asegura que se calcule con conocimiento de su entorno. A cambio, la expresión de contexto en sí queda opaca. No podemos acceder directamente en nuestro código a lo que resulta de ella, precisamente porque es contextual: no hay un único resultado correcto, puede haber varios resultados en distintos lugares del documento. Por eso, todo lo que dependa de datos contextuales tiene que ocurrir dentro de la expresión de contexto.

Además de las expresiones de contexto explícitas, el contexto también se establece de forma implícita en algunos lugares que también son conscientes de su ubicación en el documento: las @reference:styling:show-rules[reglas show] proporcionan contexto #footnote[Actualmente, todas las reglas show proporcionan un @reference:context:style-context[contexto de estilo], pero solo las reglas show sobre elementos @location:locatable[localizables] proporcionan un @reference:context:location-context[contexto de ubicación].] y, por ejemplo, las numeraciones del índice también proporcionan el contexto adecuado para resolver contadores.

= Contexto de estilo <style-context>
Con las reglas set, podemos ajustar las propiedades de estilo de partes de nuestro documento o de todo él. No podemos acceder a ellas sin un contexto conocido, ya que pueden cambiar a lo largo del documento. Cuando hay un contexto disponible, podemos recuperarlas simplemente accediendo a ellas como campos de la función de elemento respectiva.

```example
#set text(lang: "de")
#context text.lang
```

Como se explicó antes, una expresión de contexto reacciona a los distintos entornos en los que se la coloca. En el siguiente ejemplo, creamos una sola expresión de contexto, la guardamos en la variable `value` y la usamos varias veces. Cada uso reacciona correctamente al entorno actual.

```example
#let value = context text.lang
#value

#set text(lang: "de")
#value

#set text(lang: "fr")
#value
```

Un punto clave: al crearse, `value` se convierte en @content[contenido] opaco al que no podemos echarle un vistazo. Solo se puede resolver cuando se lo coloca en algún lugar, porque solo entonces se conoce el contexto. El cuerpo de una expresión de contexto puede evaluarse cero, una o varias veces, según en cuántos lugares distintos se lo ponga.

= Contexto de ubicación <location-context>
Ya vimos que el contexto nos da acceso a los valores de las reglas set. Pero puede hacer más: también nos permite saber _dónde_ del documento estamos, en relación con otros elementos y de forma absoluta en las páginas. Podemos usar esta información para crear interacciones muy flexibles entre distintas partes del documento. Esto es lo que sustenta funciones como la numeración de títulos, el índice o los encabezados de página que dependen de los títulos de sección.

Algunas funciones, como @counter.get, acceden implícitamente a la ubicación actual. En el siguiente ejemplo, queremos recuperar el valor del contador de títulos. Como cambia a lo largo del documento, primero tenemos que entrar en una expresión de contexto. Después, usamos `get` para recuperar el valor actual del contador. Esta función accede a la ubicación actual desde el contexto para resolver el valor del contador. Los contadores tienen varios niveles y `get` devuelve un array con los números resueltos. Así obtenemos el siguiente resultado:

```example
#set heading(numbering: "1.")

= Introduction
#lorem(5)

#context counter(heading).get()

= Background
#lorem(5)

#context counter(heading).get()
```

Para tener más flexibilidad, también podemos usar la función @here para extraer directamente la @location[ubicación] actual del contexto. El siguiente ejemplo lo demuestra:

- Primero tenemos `{counter(heading).get()}`, que se resuelve en `{(2,)}` como antes.
- Después usamos la más potente @counter.at con @here, que en combinación equivale a `get`, y así obtenemos `{(2,)}`.
- Por último, usamos `at` con una @label[etiqueta] para recuperar el valor del contador en una ubicación _diferente_ del documento, en nuestro caso la del título de la introducción. Esto da `{(1,)}`. El sistema de contexto de Typst nos da capacidades de viaje en el tiempo y nos permite recuperar los valores de cualquier contador y estado en _cualquier_ ubicación del documento.

```example
#set heading(numbering: "1.")

= Introduction <intro>
#lorem(5)

= Background <back>
#lorem(5)

#context [
  #counter(heading).get() \
  #counter(heading).at(here()) \
  #counter(heading).at(<intro>)
]
```

Como mencionamos antes, también podemos usar context para obtener la posición física de los elementos en las páginas. Lo hacemos con la función @locate, que funciona de forma similar a `counter.at`: toma una ubicación u otro @selector[selector] que se resuelva en un elemento único (también puede ser una etiqueta) y devuelve la posición de ese elemento en las páginas.

```example
Background is at: \
#context locate(<back>).position()

= Introduction <intro>
#lorem(5)
#pagebreak()

= Background <back>
#lorem(5)
```

Hay otras funciones que usan el contexto de ubicación, la más destacada es @query. Mirá la categoría de @reference:introspection[introspección] para más detalles sobre ellas.

= Contextos anidados <nested-contexts>
El contexto también es accesible desde dentro de llamadas a funciones anidadas en bloques de contexto. En el siguiente ejemplo, `foo` en sí se convierte en una función contextual, igual que lo es @length.to-absolute[`to-absolute`].

```example
#let foo() = 1em.to-absolute()
#context {
  foo() == text.size
}
```

Los bloques de contexto se pueden anidar. El código contextual siempre accede entonces al contexto más interno. El siguiente ejemplo lo demuestra: el primer `text.lang` accede a los estilos del bloque de contexto externo y, por lo tanto, *no* ve el efecto de `{set text(lang: "fr")}`. El bloque de contexto anidado alrededor del segundo `text.lang`, en cambio, empieza después de la regla set y por eso muestra su efecto.

```example
#set text(lang: "de")
#context [
  #set text(lang: "fr")
  #text.lang \
  #context text.lang
]
```

Quizás te preguntes por qué Typst ignora la regla set del francés al calcular el primer `text.lang` del ejemplo anterior. La razón es que, en el caso general, Typst no puede conocer todos los estilos que se van a aplicar, ya que las reglas set se pueden aplicar al contenido después de haberlo construido. A continuación, `text.lang` ya está calculado cuando se aplica la función de plantilla. Por lo tanto, no puede ser consciente del cambio de idioma a francés en la plantilla.

```example
#let template(body) = {
  set text(lang: "fr")
  upper(body)
}

#set text(lang: "de")
#context [
  #show: template
  #text.lang \
  #context text.lang
]
```

El segundo `text.lang`, en cambio, _sí_ reacciona al cambio de idioma, porque la evaluación de su bloque de contexto circundante se difiere hasta que se conocen los estilos que le corresponden. Esto ilustra la importancia de elegir el punto de inserción correcto para un contexto, de modo de acceder precisamente a los estilos correctos.

Lo mismo vale para el contexto de ubicación. A continuación, la primera llamada a `{c.display()}` accede al bloque de contexto externo y, por lo tanto, no ve el efecto de `{c.update(2)}`, mientras que la segunda `{c.display()}` accede al contexto interno y, por lo tanto, sí lo ve.

```example
#let c = counter("mycounter")
#c.update(1)
#context [
  #c.update(2)
  #c.display() \
  #context c.display()
]
```

= Iteraciones del compilador <compiler-iterations>
Para resolver las interacciones contextuales, el compilador de Typst procesa tu documento varias veces. Por ejemplo, para resolver una llamada a `locate`, Typst primero proporciona una posición provisoria, compone tu documento y luego vuelve a compilar con la posición conocida a partir del diseño terminado. Se usa el mismo enfoque para resolver contadores, estados y consultas. En ciertos casos, Typst puede incluso necesitar más de dos iteraciones para resolverlo todo. Si bien a veces es una necesidad, también puede ser señal de un uso indebido de las funciones contextuales (por ejemplo, del @state:caution[estado]). Si Typst no puede resolver todo en cinco intentos, se detiene y muestra la advertencia "document did not converge within five attempts."

Un lector muy atento podría haber notado que no todas las funciones presentadas arriba usan realmente la ubicación actual. Si bien `{counter(heading).get()}` definitivamente depende de ella, `{counter(heading).at(<intro>)}`, por ejemplo, no. Sin embargo, igual requiere contexto. Aunque su valor es siempre el mismo _dentro_ de una iteración de compilación, puede cambiar a lo largo de varias iteraciones del compilador. Si se la pudiera llamar directamente en el nivel superior de un módulo, todo el módulo y sus exportaciones podrían cambiar a lo largo de varias iteraciones del compilador, lo cual no sería deseable.
