#import "../../../components/index.typ": docs-chapter

#show: docs-chapter.with(
  title: "Estilos",
  route: "/reference/styling",
  description: "Todos los conceptos necesarios para dar estilo a tu documento con Typst.",
)

Typst incluye un sistema de estilos flexible que aplica automáticamente a tu documento los estilos que elijas. Con las _reglas set,_ podés configurar las propiedades básicas de los elementos. De esta manera creás la mayoría de los estilos comunes. Sin embargo, puede que no haya una propiedad incorporada para todo lo que querés hacer. Por eso, Typst también admite las _reglas show,_ que pueden redefinir por completo el aspecto de los elementos.

= Reglas set <set-rules>
Con las reglas set, podés personalizar el aspecto de los elementos. Se escriben como una @function[llamada a función] de una @function:element-functions[función de elemento] precedida de la palabra clave `{set}` (o `[#set]` en marcado). A la regla set solo se le pueden proporcionar los parámetros opcionales de esa función. Consultá la documentación de cada función para ver cuáles parámetros son opcionales. En el siguiente ejemplo, usamos dos reglas set para cambiar la @text.font[familia de fuente] y la @heading.numbering[numeración de los títulos].

```example
#set heading(numbering: "I.")
#set text(
  font: "New Computer Modern"
)

= Introduction
With set rules, you can style
your document.
```

Una regla set de nivel superior sigue vigente hasta el final del archivo. Cuando está anidada dentro de un bloque de código o de contenido, solo está vigente hasta el final de ese bloque. Con un bloque, podés entonces restringir el efecto de una regla a un segmento particular de tu documento. A continuación, usamos un bloque de contenido para limitar el estilo de lista a una lista en particular.

```example
This list is affected: #[
  #set list(marker: [--])
  - Dash
]

This one is not:
- Bullet
```

A veces vas a querer aplicar una regla set de forma condicional. Para eso, podés usar una regla _set-if._

```example
#let task(body, critical: false) = {
  set text(red) if critical
  [- #body]
}

#task(critical: true)[Food today?]
#task(critical: false)[Work deadline]
```

= Reglas show <show-rules>
Con las reglas show, podés personalizar en profundidad el aspecto de un tipo de elemento. La forma más básica de regla show es una _regla show-set._ Una regla así se escribe con la palabra clave `{show}` seguida de un @selector[selector], dos puntos y luego una regla set. La forma más básica de selector es una @function:element-functions[función de elemento]. Esto hace que la regla set se aplique solo al elemento seleccionado. En el siguiente ejemplo, los títulos se vuelven azul oscuro mientras que todo el resto del texto sigue en negro.

```example
#show heading: set text(navy)

= This is navy-blue
But this stays black.
```

Con las reglas show-set podés combinar propiedades de distintas funciones para lograr muchos efectos diferentes. Pero igual te limitan a lo que está predefinido en Typst. Para lograr la máxima flexibilidad, podés escribir en cambio una regla show _de transformación_ que defina cómo dar formato a un elemento desde cero. Para escribir una regla show así, reemplazá la regla set que va después de los dos puntos por una @function[función] arbitraria. Esta función recibe el elemento en cuestión y puede devolver contenido arbitrario. La función suele definirse en línea como `{it => ..}` usando la @function:unnamed[sintaxis de función sin nombre]. Por convención, el parámetro de la función suele llamarse `it`.

Los @reference:scripting:fields[campos] disponibles en el elemento que se le pasa a la función coinciden con los parámetros de la función de elemento respectiva. A continuación, definimos una regla show que da formato a los títulos de una enciclopedia de fantasía.

La regla show en sí agrega caracteres de tilde alrededor del título (hay que escaparlos con una barra invertida porque, de lo contrario, indicarían un espacio de no separación), resalta el título en cursiva y después muestra el contador de títulos a continuación del título.

Para este ejemplo, también queríamos alineación centrada y una fuente diferente. Si bien podríamos haber agregado estas reglas set dentro de la regla show existente, las agregamos como reglas show-set separadas. Esta es una buena práctica porque así estas reglas todavía pueden ser sobrescritas por reglas show-set posteriores del documento, lo que mantiene los estilos componibles. En cambio, las reglas set dentro de una regla show de transformación ya no se podrían sobrescribir.

```example
#set heading(numbering: "(I)")
#show heading: set align(center)
#show heading: set text(font: "Inria Serif")
#show heading: it => block[
  \~
  #emph(it.body)
  #counter(heading).display()
  \~
]

= Dragon
With a base health of 15, the dragon is the most
powerful creature.

= Manticore
While less powerful than the dragon, the manticore
gets extra style points.
```

Al igual que las reglas set, las reglas show están vigentes hasta el final del bloque o archivo actual.

En lugar de una función, el lado derecho de una regla show también puede tomar una cadena de texto literal o un bloque de contenido que se sustituya directamente por el elemento. Y además de una función, el lado izquierdo de una regla show también puede tomar otros _selectores_ que definen a qué aplicar la transformación:

- *Todo:* `{show: rest => ..}` \
  Transforma todo lo que sigue a la regla show. Es útil para aplicar un diseño más complejo a todo tu documento sin envolverlo todo en una llamada a una función gigante.

- *Texto:* `{show "Text": ..}` \
  Da estilo, transforma o reemplaza texto.

- *Regex:* `{show regex("\w+"): ..}` \
  Selecciona y transforma texto con una expresión regular para tener aún más flexibilidad. Mirá la documentación del @regex[tipo `regex`] para más detalles.

- *Función con campos:* `{show heading.where(level: 1): ..}` \
  Transforma solo los elementos que tienen los campos especificados. Por ejemplo, podrías querer cambiar solo el estilo de los títulos de nivel 1.

- *Etiqueta:* `{show <intro>: ..}` \
  Selecciona y transforma los elementos que tienen la etiqueta especificada. Mirá la documentación del @label[tipo `label`] para más detalles.

```example
#show "Project": smallcaps
#show "badly": "great"

We started Project in 2019
and are still working on it.
Project is progressing badly.
```
