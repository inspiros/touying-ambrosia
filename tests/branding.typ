#import "../src/lib.typ": *
#let flavor = sys.inputs.at("flavor", default: "minimal")
#let mode = sys.inputs.at("primary", default: "multiple")
#let mark(name, wide: false) = self => box(width: if wide { 12em } else { 4em }, height: 1em,
  fill: self.colors.surface-alt, text(size: 0.55em, fill: self.colors.foreground, name))
#show: ambrosia-theme.with(
  flavor: flavor,
  palette: sys.inputs.at("palette", default: "light"),
  primary-logos: if mode == "none" { none } else if mode == "auto" { auto }
    else { (mark("PRIMARYONE", wide: true), mark("PRIMARYTWO")) },
  logos: (mark("PARTNERONE"), mark("PARTNERTWO")),
  title-logo-distribution: "grouped",
  navigation: sys.inputs.at("navigation", default: "none"),
  navigation-buttons: true, footer-logo: true,
  config-common(new-section-slide-fn: none),
  config-info(title: [Collaborative Branding], author: [Research Team], logo: mark("FALLBACK")),
)
= Overview
#for name in extensions.title-layout-names { title-slide(layout: name) }
#slide(title: [Ordinary Content])[BODY ONE]
#section-slide(title: [A New Section])[]
#ending-slide(layout: "split", contacts: none, title: [Questions?])[ENDING BODY]
#focus-slide[FOCUS BODY]
#slide(title: [No Primary Logos], config: config-store(primary-logos: none))[BODY TWO]
