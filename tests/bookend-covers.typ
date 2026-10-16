#import "../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "slides")
#let side = (left: left, right: right, top: top, bottom: bottom).at(sys.inputs.at("side", default: "right"))
#show: ambrosia-theme.with(palette: sys.inputs.at("palette", default: "light"),
  config-common(show-only-notes: mode == "notes", handout: mode == "handout",
    show-notes-on-second-screen: if mode == "second-screen" { side } else { none }),
  config-info(title: [PHOTO OPENING], author: [Presenter], email: "presenter@example.org"))
#let photo = image("../assets/kyklo.webp", width: 100%, height: 100%, fit: "cover")
#title-slide(layout: ambrosia-title-layout(base: "cover", background-image: photo),
  config: config-page(margin: (x: 5%, y: 5%)))
#ending-slide(layout: ambrosia-ending-layout(base: "cover", background-image: photo), title: [PHOTO ENDING])[
  LAST TAKEAWAY
  #link("https://example.org")[#context [#metadata(text.fill)<cover-link-ink>]LINK]
  #footnote[#context [#metadata((fill: text.fill, size: text.size.pt()))<cover-note-ink>]COVER NOTE]
  #speaker-note[PHOTO PRESENTER NOTE]
]
