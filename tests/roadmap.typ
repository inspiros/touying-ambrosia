#import "../src/lib.typ": *
#let case = sys.inputs.at("case", default: "normal")
#show: ambrosia-theme.with(
  flavor: "minimal", palette: sys.inputs.at("palette", default: "ocean"),
  config-common(new-section-slide-fn: none),
)

#slide[
  #if case == "normal" {
    ambrosia-roadmap(total: 14, now: 0,
      milestones: (4, (at: 14, label: [Delivery])),
      phases: ((name: [Explore], end: 4), (name: [Build], start: 6, end: 14)),
      tasks: (
        ((content: [First Task], start: 1, end: 3, details: [First Drawer]),
         (content: [Second Task], start: 6, end: 10, details: (start: 4, end: 14, content: [Second Drawer]))),
        (content: [Final Task], start: 10, end: 14),
      ))
  } else if case == "fractional" {
    ambrosia-roadmap(total: 5.5, unit: "day", tick-every: 0.5, now: 1.75,
      milestones: (0.25, (at: 5.5, label: [Complete])),
      phases: ((name: [Prepare], end: 1.25), (name: [Deliver], end: 5.5)),
      tasks: (
        ((content: [First], start: 0, end: 1.25), (content: [Adjacent], start: 1.25, end: 2.75)),
        (content: [Fractional Details], start: 2.5, end: 5.5,
          details: (start: 0.75, end: 5.25, content: [A Fractional Drawer])),
      ))
  } else if case == "custom-unit" {
    ambrosia-roadmap(total: 3, unit: "sprint", tick-every: 1, now: 0.5,
      tasks: ((content: [A Custom Unit], start: 0, end: 3),))
  } else if case == "decimal-ticks" {
    ambrosia-roadmap(total: 1, unit: "hour", tick-every: 0.1, now: 0.1 * 3,
      tasks: (((content: [First], start: 0, end: 0.1 * 3),
        (content: [Adjacent], start: 0.3, end: 1)),))
  } else if case == "plain" {
    ambrosia.roadmap(total: 7, tick-every: 2,
      tick-label: (start, end) => [#start#sym.dash.en#end],
      tasks: ((content: [No Phases Or Current Marker], start: 1, end: 7),))
  } else if case == "empty" {
    ambrosia-roadmap(total: 1, now: 1, milestones: (0, 1))
  } else if case in ("fit", "unfitted") {
    block(height: 9em, ambrosia-roadmap(total: 12, fit: case == "fit", min-scale: 70%,
      tasks: range(7).map(i => (content: [Task #(i + 1)], start: 1, end: 12))))
  } else if case == "overlap" {
    ambrosia-roadmap(tasks: (((content: [First], start: 0, end: 6), (content: [Second], start: 5.5, end: 8)),))
  } else if case == "zero-duration" {
    ambrosia-roadmap(tasks: ((content: [Empty], start: 1.5, end: 1.5),))
  } else if case == "bad-total" {
    ambrosia-roadmap(total: calc.inf)
  } else if case == "bad-ticks" {
    ambrosia-roadmap(total: 12, tick-every: 0)
  } else if case == "excessive-ticks" {
    ambrosia-roadmap(total: 12, tick-every: 0.0001)
  } else if case == "bad-details" {
    ambrosia-roadmap(total: 12, tasks: ((content: [Task], start: 1, end: 6,
      details: (start: 1, end: 15, content: [Out Of Range])),))
  } else if case == "bad-phase" {
    ambrosia-roadmap(phases: ((name: [First], end: 8), (name: [Second], start: 7, end: 12)))
  } else if case == "bad-now" {
    ambrosia-roadmap(total: 12, now: 13)
  } else if case == "animated" {
    [Before #pause #ambrosia-roadmap(total: 6,
      tasks: ((content: [Revealed Plan], start: 1, end: 6),))]
  } else if case == "too-dense" {
    block(height: 5em, ambrosia-roadmap(total: 12,
      tasks: ((content: rect(width: 1em, height: 400pt), start: 1, end: 12),)))
  }
]
