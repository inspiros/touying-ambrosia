#import "@preview/touying-ambrosia:0.1.0": *
#import "../template/project-brand.typ": project-theme
#import "helpers/sankey.typ": sankey-flow

// This experimental native-Typst recipe is deliberately outside the package API.
// Its helper can also be used in an ordinary document; it needs no Touying self.
#let palette = "ocean" // try midnight; ribbons use transparency, not white washes
#let palette = sys.inputs.at("palette", default: palette)
#let p = palettes.resolve(palette)
#show: project-theme.with(palette: palette, font: "DejaVu Sans",
  config-common(new-section-slide-fn: none),
  config-info(title: [Following The Flow], author: [Presenter]),
)

== Where Requests Go
The same width represents the same quantity across the entire diagram.
#v(0.5em)
#sankey-flow(
  (
    ("New Requests", "Ready", 68),
    ("New Requests", "Needs Review", 22),
    ("New Requests", "Closed", 10),
    ("Carried Forward", "Ready", 8),
    ("Carried Forward", "Needs Review", 12),
  ),
  palette: p, height: 14em, // total region INCLUDES labels and node padding
  color-mode: "target", // alternatively inherit each ribbon's source color
  nodes: (
    "New Requests": (fill: p.accent),
    "Carried Forward": (fill: p.muted),
    "Ready": (fill: p.success),
    "Needs Review": (fill: p.warning),
    "Closed": (fill: p.muted),
  ),
)
