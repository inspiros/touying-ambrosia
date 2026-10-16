#import "@preview/touying-ambrosia:0.1.0": *
#import "../template/project-brand.typ": project-theme

// Edit these defaults in your IDE; no QR generator is needed to compile.
#let palette = "ocean" // try midnight or nebula
#let show-qr = true // false makes the card quieter and releases its QR column
#show: project-theme.with(flavor: "minimal", palette: sys.inputs.at("palette", default: palette),
  config-info(title: [Sharing Credit], author: [Presenter]))

#slide(title: [People And Tools])[
  // Acknowledgements need no special API: the normal block handles rich text,
  // partner logos, links, and any grouping that suits the presentation.
  #grid(columns: (1fr, 1fr), gutter: 1em, align: top,
    ambrosia-block(style: "outlined", title: [Acknowledgements])[
      Thanks to our collaborators, reviewers, and supporting institutions.

      - Research and discussion.
      - Data and infrastructure.
      - Feedback and testing.
    ],
    ambrosia-credit-card(qr: show-qr),
  )
]

#ending-slide(layout: "plain", title: [Thank You])[
  // The card is always opt-in. It works in endings or ordinary slide content.
  // Its links and bundled QR lead to the repository's source and examples.
  #ambrosia.credit-card(width: 65%, qr: show-qr)
]
