#import "../examples/helpers/sankey.typ": sankey-flow, flow-model
#import "../src/palettes.typ"
#let palette = palettes.resolve(sys.inputs.at("palette", default: "ocean"))
#let size = int(sys.inputs.at("size", default: "18")) * 1pt
#set page(width: 38em, height: 19em, margin: 1em, fill: palette.background)
#set text(font: "DejaVu Sans", size: size, fill: palette.foreground)
#let kind = sys.inputs.at("invalid", default: "")
#let edges = (("A", "C", 6), ("B", "C", 4), ("C", "D", 7), ("C", "E", 3))
#let edges = (if kind == "empty" { () }
  else if kind == "cycle" { (("A", "B", 1), ("B", "A", 1)) }
  else if kind == "self" { (("A", "A", 1),) }
  else if kind == "weight" { (("A", "B", -1),) }
  else if kind == "skip" { (("A", "B", 4), ("B", "C", 4), ("A", "C", 2)) }
  else { edges })
#sankey-flow(edges, palette: palette, height: if kind == "small" { 1em } else { 16em },
  nodes: if kind == "unknown" { (Typo: (:)) } else { (:) },
)
