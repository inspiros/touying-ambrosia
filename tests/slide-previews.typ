#import "../src/lib.typ": *
#let case = sys.inputs.at("case", default: "integer")
#show: ambrosia-theme.with(config-common(new-section-slide-fn: none))
#slide(title: [Explicit Target])[#metadata(none)<explicit-target> First frame. #pause Second frame.]
#slide(title: [A Visual Reference])[
  #ambrosia-slide-preview(if case == "missing" { <missing-slide> } else { <explicit-target> },
    frame: if case == "out-of-range" { 3 } else { 2 })
]
