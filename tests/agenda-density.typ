#import "../src/lib.typ": *
#show: ambrosia-theme.with(
  agenda-style: sys.inputs.at("style", default: "cards"),
  palette: "midnight", text-size: 24pt,
  config-common(new-section-slide-fn: none),
  config-info(title: [Dense Agenda], author: [Tester]),
)
#outline-slide(depth: 3)
// Keep the fixture small while exposing the same many-heading model to every
// renderer. Explicit slide content is not turned into automatic dividers.
#slide(title: [Heading Targets])[
  #show heading: none
  #for n in range(1, 36) { heading(depth: 1)[Section #n] }
  #for n in range(1, 31) {
    heading(depth: 2)[A Detailed Topic #n]
    heading(depth: 3)[Assumptions And Limits #n]
  }
  The headings provide native targets for fitting and omission tests.
]
#new-section-slide[Current introduction. #pause Revealed introduction.]
#outline-slide(start: 15)
#ending-slide(title: [End])[]
