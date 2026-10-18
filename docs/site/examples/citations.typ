#import "@preview/touying-ambrosia:0.1.0": *
#show: ambrosia-theme.with(palette: "ocean")
// Keep references.bib beside this file. Both citations refer to the same entry.
// ANCHOR: example
#slide(title: [One Citation Identity])[
  An ordinary reference @knuth84.
  A full note #footcite(<knuth84>).
]
#bibliography-slide("references.bib")
// ANCHOR_END: example
