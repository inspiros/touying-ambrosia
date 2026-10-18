#import "@preview/touying-ambrosia:0.1.0": *
// Try a new hex seed; all displayed role colors come from the active palette.
// ANCHOR: example
#let fieldwork = ambrosia-palette(
  base: "light", name: "Fieldwork",
  primary: rgb("2b6b51"),
)
#show: ambrosia-theme.with(palette: fieldwork)
#slide(title: [Our Visual Language])[
  #ambrosia-palette-showcase(columns: 5)
]
// ANCHOR_END: example
