#import "../src/lib.typ": *
// Edit these defaults in an IDE; command-line inputs optionally override them.
#let preset = "ocean" // a curated palette name
#let primary = auto // e.g. rgb("2b6b51"); auto retains the preset's accent seed
#let rotate = 90deg // e.g. 65deg rotates the base hues in OKLCH
#let preset = sys.inputs.at("palette", default: preset)
#let palette = {
  ambrosia-palette(base: preset, name: preset + " variation",
    primary: if "primary" in sys.inputs { rgb(sys.inputs.primary) } else { primary },
    rotate: if "rotate" in sys.inputs { float(sys.inputs.rotate) * 1deg } else { rotate })
}
#show: ambrosia-theme.with(
  flavor: "minimal", palette: palette, font: "DejaVu Sans",
  config-info(title: [Palette: #if type(palette) == str { palette } else { palette.name }], subtitle: [Independent Colors. Consistent Geometry.], author: [Kyklo]),
)
#title-slide()

== A Palette In Use
#grid(columns: (1fr, 1fr), gutter: 0.8em,
  ambrosia-block(style: "poster", title: [One Clear Idea])[
    Primary accents, quiet surfaces, and readable text.
    #ambrosia-badge[Research]
  ],
  ambrosia-block(style: "outlined", title: [Evidence])[
    A good palette keeps the result in focus.
    #footcite(<knuth84>)
  ],
)
#v(0.7em)
#grid(columns: (1fr, 1fr, 1fr), gutter: 0.7em,
  ambrosia-block(style: "stripe", kind: "info", title: [Info])[Context.],
  ambrosia-block(style: "stripe", kind: "success", title: [Success])[Validated.],
  ambrosia-block(style: "stripe", kind: "warning", title: [Warning])[Limitations.],
)
#ambrosia-source-note[Colors remain independent of the layout and team logo.]
#hidden-bibliography("bibliography.bib")

== The Palette's Roles
#ambrosia-palette-showcase()
