#import "../src/lib.typ": *
#let paint = sys.inputs.at("background", default: "auto")
#let paint = {
  if paint == "auto" { auto } else if paint == "none" { none }
  else if paint == "custom" { rgb("e8e2dc") } else { false }
}
#show: ambrosia-theme.with(flavor: "portico",
  ..if "background" in sys.inputs { (sidebar-background: paint,) } else { (:) },
  palette: sys.inputs.at("palette", default: "ocean"),
  navigation-side: sys.inputs.at("side", default: "right"),
  config-common(new-section-slide-fn: none),
  config-info(title: [Optional Sidebar Paint], author: [Tester]))
#let probe() = layout(size => [#metadata((width: size.width.pt()))<sidebar-background-body>])
= Research
== Theme Setting
#probe()
The theme selects the initial paint.
#slide(title: [Transparent Override], config: config-store(sidebar-background: none))[
  #probe()
  This slide keeps the same layout with a transparent sidebar.
]
#slide(title: [Color Override], config: config-store(sidebar-background: rgb("e8e2dc")))[
  #probe()
  A solid color override also selects readable label colors.
]
