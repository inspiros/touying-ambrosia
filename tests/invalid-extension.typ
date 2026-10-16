#import "../src/lib.typ": *
#let bad = if sys.inputs.at("kind", default: "key") == "key" {
  ambrosia-flavor(typo-margin: 3em)
} else { ambrosia-flavor(title-renderer: true) }
#show: ambrosia-theme.with(flavor: bad)
