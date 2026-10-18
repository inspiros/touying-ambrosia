#import "@preview/touying-ambrosia:0.1.0": *
// ANCHOR: example
#show: ambrosia-theme.with(
  flavor: "cambridge", palette: "ocean",
  navigation: "tree",
  config-common(new-section-slide-fn: none),
  config-info(title: [From Idea To Evidence]),
)
= Motivation
== A Shared Question
=== The Starting Point
Begin with the question that connects the talk.

= Methods
== An Explicit Model
=== Analysis
#ambrosia-block(style: "stripe")[
  The strips retain the talk, section,
  and subsection context.
]
// ANCHOR_END: example
