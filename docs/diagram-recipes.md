# Experimental Diagram Recipes

Diagrams can reuse Ambrosia's semantic colors and inherited text size without
becoming theme APIs. The [Sankey example](../examples/sankey.typ) demonstrates a
small, independent native-Typst helper in
[examples/helpers/sankey.typ](../examples/helpers/sankey.typ). It imports neither
Touying nor CetZ and can also render in an ordinary document.

This is an experimental recipe, not an exported `ambrosia-sankey` component.
To try it online, copy the helper into your own project, or download its
[source file](https://raw.githubusercontent.com/inspiros/touying-ambrosia/main/examples/helpers/sankey.typ).
There is no need to clone the repository. Examples are excluded from the
installable package.

## The Data Model

Each edge is `(source-id, target-id, positive-value)` with an optional fourth
dictionary containing `label`, `fill`, or `stroke`. Nodes are ordered by first
appearance in the edges. A node override accepts `fill`, `label`, and native
`label-pos`; `label: none` hides the label. `show-values: false` hides counts.

The helper accepts a `palette` record from `palettes.resolve(...)`. Its accent,
foreground and semantic colors can be shared with the surrounding presentation.
`color-mode: "target"` (default) or `"source"` selects inherited ribbon colors;
explicit edge fills take precedence. Transparent ribbons work on both light and
dark pages. The helper inherits the document's font and uses `em` spacing.

## Geometry And Limits

- A topological traversal assigns columns and rejects cycles and self-loops.
- One shared scale converts every value to a ribbon/bar thickness. The height
  budget includes all inter-node gaps and labels; the horizontal budget includes
  the final node bar's width.
- Node capacity is the greater of incoming and outgoing totals. An imbalance
  leaves unused capacity; it does not invent a balancing flow.
- Source and target offsets are independent, so each port stacks its ribbons
  without changing their values. Labels paint after ribbons and bars.
- Empty graphs, non-positive/non-finite weights, unknown node overrides, and
  insufficient drawing regions produce diagnostics.

The current recipe supports acyclic flows between **adjacent columns**. An edge
that skips a column needs explicit intermediate nodes. It does not route cycles,
minimize crossings, optimize label collisions, or choose an aesthetic node order
for you. Preserve explicit edge order and review the drawing.

The existing draft has useful scope for a later standalone diagram component.
Keep that decision separate from the presentation API and from the eventual
`ambrosia-kit` extraction.
