#import "@preview/touying-ambrosia:0.1.0": *
#import "showcase.typ": kyklo-theme, kyklo-flavor
// Edit the defaults here in your IDE. CLI inputs are optional overrides.
#let flavor = "kyklo" // or a built-in name; Cambridge uses === for slide headings
#let palette = "light" // try midnight, forest, or an ambrosia-palette(...) descriptor
#let buttons = true // optional PDF footer controls; theme default is false
#show: kyklo-theme.with(
  navigation-buttons: buttons,
  title-layout: "featured", // first logo stands out; the four partners form a smaller row
  affiliation-numbering: "*",
  flavor: sys.inputs.at("flavor", default: flavor),
  palette: sys.inputs.at("palette", default: palette),
  config-info(title: [Touying Ambrosia], subtitle: [Flexible Research Presentations],
    authors: (
      (name: [Alex Researcher], affiliations: ("kyklo", "olympus"), email: "alex@example.org"),
      (name: [Sam Collaborator], affiliations: ("kyklo", "helios"), email: "sam@example.org"),
    ),
    institutions: (kyklo: [Kyklo Laboratory], olympus: [Olympus Institute], helios: [Helios Polytechnic]),
    short-author: [Researcher & Collaborator], short-title: [Touying Ambrosia],
    date: [15 October 2026],
  ),
)
#title-slide()
#outline-slide()
= The Idea
== Independent Choices
Choose geometry with a flavor, colors with a palette, and your own logos.
#grid(columns: (1fr, 1fr), gutter: 1em,
  ambrosia-block(style: "poster", kind: "info", title: [A Visual Language])[Independent layouts and twelve palettes.],
  ambrosia-block(style: "outlined", kind: "success", title: [Your Institution])[Wrap the core with your own flavor and branding.],
)
== An Evolving Result
#ambrosia-block(style: "poster", shadowed: true, watermark: "body", title: [Observation])[
  A useful source #footcite(<knuth84>).
  #pause
  #ambrosia-block(style: "outlined", kind: "warning", title: [Qualification])[Explain the limitation.]
]

= More Ways To Communicate
== The Palette In Use
#ambrosia-palette-showcase()

== Shared Components
#ambrosia-badge(kind: "success", shadowed: true)[Validated]
#ambrosia-source-note[An example credit line.]
#grid(columns: (1fr, 1fr), gutter: 1em,
  ..("plain", "framed", "outlined", "stripe").map(style => ambrosia-block(style: style, title: upper(style.slice(0, 1)) + style.slice(1))[Same content model.]),
)
#section-slide(title: [A Deliberate Transition], subtitle: [Change Pace])
#focus-slide[One idea worth remembering.]
#image-slide("../assets/kyklo.webp", caption: [Kyklo Laboratory],
  credit: [Fictional laboratory · generated illustration], alt: "An imagined Kyklo laboratory")
#bibliography-slide("bibliography.bib")
#ending-slide(layout: "split", title: [Questions?])[
  - Choose a layout, a palette, and your own branding.
  - Keep the same authoring tools as your presentation changes.
]
#show: appendix
== Supporting Evidence
Appendix content keeps its own heading and slide-count behavior.
