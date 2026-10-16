#import "../src/lib.typ": *
#show: ambrosia-theme.with(
  flavor: sys.inputs.at("flavor", default: "minimal"),
  palette: sys.inputs.at("palette", default: "nocturne"),
  text-size: float(sys.inputs.at("text-size", default: "18")) * 1pt,
  footer-aa: [LeftEdge], footer-ab: none, footer-ac: none, footer-ad: [RightEdge],
  config-info(title: [Typography], author: [Tester]),
)

#let record(role) = context [#metadata((role: role, size: text.size.pt()))<ambrosia-type-test>]

#slide(title: [Readable proportions])[
  #record("body")Body text.
  #figure(
    table(columns: 2, [#record("table")Method], [Score], [Baseline], [0.74]),
    caption: [#record("caption")Caption text.],
  )
  #ambrosia-block(title: [Block preset])[A block with sizes relative to the deck font.]
]
