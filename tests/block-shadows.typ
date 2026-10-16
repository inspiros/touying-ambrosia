#import "../src/lib.typ": *
#import "../examples/showcase.typ": watermark
#show: ambrosia-theme.with(watermark-logo: watermark,flavor: "minimal", watermark: false,
  palette: sys.inputs.at("palette", default: "light"),
  text-size: int(sys.inputs.at("size", default: "18")) * 1pt,
  config-info(title: [Panel shadows], author: [Tester]),
)

#slide(title: [Separate poster panels])[
  #ambrosia-block(style: "poster", shadowed: true, gap: 1em, title: [SPLIT HEADER])[
    SPLIT BODY. The gap between these two panels remains open.
  ]
]

#slide(title: [Transparent outlined panels])[
  #place(top + left, dy: 2em, block(width: 100%, height: 2em,
    fill: yellow.transparentize(75%), []))
  #ambrosia-block(style: "outlined", shadowed: true, title: [OUTLINE HEADER])[
    OUTLINE BODY. The stripe behind this panel remains visible.
    #v(1em)
    The shadow follows the border, leaving the interior transparent.
  ]
]

#slide(title: [No surface, no shadow])[
  #ambrosia-block(style: "plain", background: none, stroke: none, shadowed: true,
    title: [BORDERLESS HEADER])[BORDERLESS BODY. There is no panel silhouette.]
]

#slide(title: [A filled heading with a transparent body])[
  #ambrosia-block(style: "framed", background: none, shadowed: true,
    title: [FRAMED HEADER])[FRAMED BODY. Only the heading and border cast shadows.]
]

#slide(title: [Nesting, animations, watermarks, and citations])[
  #ambrosia-block(style: "poster", shadowed: true, watermark: "title", title: [OUTER HEADER])[
    #ambrosia.block(style: "outlined", shadowed: true, watermark: "body", title: [INNER HEADER])[
      BEFORE REVEAL. #footnote[ORDINARY NOTE]
      #pause
      AFTER REVEAL. #footcite(<knuth84>)
    ]
  ]
  #hidden-bibliography("../examples/bibliography.bib")
]
