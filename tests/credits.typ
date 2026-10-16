#import "../src/lib.typ": *
#show: ambrosia-theme.with(flavor: "minimal", palette: sys.inputs.at("palette", default: "ocean"),
  config-info(title: [Credit Cards]), config-common(new-section-slide-fn: none))
#slide(title: [Default Credit])[
  #ambrosia-credit-card(width: 65%)
]
#slide(title: [Without A QR])[
  #ambrosia.credit-card(qr: false, width: 45%)
]
#slide(title: [Downstream Identity])[
  #ambrosia-credit-card(project: (name: "Example Theme", url: "https://example.org/theme"),
    title: [Created With Typst], link-label: [Project Home], width: 55%)
]
#ending-slide(layout: "centered", title: [Thank You])[
  #ambrosia-credit-card(width: 65%, qr: self => image(assets.read-asset(assets.asset-paths.credit-qr)))
]
