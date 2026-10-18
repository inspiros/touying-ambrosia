#import "@preview/touying-ambrosia:0.1.0": *
#show: ambrosia-theme.with(palette: "ocean")
#slide(title: [A Useful Container])[
// Change style for geometry and kind for meaning. The preview shows both frames' content.
// ANCHOR: example
#ambrosia-block(
  style: "tabbed", kind: "success",
  title: [A Useful Result],
)[
  Explain the result in one sentence.
  #ambrosia-block(style: "outlined", title: [Evidence])[
    Begin with the observation.
    #pause
    Add its limits when you are ready.
  ]
]
// ANCHOR_END: example
]
