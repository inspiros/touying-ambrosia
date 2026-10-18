#import "@preview/touying-ambrosia:0.1.0": *
#show: ambrosia-theme.with(palette: "ocean")
#slide(title: [A Little Hierarchy])[
// Helpers inherit the surrounding text size. Badges can optionally cast a shadow.
// ANCHOR: example
Regular text, #alert[the key point],
#muted[secondary context],
and #subtle[an optional aside].

#ambrosia-badge(kind: "success", shadowed: true)[Verified]
#ambrosia-badge(kind: "warning")[Preliminary]

#ambrosia-source-note[Source: Example Dataset, 2026.]
// ANCHOR_END: example
]
