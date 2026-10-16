// Shared source for the manual and its independently compiled slide snapshots.
#let start = ```typst
#import "@preview/touying-ambrosia:0.1.0": *
#show: ambrosia-theme.with(
  flavor: "minimal", palette: "ocean",
  config-info(title: [From Idea To Evidence],
    author: [Alex Researcher]),
)
#title-slide()
```

#let block-example = ```typst
#ambrosia-block(style: "tabbed",
  kind: "success", title: [A Useful Result],
  shadowed: false,
)[
  Explain the result in one sentence.
  #pause
  Add the evidence when you are ready.
]
```

#let image-example = ```typst
#image-slide("../../assets/kyklo.webp",
  alt: "A circular research pavilion",
  caption: [A Space For Shared Ideas],
  credit: [Generated demonstration image],
  caption-position: bottom + right,
  caption-width: 48%, caption-margin: 1em,
)
```

#let roadmap-example = ```typst
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
```
