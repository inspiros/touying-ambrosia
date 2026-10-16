#import "../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "slides")
#let placement = sys.inputs.at("placement", default: "footer")
#let side = (left: left, right: right, top: top, bottom: bottom).at(sys.inputs.at("notes-side", default: "right"))
#let footer = sys.inputs.at("footer", default: "default")
#let custom-footer(self) = {
  if self.store.navigation-definition.placement == "footer" { extensions.render-navigation-row(self) }
  text(size: 0.5em)[Custom Footer]
}
#show: ambrosia-theme.with(flavor: sys.inputs.at("flavor", default: "minimal"),
  navigation: ambrosia-navigation(base: "segments", placement: placement),
  navigation-buttons: true, section-progress: true,
  palette: sys.inputs.at("palette", default: "ocean"),
  text-size: int(sys.inputs.at("size", default: "18")) * 1pt,
  ..if footer == "hidden" { (config-page(footer: none),) }
    else if footer == "managed" { (config-page(footer: custom-footer), config-store(navigation-footer-managed: true)) }
    else { () },
  config-info(title: [Section Segments], author: [Presenter], logo: self => image("fixtures/image.svg")),
  config-common(slide-level: 2, new-section-slide-fn: none, handout: mode == "handout",
    show-only-notes: mode == "notes", article-mode: mode == "article",
    show-notes-on-second-screen: if mode == "second-screen" { side } else { none }))
#let probe(id) = layout(size => context [#metadata((id: id, width: size.width.pt(), height: size.height.pt()))<chapter-body>])
#slide(title: [Before The Sections])[#probe("before") An opening thought.]
= Discover
== Evidence
#probe("first")
First frame.
#speaker-note[A note.]
#pause
Second frame.
== A Result
#probe("second")
Evidence for the result.
= Build
#slide(title: [The Next Idea])[#probe("next") Main content.]
#slide(title: [An Uncluttered Slide], config: config-store(navigation: none))[
  #probe("disabled") Main content.
]
#show: appendix
= Supporting Material
== Backup
#probe("appendix")
The appendix has its own sections.
