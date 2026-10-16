#import "../src/lib.typ": *
#import "../examples/showcase.typ": watermark
#show: ambrosia-theme.with(watermark-logo: watermark,
  flavor: sys.inputs.at("flavor", default: "minimal"),
  palette: sys.inputs.at("palette", default: "light"),
  watermark: true,
  config-info(title: [Quiet branding], author: [Tester]),
)
#title-slide()
#outline-slide()

= Branded containers
Section introduction.

== Marks follow their surfaces
#ambrosia-block(style: "poster", watermark: "body", title: [A quiet body])[
  A source inside a decorated panel #footcite(<knuth84>).
  #pause
  #ambrosia-block(style: "outlined", watermark: true, title: [Nested])[
    Nested content remains visible.
  ]
]

== Marks in headings
#ambrosia-block(style: "poster", watermark: "title", kind: "info", title: [Observation])[
  A decorated title bar.
]
#ambrosia-block(style: "framed", watermark: true, fill: yellow, background: black, title: [Custom contrast])[
  Readable text on a custom background.
]
#hidden-bibliography("../examples/bibliography.bib")

#title-slide(watermark: false, title: [Disabled on this slide])
#outline-slide(watermark: false)
