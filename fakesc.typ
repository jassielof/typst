Default font with true small caps:
- Default: #smallcaps(lorem(20))
- Forced as false: #{
  set text(features: ("smcp": 0))
  smallcaps(typographic: true,  lorem(20))
}
- Forced as true: #{
  set text(features: ("smcp": 0))
  smallcaps(typographic: false, lorem(20))
}

Setting to a font without true small caps (IBM Plex Serif):
#set text(font: "IBM Plex Serif")
- Default: #smallcaps(lorem(20))
  - Different size: #smallcaps(size: 0.5em, lorem(20))

// Extra tests:
// - #smallcaps(synthetic: false, lorem(20))
// - #smallcaps(synthetic: true, lorem(20))
// - #smallcaps(all: true, synthetic: true, lorem(20))
// #show smallcaps: set text(tracking: 0.1cm)
// - #smallcaps(synthetic: true, lorem(20))
// #show smallcaps: set text(tracking: 0cm, stroke: 0.1em)
// - #smallcaps(synthetic: true, lorem(20))
// #show smallcaps: set text(tracking: 0cm, stroke: 0.01em, size: 0.8em)
// - #smallcaps(synthetic: true, lorem(20))
// #show smallcaps: scale.with(x: 150%, reflow: true)
// - #smallcaps(synthetic: true, lorem(20))
