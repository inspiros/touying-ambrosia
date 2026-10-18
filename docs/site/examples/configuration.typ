// Change each choice independently; the sidebar reserves its own space.
// ANCHOR: example
#import "@preview/touying-ambrosia:0.1.0": *
#show: ambrosia-theme.with(
  flavor: "minimal", palette: "midnight",
  navigation: "sidebar",
  config-common(new-section-slide-fn: none),
  config-info(title: [From Idea To Evidence]),
)
= A Shared Question
== One Useful Finding
#ambrosia-block(style: "stripe", kind: "success")[
  Geometry, color, and navigation are independent.
]
// ANCHOR_END: example
