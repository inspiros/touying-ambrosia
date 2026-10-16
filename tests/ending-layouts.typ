#import "../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "slides")
#let side = (left: left, right: right, top: top, bottom: bottom).at(sys.inputs.at("side", default: "right"))
#show: ambrosia-theme.with(
  flavor: sys.inputs.at("flavor", default: "minimal"),
  palette: sys.inputs.at("palette", default: "light"),
  text-size: float(sys.inputs.at("size", default: "18")) * 1pt,
  footcite-once: false, ending-layout: "plain",
  config-common(handout: mode == "handout", show-only-notes: mode == "notes",
    show-notes-on-second-screen: if mode == "second-screen" { side } else { none }),
  config-info(title: [Ending Layouts], author: [Presenter], emails: ("shared@example.org",),
    logo: self => box(height: 1em, text(size: 0.6em)[BRAND])),
)
#slide(title: [Sources])[#hidden-bibliography("../examples/bibliography.bib")]
#for name in extensions.ending-layout-names {
  ending-slide(layout: name, title: [Questions?])[
    BEFORE REVEAL #footnote[ORDINARY END NOTE]
    #pause
    AFTER REVEAL #footcite(<knuth84>)
    #speaker-note[ENDING PRESENTER NOTE]
  ]
}
#ending-slide(title: [Theme Default], contacts: none)[]
#ending-slide(layout: "split", title: [No Side Panel], contacts: none, logos: none)[FULL WIDTH END]
#ending-slide(layout: "cover", title: [Replaced Contacts], contacts: ("local@example.org", "local@example.org"))[]
