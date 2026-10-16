#import "../src/lib.typ": *
#let symbol-numbering = sys.inputs.at("numbering", default: "*")
#let pattern = if symbol-numbering == "custom" { n => [#sym.star#n] } else { symbol-numbering }
#show: ambrosia-theme.with(
  flavor: sys.inputs.at("flavor", default: "minimal"),
  affiliation-numbering: pattern,
  config-info(title: [Linked institutions],
    authors: (
      (name: [First Author], affiliations: ("lab", "university")),
      (name: [Second Author], affiliations: ("lab",)),
    ),
    institutions: (lab: [Shared Laboratory], university: [Example University]),
  ),
)
#title-slide()
#slide(title: [A manual affiliation])[Visiting Researcher#ambrosia-affiliation("university")]
#title-slide(title: [Repeated title], subtitle: [Anchors remain local],
  affiliation-numbering: "I", affiliation-scope: "other")
#slide(title: [After another cover])[Visiting Researcher#ambrosia.affiliation("lab", scope: "other")]
