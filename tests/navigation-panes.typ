#import "../src/lib.typ": *
#show: ambrosia-theme.with(flavor: "cambridge", navigation: "panes",
  palette: sys.inputs.at("palette", default: "ocean"),
  navigation-buttons: true, config-common(new-section-slide-fn: none),
  config-info(title: [Two Navigation Panes], author: [Presenter]))
#let probe(id) = layout(size => context [#metadata((id: id, height: size.height.pt(), width: size.width.pt()))<pane-body>])
= Discover
#for index in range(1, 13) {
  heading(depth: 2)[Topic #index With A Long Subsection Label]
  heading(depth: 3)[Slide #index]
  [BODYMARKER]
  if index == 1 { pause; [A second frame.] }
}
#slide(title: [A Normal Slide])[#probe("normal") BODYMARKER]
#slide(title: [A Local Override], config: config-store(navigation: none))[
  #probe("disabled") BODYMARKER
]
= Build
== Another Topic
=== Another Slide
BODYMARKER
= A Section Without Subsections
#slide(title: [No Subsections])[BODYMARKER]
#show: appendix
= Supporting Material
== Evidence
=== Backup
BODYMARKER
