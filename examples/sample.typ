#import "@preview/touying-ambrosia:0.1.0": *
#import "../template/project-brand.typ": project-theme

// Edit these defaults in your IDE; the preview updates on save.
// Geometry: simple, cambridge, darmstadt, dewdrop, stargazer, minimal.
#let flavor = "minimal"
// Colors: light, ocean, forest, sand, rose, slate; nocturne, nebula,
// midnight, evergreen, ember, graphite. CLI inputs optionally override defaults.
#let palette = "light"
#show: project-theme.with(
  flavor: sys.inputs.at("flavor", default: flavor),
  palette: sys.inputs.at("palette", default: palette),
  config-common(new-section-slide-fn: none), // keep the gallery at three pages
  config-info(title: [Touying Ambrosia], subtitle: [Your Geometry, Colors, And Branding],
    author: [Alex Researcher], short-title: [Ambrosia], date: [15 October 2026]),
)
#title-slide()
#let level = if sys.inputs.at("flavor", default: flavor) == "cambridge" { 3 } else { 2 }
= Research
#if level == 3 { heading(depth: 2)[Motivation] }
#heading(depth: level)[One Useful Idea]

  // style selects geometry; kind selects a semantic accent from the palette.
  #ambrosia-block(style: "poster", kind: "info", title: [Observation])[
    Explain the result in a few clear sentences.
  ]
  #ambrosia-badge(kind: "success", shadowed: true)[Validated]
= Evidence
#if level == 3 { heading(depth: 2)[Evaluation] }
#heading(depth: level)[Evidence And Perspective]

  A useful source #footcite(<knuth84>).
  #ambrosia-block(style: "stripe", kind: "warning", title: [Qualification])[
    Share the assumption behind the claim.
  ]
  // Register sources without displaying a bibliography slide.
  #hidden-bibliography("bibliography.bib")
