#import "../src/lib.typ": *
// Change these defaults and component arguments in your IDE preview.
#let flavor = "minimal"
#let palette = "ocean" // try midnight for the same components on dark surfaces
#show: ambrosia-theme.with(
  flavor: flavor, palette: sys.inputs.at("palette", default: palette),
  font: "DejaVu Sans", footcite-once: false,
  config-common(new-section-slide-fn: section-slide),
  config-info(title: [Tools For A Research Talk], subtitle: [Containers, Citations, And Slide Patterns],
    author: [Kyklo], institution: [One template. Your presentation.]),
)

#title-slide()

= Containers

== One Object, Six Styles
#grid(columns: (1fr, 1fr), gutter: 0.7em,
  ambrosia-block(style: "plain", title: [Plain])[A quiet panel for everyday content.],
  ambrosia-block(style: "framed", title: [Framed])[An attached accent heading.],
  ambrosia-block(style: "poster", title: [Poster])[A separate title bar and content panel.],
  ambrosia-block(style: "outlined", title: [Outlined])[A border and a ruled heading.],
  ambrosia-block(style: "stripe", kind: "success", title: [Stripe])[A semantic accent without a heavy title bar.],
  // The centered tab overlaps the top border; body clearance is automatic.
  ambrosia-block(style: "tabbed", kind: "info", title: [Tabbed])[A centered title crossing the frame.],
)

== Meaning And Sources
#grid(columns: (1fr, 1fr), gutter: 0.7em,
  ambrosia-block(style: "poster", kind: "info", title: [Observation])[
    Good containers make a single idea easy to find.
    #ambrosia-badge(kind: "info", shadowed: true)[Evidence]
  ],
  ambrosia-block(style: "poster", kind: "warning", title: [Limitation])[
    Give uncertainty the same care as a result.
    #ambrosia-badge(kind: "warning")[Check assumptions]
  ],
)
#ambrosia-source-note[Local source lines can credit a figure or link to #link("https://typst.app/docs/")[documentation].]

= Sources

== A Paper Has An Identity
// Native #cite and @key share the compact CSL labels; no custom cite is needed.
Ordinary #cite(<knuth84>), shorthand @knuth84, and a footnote #footcite(<knuth84>).
Two different works: #footcite(<knuth84>) and #footcite(<knuth1984programming>).

#pause
Repeat #footcite(<knuth84>): its identifier stays the same.
An ordinary note still starts at 1#footnote[An ordinary explanatory note.].

== Choose The Notation
Author--year: #footcite(<knuth84>).

Presentation-wide number: #footcite(<knuth84>, marker: "number").

Bibliography key: #footcite(<knuth84>, marker: "key").

Legacy inline author--year and local superscript: #footcite(<knuth84>, marker: "local").

#bibliography-slide("bibliography.bib")

= More Than A Bullet List

#slide(composer: (1fr, 1fr), title: [Compare Two Approaches])[
  #ambrosia-block(style: "outlined", title: [Before])[
    One fixed appearance.
    Numbers that need slide context.
  ]
][
  #ambrosia-block(style: "poster", kind: "success", title: [After])[
    Independent geometry and palettes.
    Stable source identifiers.
  ]
]

#image-slide("../assets/kyklo.webp", caption: [A scene can carry the slide],
  credit: [Source: the bundled Kyklo cover asset.], alt: "Kyklo laboratory cover")

#slide(title: [Three Takeaways])[
  + Choose a palette that fits your topic and audience.
  + Keep source identities consistent across slides.
  + Use the same block object with a clear visual purpose.
]

#ending-slide(title: [Questions?])[Let's discuss.]
