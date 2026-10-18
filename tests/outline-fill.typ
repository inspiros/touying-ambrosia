#import "../src/lib.typ": *
#let choice = sys.inputs.at("fill", default: "dots")
#let leaders = if choice == "none" { none } else if choice == "line" {
  repeat[–]
} else { repeat[.] }
#show: ambrosia-theme.with(flavor: "minimal",
  agenda-style: sys.inputs.at("style", default: "list"),
  outline-fill: leaders,
  config-common(new-section-slide-fn: none),
  config-info(title: [Outline Leaders], author: [Presenter]))
#outline-slide(depth: 2)
#outline-slide(fill: none, depth: 2)
#outline-slide(fill: repeat[–], depth: 2)
#slide(title: [Heading Targets])[
  #show heading: none
  = A Short Section
  == A Result
  = A Long Section Heading That Wraps Onto More Than One Line In A Narrow Agenda Without Losing Its Slide Number
  == A Follow-Up
]
#new-section-slide(neighbors: 1)[]
