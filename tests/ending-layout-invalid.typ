#import "../src/lib.typ": *
#let case = sys.inputs.at("case", default: "name")
#let options = {
  if case == "name" { "unknown" }
  else if case == "key" { (typo: true) }
  else if case == "side" { (logos-placement: "side") }
  else if case == "columns" { (logo-columns: 0) }
  else { (title-shadow: "yes") }
}
#show: ambrosia-theme.with(ending-layout: options)
#ending-slide(title: [Ending])[]
