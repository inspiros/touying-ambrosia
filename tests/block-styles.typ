#import "../src/lib.typ": *
#import "../src/lib.typ": extensions
#let block-style-names = extensions.block-style-names
#let block-kinds = extensions.block-kinds
#show: ambrosia-theme.with(flavor: "minimal", palette: sys.inputs.at("palette", default: "light"),
  block-style: "poster", config-info(title: [Containers], author: [Tester]))

#for style in block-style-names {
  slide(title: [Style: #style])[
    #ambrosia-block(style: style, title: [Outer #style])[
      #ambrosia-block(style: "outlined", title: [Nested])[
        Visible before. #pause Nested revealed.
      ]
      #uncover("2-")[#alert[Visible after.]]
    ]
  ]
}

#slide(title: [Semantic variants])[
  #grid(columns: (1fr, 1fr, 1fr), gutter: 0.5em,
    ..block-kinds.map(kind => ambrosia-block(title: kind, kind: kind)[Semantic panel.]),
  )
]

#slide(title: [Overrides and context])[
  #context ambrosia-block(style: "poster", fill: yellow, background: black, title: [Custom colors])[
    Contrasting text on custom colors.
    #ambrosia-block(style: "stripe", kind: "success")[Nested contextual body.]
  ]
  #ambrosia-block(style: "framed", background: none, title: "Transparent")[Transparent body.]
  #ambrosia-block(style: "framed", title: [Explicit framed style])[Framed body.]
]
