#import "../src/lib.typ": *
#let flavor = sys.inputs.at("flavor", default: "cambridge")
#let mode = sys.inputs.at("logo", default: "auto")
#let notes = sys.inputs.at("notes", default: "false") == "true"
#show: ambrosia-theme.with(flavor: flavor,
  text-size: float(sys.inputs.at("size", default: "18")) * 1pt,
  navigation-buttons: sys.inputs.at("navigation-buttons", default: "false") == "true",
  footer-logo: if mode == "auto" { auto } else { mode == "true" },
  config-common(show-notes-on-second-screen: if notes { right } else { none }),
  config-info(logo: self => [#image("fixtures/image.svg")<footer-logo-probe>]),
)
#let fill-body = layout(bounds => context {
  [#metadata((height: bounds.height.pt()))<body-region>]
  block(width: 100%, height: 100%, fill: rgb("e6edf3"), inset: 0.3em,
    align(bottom + right)[Content Reaches The Body Boundary])
})
#slide(title: [A Full Content Region])[#fill-body]
#slide(title: [A Local Override], config: config-store(footer-logo: false))[#fill-body]
#slide(title: [Hidden Footer], footer: none)[#fill-body]
