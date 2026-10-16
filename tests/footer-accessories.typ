#import "../src/lib.typ": *
#let unit = sys.inputs.at("unit", default: "em")
#show: ambrosia-theme.with(flavor: "cambridge", navigation: "segments",
  text-size: if unit == "relative" { 1.5em } else { 18pt },
  footer-logo-height: if unit == "em" { 1.1em } else { 20pt },
  navigation-buttons: true, config-common(new-section-slide-fn: none),
  config-info(title: [Compact Accessories], author: [Presenter], logo: self => image("fixtures/image.svg")))
= Main Section
=== Full Content
#layout(bounds => context {
  [#metadata((height: bounds.height.pt()))<accessory-body>]
  block(width: 100%, height: 100%, fill: rgb("e6edf3"))[Full Body]
})
