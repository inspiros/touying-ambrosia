#import "../src/lib.typ": *
#let case = sys.inputs.at("case", default: "name")
#let navigation = { if case == "name" { "unknown-navigation" }
  else if case == "placement" { ambrosia-navigation(placement: "header") }
  else if case == "width" { ambrosia-navigation(width: "wide") }
  else { "sidebar" } }
#show: ambrosia-theme.with(navigation: navigation,
  navigation-width: if case == "too-wide" { 100em } else { auto })
#slide[Content.]
