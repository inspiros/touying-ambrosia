#import "../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "styled")
#show: ambrosia-theme.with(
  palette: sys.inputs.at("palette", default: "ocean"),
  text-size: float(sys.inputs.at("size", default: "18")) * 1pt,
  code-style: if mode == "plain" { "plain" } else { "surface" },
  quote-style: if mode == "plain" { "plain" } else { "stripe" },
  config-info(title: [Text Styling], author: [Tester]),
)
#let record(role, background: auto) = context [#metadata((role: role,
  size: text.size.pt(), weight: text.weight, ink: text.fill.to-hex(),
  background: if background == auto { page.fill.to-hex() } else { background.to-hex() },
))<ambrosia-text-probe>]

#slide(title: [Inline Hierarchy])[
  #record("normal")NORMAL
  #muted[#record("muted")MUTED]
  #subtle[#record("subtle")SUBTLE]
  #text(size: 1.25em, weight: "bold")[#ambrosia.muted[#record("large")LARGE]]
  Inline #raw("inline_token", lang: "python") stays inline.
  #context [#ambrosia.subtle[#record("late")LATE CONTEXT]]
]

#slide(title: [A Different Panel Surface])[
  #ambrosia-block(style: "framed", title: [PANEL], background: rgb("141824"))[
    #muted[#record("panel-muted", background: rgb("141824"))PANEL MUTED]
    #subtle[#record("panel-subtle", background: rgb("141824"))PANEL SUBTLE]
    #pause
    #muted[REVEALED TEXT]
  ]
]

#slide(title: [Native Quotation])[
  Inline #quote[INLINE QUOTE].
  #quote(block: true, attribution: link("https://example.org")[ATTRIBUTION])[
    QUOTED TEXT#footnote[QUOTATION NOTE].
    #pause
    REVEALED QUOTATION.
  ]
]

#slide(title: [Native Raw])[
  ```python
  def native_code(value):
      return value + 1
  ```
  #raw("EXPLICIT THEME", lang: "text", theme: none, block: true)
]

#slide(title: [A Local Surface], config: config-page(fill: rgb("301424")))[
  #muted[#record("local-muted")LOCAL MUTED]
  #subtle[#record("local-subtle")LOCAL SUBTLE]
]
