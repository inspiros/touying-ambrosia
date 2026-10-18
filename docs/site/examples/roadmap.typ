#import "@preview/touying-ambrosia:0.1.0": *
#show: ambrosia-theme.with(palette: "ocean")
#slide(title: [A Six-Week Project])[
// Time starts at zero; fractional boundaries keep their proportional widths.
// ANCHOR: example
#ambrosia-roadmap(
  total: 6, unit: "week", tick-every: 1,
  now: 2.5, milestones: (4.5,),
  tasks: (
    (content: [Explore], start: 0, end: 2.5),
    (content: [Build], start: 2, end: 5,
      kind: "success"),
    (content: [Review], start: 4.5, end: 6,
      kind: "warning"),
  ),
)
// ANCHOR_END: example
]
