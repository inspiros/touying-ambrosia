#import "../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "slides")
#let flavor = sys.inputs.at("flavor", default: "minimal")
#let level = if flavor == "cambridge" { 3 } else { 2 }
#show: ambrosia-theme.with(
  flavor: flavor,
  palette: sys.inputs.at("palette", default: "light"),
  navigation-buttons: sys.inputs.at("buttons", default: "true") == "true",
  navigation-buttons-actions: ("first", "previous", "section", "outline", "next", "last"),
  config-info(logo: self => [#image("fixtures/image.svg")<navigation-logo>]),
  config-page(foreground: place(top + left, text(size: 0.35em)[FOREGROUND])),
  config-common(new-section-slide-fn: none, handout: mode == "handout", show-only-notes: mode == "notes",
    show-notes-on-second-screen: if mode == "second-screen" { right } else { none }),
)
#title-slide(title: [Navigation])
#outline-slide()
= Research
#heading(depth: level)[Animated]
Frame one.
#speaker-note[Presenter note.]
#pause
Frame two.
#heading(depth: level)[A Result]
Another logical slide.
#slide(title: [No Overlay], config: config-store(navigation-buttons: false))[Locally disabled.]
#focus-slide[Immersive.]
#image-slide("fixtures/image.svg")
#section-slide(title: [Transition])
#show: appendix
= Backup
#heading(depth: level)[Extra Evidence]
Appendix slide.
#outline-slide()
