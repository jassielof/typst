#set page(margin: 1cm, width: 8in, height: auto)

#let weights = (
  "thin",
  "light",
  "regular",
  "medium",
  "semibold",
  "bold",
  "extrabold",
  "black",
)

#let styles = (
  "normal",
  "italic",
  "oblique",
)

#let fonts = (
  "source serif 4",
  "source sans 3",
  "source code pro",
  "montserrat",
  "roboto",
  "open sans",
  "merriweather",
  "inter",
  "ibm plex sans",
  "google sans flex",
)

#let sample-text = [Whereas recognition of the inherent dignity]

#for f in fonts {
  let styled-texts = ()

  for w in range(100, 1000, step: 100) {
    styled-texts.push(strong[#w])
    for s in styles {
      styled-texts.push(
        text(
          font: f,
          weight: w,
          style: s,
          sample-text,
        ),
      )
    }
  }

  figure(
    table(
      columns: 4,
      rows: 9,
      align: left,
      table.header([], [*Normal*], [*Italic*], [*Oblique*]),
      ..styled-texts,
    ),
    caption: upper(strong(f)),
  )
}

