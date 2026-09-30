#import "../../../components/index.typ": docs-category, scope

#show: docs-category.with(
  title: "Fundamentos",
  description: "Documentación de las definiciones fundamentales que forman la base de Typst.",
  category: "foundations",
  scope-additions: (
    "none": type(none),
    "auto": type(auto),
  ),
  groups: (
    (
      name: "calc",
      def-target: calc,
      title: "Cálculo",
      scope: scope(std, "calc"),
      definitions: dictionary(calc),
      description: "Documentación del módulo `calc`, que contiene definiciones para el cálculo matemático.",
      docs: [
        Módulo para cálculos y procesamiento de valores numéricos.

        Estas definiciones forman parte del módulo `calc` y no se importan por defecto.
      ],
    ),
    (
      name: "std",
      def-target: std,
      title: "Biblioteca estándar",
      definitions: (:),
      description: "Documentación del módulo `std`, que contiene todos los elementos accesibles globalmente.",
      docs: [
        Un módulo que contiene todos los elementos accesibles globalmente.

        = Usar definiciones "ocultas" (shadowed) <using-shadowed-definitions>
        El módulo `std` es útil siempre que hayas reemplazado un nombre del ámbito global (esto se llama _shadowing_). Por ejemplo, podrías haber usado el nombre `text` para un parámetro. Para poder seguir accediendo al elemento `text`, escribí `std.text`.

        ```example
        >>> #set page(margin: (left: 3em))
        #let par = [My special paragraph.]
        #let special(text) = {
          set std.text(style: "italic")
          set std.par.line(numbering: "1")
          text
        }

        #special(par)

        #lorem(10)
        ```

        = Acceso condicional <conditional-access>
        También podés usar esto en combinación con el @dictionary.constructor[constructor de diccionarios] para acceder condicionalmente a definiciones globales. Esto puede ser útil, por ejemplo, para usar funcionalidad nueva o experimental cuando está disponible, recurriendo a una implementación alternativa si se usa en una versión más antigua de Typst. En particular, esto nos permite crear #link("https://en.wikipedia.org/wiki/Polyfill_(programming)")[polyfills].

        Puede ser tan simple como crear un alias para evitar mensajes de advertencia, por ejemplo, usar condicionalmente `pattern` en la versión 0.12 de Typst, pero usar @tiling en las versiones más nuevas. Como los parámetros que acepta la función `tiling` coinciden con los de la antigua función `pattern`, usar la función `tiling` cuando esté disponible y recurrir a `pattern` en caso contrario unificará el uso en todas las versiones. Tené en cuenta que, al crear un polyfill, @sys.version también puede ser muy útil.

        ```typ
        #let tiling = if "tiling" in std { tiling } else { pattern }

        ...
        ```
      ],
    ),
    (
      name: "sys",
      def-target: sys,
      title: "Sistema",
      scope: scope(std, "sys"),
      definitions: dictionary(sys),
      description: "Documentación del módulo `sys` para las interacciones con el sistema.",
      docs: [
        Módulo para las interacciones con el sistema.
      ],
    ),
  ),
)

Tipos y funciones fundamentales.

Acá vas a encontrar documentación de los tipos de datos básicos, como los @int[enteros] y las @str[cadenas de texto], así como detalles sobre las funciones de cálculo centrales.
