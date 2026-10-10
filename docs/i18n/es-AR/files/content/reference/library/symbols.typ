#import "../../../components/index.typ": (
  classnames, colors, docs-category, docs-section, fonts, icon,
  paged-heading-offset, prose-styling, search-box, ty-pill, use-icon,
)

// Symbols that are not rendered as themselves because they would be invisible.
#let symbol-overrides = (
  " ": "␣",
  "\u{00a0}": "nbsp",
  "\u{202F}": "nnbsp",
  "\u{00ad}": "shy",
  "\u{2002}": "ensp",
  "\u{2003}": "emsp",
  "\u{2004}": "⅓emsp",
  "\u{2005}": "¼emsp",
  "\u{2006}": "⅙emsp",
  "\u{205f}": "mmsp",
  "\u{2007}": "numsp",
  "\u{2008}": "puncsp",
  "\u{2009}": "thinsp",
  "\u{200a}": "hairsp",
  "\u{2060}": "wjoin",
  "\u{200D}": "zwj",
  "\u{200C}": "zwnj",
  "\u{200B}": "zwsp",
  "\u{200E}": "lrm",
  "\u{200F}": "rlm",
)

// Additional keywords for some symbols. Used to improve symbol search.
#let symbol-keywords = (
  "ħ": ("hbar",),
  "⇒": ("implies",),
  "⟹": ("implies",),
  "⇔": ("iff",),
  "⅋": ("par",),
  "א": ("alef",),
  "ב": ("bet",),
  "ד": ("dalet",),
)

// Human-facing names of the math classes.
#let math-class-names = (
  "normal": "Normal",
  "alphabetic": "Alphabetic",
  "binary": "Binary",
  "closing": "Closing",
  "diacritic": "Diacritic",
  "fence": "Fence",
  "glyphpart": "Glyph Part",
  "large": "Large",
  "opening": "Opening",
  "punctuation": "Punctuation",
  "relation": "Relation",
  "space": "Space",
  "unary": "Unary",
  "vary": "Vary",
  "special": "Special",
)

// Fonts that are used to display the symbols.
#let symbol-fonts = (
  // TODO: Maybe prefer Libertinus Serif for the full default look?
  // Note: Keep in sync with docs.css.
  fonts.body,
  "New Computer Modern Math",
  "Twitter Color Emoji",
)

#let copy-button() = html.button(
  class: "copy",
  icon(16, "copy", "Copiar"),
)

// The HTML template that is instantiated for the popup.
#let flyout-template() = {
  html.template(id: "flyout-template", html.div(class: "symbol-flyout", {
    html.div(class: "info", {
      html.button(class: "main", html.span(class: "sym"))
      html.div(class: "props", {
        html.h3(html.span(class: "unic-name"))
        html.p(class: "sym-deprecation", {
          use-icon(16, "warn", "Advertencia")
          html.span(class: "text")[Este símbolo está obsoleto]
        })
        html.p(class: "sym-name", {
          [Nombre: ]
          html.code()
          copy-button()
        })
        html.p(class: "shorthand", {
          [Atajo: ]
          html.code(class: "typ-escape")
          copy-button()
          html.span(class: "remark")
        })
        html.p(class: "escape", {
          [Escape: ]
          html.code(
            class: "typ-escape",
            html.span(class: "value"),
          )
          copy-button()
        })
        html.p(class: "accent", {
          [Acento: ]
          icon(16, "check", "Sí")
        })
        html.p(class: "math-class", {
          [Clase matemática: ]
          html.span(class: "value")
        })
        html.p(class: "latex-name", {
          [LaTeX: ]
          html.code()
        })
      })
    })
    html.div(class: "variants-box", {
      html.h4[Variantes]
      html.ul(class: "symbol-grid")
    })
  }))

  html.template(id: "flyout-sym-row", {
    html.li(html.button(html.span(class: "sym")))
  })
}

// One list entry in a symbol list or cell in a symbol grid.
#let symbol-entry(
  name,
  value,
  deprecation,
  alternates,
  shorthand: false,
) = {
  let attrs = (
    // This can possibly produce IDs that are not valid CSS identifiers, but we
    // don't need that so this is fine.
    id: "symbol-" + name,
    data-codex-name: if not shorthand { name },
    data-unic-name: stdx.unicode-name(value),
    data-latex-name: stdx.latex-name(value),
    data-keywords: symbol-keywords.at(value, default: ()).join(" ", default: ""),
    data-value: value,
    data-accent: if stdx.is-accent(value) { "true" },
    data-alternates: alternates.join(" ", default: none),
    data-markup-shorthand: stdx.shorthands.markup.at(value, default: none),
    data-math-shorthand: stdx.shorthands.math.at(value, default: none),
    data-math-class: {
      let class = stdx.math-class(value)
      if class != none { math-class-names.at(class) }
    },
    data-override: symbol-overrides.at(value, default: none),
    data-deprecation: deprecation,
  )

  let body = symbol-overrides.at(value, default: value)

  context if target() == "paged" {
    let style = if value in symbol-overrides {
      (fill: colors.dark-gray.shade-10, weight: 500, style: "italic")
    }
    box(width: 5em, h(1fr) + text(font: symbol-fonts, ..style, body) + h(1em))
    let wrapper = if deprecation != none { strike } else { it => it }
    if shorthand {
      text(fill: colors.text.syntax.teal, wrapper(raw(name)))
    } else {
      wrapper(raw(name))
    }
  } else {
    html.elem(
      "li",
      attrs: attrs.pairs().filter(p => p.last() != none).to-dict(),
      html.button({
        html.span(class: "sym", body)
        html.code(
          ..if shorthand { (class: "typ-escape") },
          if not shorthand {
            show ".": it => it + html.wbr()
            name
          } else {
            name
          },
        )
      }),
    )
  }
}

// Computes the entries to display in a symbol list / grid.
#let symbol-list-entries(mod, prefix) = {
  let entries = ()
  for (name, s) in dictionary(mod) {
    if type(s) == module {
      let nested-prefix = if prefix == none {
        name
      } else {
        prefix + "." + name
      }
      entries += symbol-list-entries(s, nested-prefix)
      continue
    }

    let info = stdx.describe(s)
    let binding = stdx.binding(mod, name)

    for (variant, value, deprecation) in info.variants {
      if deprecation == none and binding.deprecation != none {
        deprecation = binding.deprecation.message
      }

      let complete(v) = {
        if prefix != none {
          prefix + "."
        }
        name
        if v != "" {
          "." + v
        }
      }

      let full-name = complete(variant)
      let alternates = info
        .variants
        .map(((variant, ..)) => complete(variant))
        .filter(v => v != full-name)

      entries.push((
        value,
        symbol-entry(
          full-name,
          value,
          deprecation,
          alternates,
        ),
      ))
    }
  }
  entries
}

// A list / grid of symbols.
//
// Any page containing this should also contain a single `flyout-template()` in
// website export.
#let symbol-list(entries, emoji: false) = {
  context if target() == "paged" {
    columns(2, list(..entries, marker: none))
  } else {
    html.ul(
      class: classnames("symbol-grid", emoji: emoji),
      entries.join(),
    )
  }
}

// A list / grid of symbols with their names.
#let symbol-name-list(mod, emoji: false) = {
  let entries = symbol-list-entries(mod, none)
  if emoji {
    // Order entries in CLDR order.
    entries = entries.sorted(
      key: ((value, entry)) => value,
      by: stdx.emoji-ordering,
    )
  }
  symbol-list(
    entries.map(((_, entry)) => entry),
    emoji: emoji,
  )
}

// A list / grid of symbols with their shorthands.
#let symbol-shorthand-list(shorthands) = {
  let entries = shorthands.pairs().map(((value, shorthand)) => {
    symbol-entry(
      shorthand,
      value,
      none,
      (),
      shorthand: true,
    )
  })
  symbol-list(entries)
}

#docs-category(
  title: "Símbolos",
  description: "Símbolos predefinidos en Typst.",
  category: "symbols",
)[
  Los módulos @sym y @emoji les dan nombres a los símbolos y a los emojis para que sea fácil insertarlos con un teclado normal. Como alternativa, siempre podés ingresar directamente símbolos Unicode en tu texto y en tus fórmulas. Además de los símbolos enumerados a continuación, el modo matemático define `dif` y `Dif`. No son valores de símbolo normales porque también afectan el espaciado y el estilo de fuente.

  Podés definir símbolos personalizados con la función constructora del tipo @symbol.

  = Atajos <shorthands>
  Los atajos son secuencias concisas de caracteres que evocan glifos específicos. Los atajos y otras formas de producir símbolos se pueden usar indistintamente. Podés usar distintos conjuntos de atajos en modo matemático y en modo marcado. Algunos atajos, como `~` para un espacio de no separación, producen símbolos que no se imprimen, que se indican con texto provisorio en gris.

  Podés desactivar la interpretación de un atajo escapando cualquiera de sus caracteres. Si escapás un solo carácter de un atajo, los caracteres restantes sin escapar pueden formar un atajo distinto.

  == En modo marcado <within-markup-mode>
  #symbol-shorthand-list(stdx.shorthands.markup)

  == En modo matemático <within-math-mode>
  #symbol-shorthand-list(stdx.shorthands.math)

  #context if target() == "html" {
    flyout-template()
  }
]

#let symbols-section(..args, mod: none, emoji: false, body) = docs-section(
  ..args,
  kind: stdx.ui("Symbol list"),
  {
    prose-styling(body)
    context if target() == "html" {
      html.div(class: "symbol-hint", {
        par[Hacé clic en un #ty-pill(symbol) para copiarlo al portapapeles.]
        search-box(id: "symbol-search", placeholder: "Buscar en los símbolos")
      })
    }
    symbol-name-list(mod, emoji: emoji)
    context if target() == "html" {
      flyout-template()
    }
  },
)

#show: paged-heading-offset.with(1)

#symbols-section(
  title: "Símbolos generales",
  route: "/reference/symbols/sym",
  def-target: <sym>,
  description: "Documentación del módulo `sym`, que les da nombres a los símbolos.",
  mod: sym,
)[
  Símbolos generales con nombre.

  Por ejemplo, `[#sym.arrow]` produce el símbolo →. Dentro de la @math[matemática], estos símbolos se pueden usar sin el prefijo `[#sym.]`.

  La `d` de `dx` en una integral se puede escribir como `[$dif x$]`. Fuera de las fórmulas matemáticas, se puede acceder a `dif` como `math.dif`.
]

#symbols-section(
  title: "Emoji",
  route: "/reference/symbols/emoji",
  def-target: <emoji>,
  description: "Documentación del módulo `emoji`, que les da nombres a los emojis.",
  mod: emoji,
  emoji: true,
)[
  Emojis con nombre.

  Por ejemplo, `[#emoji.face]` produce el emoji 😀. Si usás con frecuencia ciertos emojis, también podés importarlos del módulo `emoji` (`[#import emoji: face]`) para usarlos sin el prefijo `emoji.`.
]
