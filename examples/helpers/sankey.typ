// Experimental recipe, independent of Touying. Not part of Ambrosia's public API.
// Layered DAGs only: positive finite weights, no cycles or skipped columns.
#let flow-model(edges) = {
  assert(type(edges) == array and edges.len() > 0, message: "Sankey needs at least one edge.")
  let ids = ()
  let incoming = (:)
  let outgoing = (:)
  let degree = (:)
  for e in edges {
    assert(type(e) == array and e.len() in (3, 4), message: "Sankey edges are (source, target, value[, options]).")
    let (src, dst, value) = e.slice(0, 3)
    assert(type(src) == str and type(dst) == str, message: "Sankey node IDs must be strings.")
    assert(src != dst, message: "Sankey does not support self-loops.")
    assert(type(value) in (int, float) and value > 0 and value < calc.inf,
      message: "Sankey weights must be positive and finite.")
    assert(e.len() == 3 or type(e.at(3)) == dictionary, message: "Sankey edge options must be a dictionary.")
    for n in (src, dst) { if n not in ids { ids.push(n) } }
    outgoing.insert(src, outgoing.at(src, default: 0) + value)
    incoming.insert(dst, incoming.at(dst, default: 0) + value)
    degree.insert(dst, degree.at(dst, default: 0) + 1)
  }
  let ready = ids.filter(n => degree.at(n, default: 0) == 0)
  let layers = ids.map(n => (n, 0)).to-dict()
  let visited = 0
  while ready.len() > 0 {
    let n = ready.remove(0)
    visited += 1
    for e in edges.filter(e => e.first() == n) {
      let dst = e.at(1)
      layers.at(dst) = calc.max(layers.at(dst), layers.at(n) + 1)
      degree.at(dst) -= 1
      if degree.at(dst) == 0 { ready.push(dst) }
    }
  }
  assert(visited == ids.len(), message: "Sankey requires an acyclic graph.")
  for e in edges {
    assert(layers.at(e.at(1)) == layers.at(e.first()) + 1,
      message: "This Sankey recipe supports adjacent columns only. Split a skipped-column edge through an explicit intermediate node.")
  }
  let capacity = ids.map(n => (n, calc.max(incoming.at(n, default: 0), outgoing.at(n, default: 0)))).to-dict()
  assert(capacity.values().all(v => v < calc.inf), message: "Sankey capacity totals must be finite.")
  let columns = range(calc.max(..layers.values()) + 1).map(i => ids.filter(n => layers.at(n) == i))
  (ids: ids, columns: columns, layers: layers, capacity: capacity, incoming: incoming, outgoing: outgoing)
}

#let sankey-flow(edges, width: 100%, height: 13em, node-width: 0.35em, node-padding: 0.8em,
  label-width: 5.5em, color-mode: "target", nodes: (:), show-values: true,
  palette: (accent: rgb("246fa0"), foreground: rgb("202b36"), border: rgb("9daab8")),
) = {
  let model = flow-model(edges)
  assert(color-mode in ("source", "target"), message: "Sankey color-mode must be source or target.")
  for n in nodes.keys() { assert(n in model.ids, message: "Unknown Sankey node override: " + n) }
  block(width: width, height: height, above: 0em, below: 0em, layout(bounds => context {
    let bar = node-width.to-absolute()
    let padding = node-padding.to-absolute()
    let label-width = label-width.to-absolute()
    let gap = (0.35em).to-absolute()
    let get(n, key, fallback) = nodes.at(n, default: (:)).at(key, default: fallback)
    let node-color(n) = get(n, "fill", palette.accent)
    let labels = (:)
    let positions = (:)
    let max-label-height = 0pt
    for n in model.ids {
      let label = get(n, "label", n)
      let source = model.incoming.at(n, default: 0) == 0
      let sink = model.outgoing.at(n, default: 0) == 0
      let pos = get(n, "label-pos", auto)
      let pos = if pos == auto { if source { left } else if sink { right } else { top } } else { pos }
      assert(type(pos) == alignment, message: "Sankey label-pos must be a native alignment.")
      let pos = ((if pos.x == none { center } else { pos.x }) + (if pos.y == none { horizon } else { pos.y }))
      positions.insert(n, pos)
      if label != none {
        let label = block(width: label-width, above: 0em, below: 0em, {
          set text(size: 0.75em, fill: palette.foreground)
          set par(justify: false, leading: 0.35em)
          set align(if pos.x == left { right } else if pos.x == right { left } else { center })
          label
          if show-values { linebreak(); text(size: 0.85em, str(model.capacity.at(n))) }
        })
        let h = measure(label).height
        max-label-height = calc.max(max-label-height, h)
        labels.insert(n, (body: label, height: h))
      }
    }
    let side = label-width + gap
    let vertical = max-label-height + gap
    let plot-width = bounds.width - 2 * side
    let plot-height = bounds.height - 2 * vertical
    assert(bar > 0pt and padding >= 0pt and plot-width > bar and plot-height > 0pt,
      message: "Sankey region is too small for its bars and labels. Increase size or shorten labels.")
    // All columns share one value scale; padding is part of the height budget.
    let scales = model.columns.map(col => {
      let available = plot-height - padding * (col.len() - 1)
      assert(available > 0pt, message: "Sankey node padding consumes the column. Increase height or reduce node-padding.")
      available / col.map(n => model.capacity.at(n)).sum()
    })
    let unit = calc.min(..scales)
    let step = (plot-width - bar) / (model.columns.len() - 1)
    let geometry = (:)
    for (i, col) in model.columns.enumerate() {
      let occupied = col.map(n => model.capacity.at(n) * unit).sum() + padding * (col.len() - 1)
      let y = vertical + (plot-height - occupied) / 2
      for n in col {
        let h = model.capacity.at(n) * unit
        geometry.insert(n, (x: side + i * step, top: y, bottom: y + h))
        y += h + padding
      }
    }
    let outgoing = geometry.pairs().map(((n, g)) => (n, g.top)).to-dict()
    let incoming = outgoing
    block(width: bounds.width, height: bounds.height, above: 0em, below: 0em, {
      [#metadata((width: bounds.width.pt(), height: bounds.height.pt()))<sankey-region>]
      for e in edges {
        let (src, dst, value) = e.slice(0, 3)
        let opts = e.at(3, default: (:))
        let a = geometry.at(src)
        let b = geometry.at(dst)
        let h = value * unit
        let y1 = outgoing.at(src)
        let y2 = incoming.at(dst)
        outgoing.at(src) += h
        incoming.at(dst) += h
        let x1 = a.x + bar
        let x2 = b.x
        let dx = x2 - x1
        let y0 = calc.min(y1, y2)
        let color = node-color(if color-mode == "source" { src } else { dst })
        place(top + left, dx: x1, dy: y0, {
          [#metadata((value: value, height: h.pt(), source: src, target: dst))<sankey-ribbon>]
          curve(fill: opts.at("fill", default: color.transparentize(60%)), stroke: opts.at("stroke", default: none),
            curve.move((0pt, y1 - y0)),
            curve.cubic((dx / 2, y1 - y0), (dx / 2, y2 - y0), (dx, y2 - y0)),
            curve.line((dx, y2 + h - y0)),
            curve.cubic((dx / 2, y2 + h - y0), (dx / 2, y1 + h - y0), (0pt, y1 + h - y0)),
            curve.line((0pt, y1 - y0)),
            curve.close())
        })
        if opts.at("label", default: none) != none {
          let label = text(size: 0.65em, fill: palette.foreground, opts.label)
          let size = measure(label)
          place(top + left, dx: (x1 + x2 - size.width) / 2, dy: (y1 + y2 + h - size.height) / 2, label)
        }
      }
      for n in model.ids {
        let g = geometry.at(n)
        place(top + left, dx: g.x, dy: g.top, {
          [#metadata((id: n, width: bar.pt(), height: (g.bottom - g.top).pt(), capacity: model.capacity.at(n)))<sankey-node>]
          rect(width: bar, height: g.bottom - g.top, fill: node-color(n), stroke: none, radius: 0.06em)
        })
      }
      // Labels paint last, so a later ribbon cannot erase an earlier label.
      for (n, label) in labels {
        let g = geometry.at(n)
        let pos = positions.at(n)
        let x = if pos.x == left { g.x - gap - label-width }
          else if pos.x == right { g.x + bar + gap } else { g.x + bar / 2 - label-width / 2 }
        let y = if pos.y == top { g.top - gap - label.height }
          else if pos.y == bottom { g.bottom + gap } else { (g.top + g.bottom - label.height) / 2 }
        assert(-0.01pt <= x and x + label-width <= bounds.width + 0.01pt and -0.01pt <= y and y + label.height <= bounds.height + 0.01pt,
          message: "Sankey label does not fit. Adjust label-pos, label-width, or diagram height.")
        place(top + left, dx: x, dy: y, label.body)
      }
    })
  }))
}
