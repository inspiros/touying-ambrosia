#import "../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "slides")
#let choice = sys.inputs.at("navigation", default: "sidebar")
#let flavor = sys.inputs.at("flavor", default: "minimal")
#let choice = if choice == "auto" { auto } else if choice == "none" { none } else if choice == "custom-header" {
  ambrosia-navigation(base: "context", name: "custom-band", height: 1em, renderer: self => text(size: 0.5em)[Custom Header Navigation])
} else if choice == "custom" {
  ambrosia-navigation(name: "team-rail", width: 8em, renderer: self => [Custom Navigation])
} else { choice }
#let notes-side = (left: left, right: right, top: top, bottom: bottom).at(sys.inputs.at("notes-side", default: "right"))
#show: ambrosia-theme.with(
  flavor: flavor, navigation: choice,
  navigation-side: sys.inputs.at("side", default: "right"),
  navigation-depth: 3, navigation-buttons: true, section-progress: true,
  palette: sys.inputs.at("palette", default: "ocean"),
  config-info(title: [Navigation Layout], author: [Presenter], logo: self => image("fixtures/image.svg")),
  config-page(foreground: place(top + left, text(size: 0.3em)[ORIGINAL FOREGROUND])),
  config-common(slide-level: 2, new-section-slide-fn: none, handout: mode == "handout", show-only-notes: mode == "notes",
    article-mode: mode == "article",
    show-notes-on-second-screen: if mode == "second-screen" { notes-side } else { none }),
)
#let probe(id) = layout(size => context [#metadata((id: id, width: size.width.pt(), height: size.height.pt()))<navigation-body>])
#title-slide()
#outline-slide()
= Discover
== A Question
=== Initial Context
#probe("animated")
First frame.
#speaker-note[Notes for the question.]
#pause
=== Revealed Context
Second frame.
== A Second Step
#probe("next")
Another logical slide.
#slide(title: [No Structural Navigation], config: config-store(navigation: none))[
  #probe("disabled") Locally disabled.
]
#focus-slide[Focus]
#image-slide("fixtures/image.svg")
#ending-slide(title: [Questions?])[]
#show: appendix
= Backup
== Supporting Evidence
#probe("appendix")
The sidebar and progress use only appendix context.
