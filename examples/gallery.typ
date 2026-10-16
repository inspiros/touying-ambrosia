#import "@preview/touying-ambrosia:0.1.0": *
#import "../template/project-brand.typ": project-theme

// README artwork, also editable in an IDE. Change these defaults and preview.
// Views: layout, cover, title-layout, ending-layout, palettes, blocks, annotations, citations, people,
// palette-component, navigation-buttons, navigation, roadmap, credits, slides. CLI inputs are optional overrides.
#let view = "layout"
#let flavor = "minimal" // seven layouts; one constant palette isolates geometry
#let palette = "ocean" // palette cards show all twelve built-in palettes
#let font = "DejaVu Sans"
#let view = sys.inputs.at("view", default: view)
#let flavor = sys.inputs.at("flavor", default: flavor)
#let palette = sys.inputs.at("palette", default: palette)
#let level = if flavor == "cambridge" { 3 } else { 2 }
#let component-views = ("blocks", "annotations", "citations", "people", "palette-component", "navigation-buttons", "roadmap", "credits")

#if view == "palettes" {
  // Compact native cards use the same resolved palette roles as the theme.
  // Comparing colors here avoids repeating every layout/palette combination.
  set page(width: 960pt, height: auto, margin: 18pt, fill: rgb("e9edf2"))
  set text(font: font, size: 12pt)
  grid(columns: (1fr,) * 3, gutter: 12pt,
    ..palettes.palette-names.map(name => {
      let p = palettes.resolve(name)
      block(width: 100%, height: 146pt, inset: 12pt, radius: 7pt, fill: p.background,
        stroke: 0.6pt + p.border,
        stack(dir: ttb, spacing: 5pt,
          grid(columns: (1fr, auto), align: horizon,
            text(size: 14pt, weight: "bold", fill: p.foreground, name),
            text(size: 8pt, fill: p.muted, if p.dark { "DARK" } else { "LIGHT" })),
          text(size: 17pt, weight: "semibold", fill: p.accent)[A Clear Result],
          text(size: 10pt, fill: p.foreground)[Readable body text on the page.],
          block(width: 100%, inset: 5pt, radius: 3pt, fill: p.surface-alt,
            text(size: 10pt, fill: p.foreground)[A quiet surface for evidence.]),
          grid(columns: (auto, auto, auto, 1fr), gutter: 5pt, align: horizon,
            ..(p.accent, p.surface, p.surface-alt).map(c => box(width: 15pt, height: 10pt,
              fill: c, radius: 2pt, stroke: 0.4pt + p.border)),
            text(size: 8pt, fill: p.muted, p.accent.to-hex())),
        ))
    }),
  )
} else {
  // Component cards omit page chrome to keep the actual utility easy to inspect.
  let card = view in component-views
  show: project-theme.with(
    flavor: if card { ambrosia-flavor(name: "component-card", header-renderer: none, footer-renderer: none) } else { flavor },
    palette: palette, font: font,
    navigation: if view == "navigation" { sys.inputs.at("navigation", default: "sidebar") } else { auto },
    navigation-side: sys.inputs.at("side", default: "right"),
    navigation-buttons: view == "navigation",
    section-progress: view == "navigation" and sys.inputs.at("navigation", default: "sidebar") != "segments",
    config-common(new-section-slide-fn: none),
    // The credit card needs a shallow canvas rather than a slide-sized frame.
    ..if view == "credits" {
      (config-page(width: 520pt, height: 134pt, margin: 0.5em),)
    } else if card {
      (config-page(width: 520pt, height: 280pt, margin: 1em),)
    } else { () },
    config-info(title: [Touying Ambrosia], subtitle: [Layouts, Palettes, And Components],
      author: [Presenter], email: if view == "ending-layout" { "presenter@example.org" } else { none },
      short-title: [Ambrosia], date: [15 October 2026]),
  )
  if view in ("cover", "title-layout") {
    title-slide(layout: if view == "title-layout" { sys.inputs.at("layout", default: "header") } else { auto })
  } else if view == "ending-layout" {
    ending-slide(layout: sys.inputs.at("layout", default: "centered"), title: [Questions?])[
      One Clear Result. One Useful Next Step.
      #parbreak()
      #link("https://github.com/inspiros/touying-ambrosia")[Project And Materials]
    ]
  } else if view in ("layout", "navigation") {
    heading(depth: 1)[Methods]
    if level == 3 { heading(depth: 2)[Evaluation] }
    heading(depth: level)[A Clear Result]
    grid(columns: (1fr, 1fr), gutter: 1em,
      [
        #ambrosia-block(style: "poster", kind: "info", title: [Observation])[
          A consistent visual language helps an audience follow the evidence.
        ]
        - One idea per slide.
        - The same content in every layout.
        #ambrosia-badge(kind: "success", shadowed: true)[Validated]
      ],
      [
        #figure(table(columns: (1fr, auto), inset: 0.4em,
          table.header[Method][Score], [Baseline], [0.74], [Proposed], [0.91]),
          caption: [Evidence In Context])
        #ambrosia-block(style: "stripe", kind: "warning", title: [Qualification])[
          Explain the assumption behind the result.
        ]
      ])
    if view == "navigation" {
      heading(depth: level)[Further Evidence]
      [A second logical slide gives the first section a partial progress segment.]
    }
    heading(depth: 1)[Results]
    if level == 3 { heading(depth: 2)[Discussion] }
    heading(depth: level)[A Further Result]
    [The next slide provides real targets for section tabs and miniature slides.]
  } else if view == "blocks" {
    slide[
      #grid(columns: (1fr, 1fr), gutter: 0.65em,
        ambrosia-block(style: "plain", title: [Plain])[A quiet panel.],
        ambrosia-block(style: "framed", title: [Framed])[An attached heading.],
        ambrosia-block(style: "poster", title: [Poster])[A separate title bar.],
        ambrosia-block(style: "outlined", title: [Outlined])[An open background.],
        ambrosia-block(style: "stripe", title: [Stripe])[A square left accent.],
        ambrosia-block(style: "tabbed", title: [Tabbed])[A centered title tab.])
    ]
  } else if view == "annotations" {
    slide[
      #text(weight: "semibold")[Small Signals, Clear Meaning]
      #v(0.6em)
      #ambrosia-badge(kind: "success", shadowed: true)[Validated]
      #h(0.5em)#ambrosia-badge(kind: "warning")[Preliminary]
      #h(0.5em)#ambrosia-badge(kind: "info")[Evidence]
      #v(0.5em)
      #ambrosia-block(style: "stripe", kind: "info", title: [Emphasis])[
        Use #alert[one important phrase] to guide attention.
      ]
      #ambrosia-source-note[Source: the experimental dataset.]
    ]
  } else if view == "citations" {
    slide[
      #text(weight: "semibold")[One Reference, One Identity]
      #v(0.6em)
      Native @knuth84 and a full footnote #footcite(<knuth84>).
      #v(0.5em)
      Markers stay consistent across slides and the bibliography.
    ]
    bibliography-slide("bibliography.bib")
  } else if view == "people" {
    title-slide(title: [Linked Authors], subtitle: none, logo: none, logos: none,
      affiliation-numbering: "*", date: none,
      authors: (
        (name: [Alex Researcher], affiliations: ("a", "b"), email: "alex@example.org"),
        (name: [Sam Collaborator], affiliations: ("b",), email: "sam@example.org")),
      institutions: (a: [First Institution], b: [Second Institution]))
  } else if view == "palette-component" {
    slide[
      #ambrosia-palette-showcase(title: [The Colors Actually In Use], columns: 3,
        roles: ("background", "surface", "primary", "info", "success", "warning"))
    ]
  } else if view == "credits" {
    slide[
      #ambrosia-credit-card(width: 100%)
    ]
  } else if view == "navigation-buttons" {
    outline-slide()
    heading(depth: 1)[Navigation]
    slide[
      #align(center + horizon)[
        #text(weight: "semibold")[Find Your Way]
        #v(1em)
        #text(size: 2em)[#ambrosia.navigation-buttons(opacity: 65%,
          actions: ("first", "previous", "section", "outline", "next", "last"))]
        #v(0.7em)
        #text(size: 0.65em)[First · Previous · Section · Outline · Next · Last]
      ]
    ]
    slide[Another logical slide supplies the forward targets.]
  } else if view == "roadmap" {
    slide[
      #text(weight: "semibold")[From Question To Delivery]
      #v(0.5em)
      #ambrosia-roadmap(total: 12, unit: "week", tick-every: 3, now: 3.5,
        milestones: ((at: 9, label: [Review]),),
        phases: ((name: [Explore], end: 4, kind: "info"),
          (name: [Build], end: 8, kind: "success"),
          (name: [Evaluate], end: 12, kind: "warning")),
        tasks: (
          (content: [Discovery], start: 0, end: 4, kind: "info"),
          (content: [Implementation], start: 2.5, end: 9, kind: "success"),
          (content: [Evaluation], start: 8, end: 12, kind: "warning"),
        ))
    ]
  } else if view == "slides" {
    title-slide()
    outline-slide()
    heading(depth: 1)[Research]
    section-slide(title: [Section Slide], subtitle: [A Deliberate Transition])
    focus-slide[One Idea Worth Remembering]
    image-slide("../assets/kyklo.webp", caption: [Image Slide], credit: [Fictional Laboratory · Generated Illustration])
    ending-slide(title: [Questions?])[]
  } else {
    panic("Unknown gallery view: " + view)
  }
}
