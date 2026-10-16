#import "../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "slides")
#let notes-side = (left: left, right: right, top: top, bottom: bottom).at(sys.inputs.at("notes-side", default: "right"))
#let depth = int(sys.inputs.at("depth", default: "2"))
#let tall = sys.inputs.at("height", default: "auto") == "tall"
#show: ambrosia-theme.with(
  flavor: "cambridge", palette: sys.inputs.at("palette", default: "ocean"),
  navigation: ambrosia-navigation(base: "tree", depth: depth, height: if tall { 3em } else { auto }),
  config-common(new-section-slide-fn: none, handout: mode == "handout", show-only-notes: mode == "notes", article-mode: mode == "article",
    show-notes-on-second-screen: if mode == "second-screen" { notes-side } else { none }),
  config-info(title: [A Long Talk Title], short-title: [Tree Talk], author: [Presenter]),
)
#let probe(id) = layout(size => context [#metadata((id: id, width: size.width.pt(), height: size.height.pt()))<tree-test-body>])
#slide(title: [Before The First Section])[#probe("before") No branch has been selected.]
= First Section With A Very Long Name That Must Stay On One Header Line Even On A Narrow Page
#slide(title: [Animated Context])[
  #probe("animated")
  #heading(depth: 2)[Initial Context With A Deliberately Long Heading Which Must Be Clipped To One Line]
  FIRSTFRAME
  #speaker-note[Presenter Notes]
  #pause
  #heading(depth: 2)[Revealed Context]
  SECONDFRAME
]
#slide(title: [No Structural Navigation], config: config-store(navigation: none))[
  #probe("disabled") Locally disabled navigation recovers its space.
]
= Second Section Without A Subsection
#slide(title: [Empty Child])[#probe("empty") A missing child must not reuse the last section's child.]
#show: appendix
= Appendix Section
== Appendix Context
=== Supporting Evidence
#probe("appendix")
Appendix Body
