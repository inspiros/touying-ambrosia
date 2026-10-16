#import "../src/lib.typ": *
#import "../examples/showcase.typ": watermark
#show: ambrosia-theme.with(palette: sys.inputs.at("palette", default: "light"),
  text-size: float(sys.inputs.at("size", default: "18")) * 1pt,
  watermark-logo: watermark,
  config-info(title: [Tabbed Containers], author: [Tester]))

#slide(title: [Nested Reveals])[
  #ambrosia.block(style: "tabbed", title: [Outer], shadowed: true)[
    #ambrosia.block(style: "tabbed", title: [Inner], watermark: "title")[
      BEFORE REVEAL #footnote[ORDINARY NOTE]
      #pause
      AFTER REVEAL #footcite(<knuth84>)
    ]
  ]
  #hidden-bibliography("../examples/bibliography.bib")
]
#slide(title: [Long Titles And Transparent Bodies])[
  #ambrosia-block(style: "tabbed", width: 60%, background: none, shadowed: true,
    title: [A Longer Title That Wraps Within A Narrow Container And Stays Clear Of The Body])[
    BODY BELOW THE TAB
  ]
]
#slide(title: [A Body Without A Title])[
  #ambrosia-block(style: "tabbed", kind: "success")[UNTITLED BODY]
]
