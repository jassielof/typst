#set page(width: 600pt, margin: 40pt)
#set text(size: 11pt)

= Synthetic Small Caps - Comprehensive Tests

== Basic Functionality

=== Default Font (Libertinus Serif - has true small caps)

*Default behavior (typographic: true, automatic fallback):*
#smallcaps[Hello World]

*Forced typographic (should use font features):*
#{
  set text(features: ("smcp": 1))
  smallcaps(typographic: true)[Hello World]
}

*Forced synthesis (typographic: false):*
#{
  set text(features: ("smcp": 0))
  smallcaps(typographic: false)[Hello World]
}

*With all: true (uppercase also becomes small caps):*
#smallcaps(all: true)[Hello WORLD]

*With all: false (only lowercase becomes small caps):*
#smallcaps(all: false)[Hello WORLD]

=== Font Without Small Caps (IBM Plex Serif)

#set text(font: "IBM Plex Serif")

*Default (should auto-synthesize):*
#smallcaps[Hello World]

*Explicit typographic: true (should auto-synthesize):*
#smallcaps(typographic: true)[Hello World]

*Explicit typographic: false (forced synthesis):*
#smallcaps(typographic: false)[Hello World]

*With all: true:*
#smallcaps(all: true)[Hello WORLD]

*With all: false:*
#smallcaps(all: false)[Hello WORLD]

== Synthesis Parameters

=== Size Customization

#set text(font: "IBM Plex Serif")

*Default size (0.75em):*
#smallcaps(typographic: false)[Hello World]

*Smaller (0.5em):*
#smallcaps(typographic: false, size: 0.5em)[Hello World]

*Larger (0.8em):*
#smallcaps(typographic: false, size: 0.8em)[Hello World]

*Custom (0.65em):*
#smallcaps(typographic: false, size: 0.65em)[Hello World]

=== Expansion Customization

#set text(font: "IBM Plex Serif")

*Default expansion (1.05):*
#smallcaps(typographic: false)[Hello World]

*No expansion (100%):*
#smallcaps(typographic: false, expansion: 100%)[Hello World]

*More expansion (110%):*
#smallcaps(typographic: false, expansion: 110%)[Hello World]

*Less expansion (102%):*
#smallcaps(typographic: false, expansion: 102%)[Hello World]

== Mixed Case Scenarios

#set text(font: "IBM Plex Serif")

*Mixed case with all: false (only lowercase should be small caps):*
#smallcaps(typographic: false, all: false)[Hello World Test]

*Mixed case with all: true (all letters should be small caps):*
#smallcaps(typographic: false, all: true)[Hello World Test]

*Numbers and punctuation:*
#smallcaps(typographic: false)[Hello 123 World!]

*Mixed with uppercase at start:*
#smallcaps(typographic: false, all: false)[HELLO world]

== Show Rules Integration

#set text(font: "IBM Plex Serif")

*Show rule with tracking:*
#show smallcaps: set text(tracking: 0.1cm)
#smallcaps(typographic: false)[Hello World]

*Show rule with stroke:*
#show smallcaps: set text(stroke: 0.01em)
#smallcaps(typographic: false)[Hello World]

*Show rule with size:*
#show smallcaps: set text(size: 0.8em)
#smallcaps(typographic: false)[Hello World]

*Show rule with multiple properties:*
#show smallcaps: set text(tracking: 0.05cm, stroke: 0.01em, size: 0.75em)
#smallcaps(typographic: false)[Hello World]

== Edge Cases

#set text(font: "IBM Plex Serif")

*Empty text:*
#smallcaps(typographic: false)[]

*Single character:*
#smallcaps(typographic: false)[a]

*All uppercase:*
#smallcaps(typographic: false, all: false)[HELLO]

*All lowercase:*
#smallcaps(typographic: false, all: false)[hello]

*Only numbers:*
#smallcaps(typographic: false)[12345]

*Only punctuation:*
#smallcaps(typographic: false)[!\@\#\$%]

== Unicode and Special Characters

#set text(font: "IBM Plex Serif")

*Accented characters:*
#smallcaps(typographic: false)[Café naïve résumé]

*German characters:*
//#smallcaps(typographic: false)[Straße München]

*Mixed scripts:*
#smallcaps(typographic: false)[Hello 你好 World]

== Long Text (Justification Test)

#set text(font: "IBM Plex Serif")
#set par(justify: true)

*Long paragraph with small caps (should justify correctly):*
#smallcaps(typographic: false)[
  Lorem ipsum dolor sit amet, consectetur adipiscing elit.
  Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
  Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.
]

== Global Settings

#set text(font: "IBM Plex Serif")

*Global small caps settings:*
#set smallcaps(typographic: false, size: 0.75em, expansion: 105%)
#smallcaps[Hello World]

*Override global with local:*
#smallcaps(size: 0.8em)[Hello World]

== Comparison: Typographic vs Synthetic

#set text(font: "Libertinus Serif")

*Side by side comparison:*

#grid(
  columns: 2,
  gutter: 20pt,
  [*Typographic (font features)*],
  [*Synthetic (forced)*],
  [#smallcaps(typographic: true)[Hello World]],
  [#smallcaps(typographic: false)[Hello World]],
)

== Font Feature Control

#set text(font: "Libertinus Serif")

*Disable font features, use synthesis:*
#{
  set text(features: ("smcp": 0, "c2sc": 0))
  smallcaps(typographic: true)[Hello World]
}

*Enable font features explicitly:*
#{
  set text(features: ("smcp": 1, "c2sc": 1))
  smallcaps(typographic: true, all: true)[Hello WORLD]
}

== Nested Small Caps

#set text(font: "IBM Plex Serif")

*Small caps within small caps:*
#smallcaps(typographic: false)[
  Hello #smallcaps(typographic: false)[Nested] World
]

== Real-World Examples

#set text(font: "IBM Plex Serif")

*Acronyms:*
#smallcaps(typographic: false)[NASA FBI CIA]

*Abbreviations:*
#smallcaps(typographic: false)[Dr. Mr. Mrs. Prof.]

*Titles:*
#smallcaps(typographic: false)[The Art of Typography]

== Performance Test (Long Text)

#set text(font: "IBM Plex Serif")

*Long text with synthesis:*
#smallcaps(typographic: false)[
  #lorem(100)
]

