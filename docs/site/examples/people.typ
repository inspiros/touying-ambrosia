#import "@preview/touying-ambrosia:0.1.0": *
// Setup for this example: one optional project mark, with no institution branding.
#let mark(self) = {
  let variants = assets.asset-paths.showcase.touying-ambrosia
  let dark = palettes.prefer-light(self.store.at("logo-background", default: self.page.fill))
  image(assets.read-asset(variants.at(if dark { "dark" } else { "light" })))
}
#show: ambrosia-theme.with(palette: "ocean", primary-logos: (mark,), affiliation-numbering: "*")
// The snippet overrides only this cover; author-columns can pin a different count.
// ANCHOR: example
#title-slide(layout: "header",
  config: config-info(
    title: [A Collaborative Talk],
    authors: (
      (name: [Alex Researcher], affiliations: ("lab",)),
      (name: [Sam Collaborator], affiliations: ("lab",)),
      (name: [Jamie Analyst], affiliations: ("partner",)),
      (name: [Robin Engineer], affiliations: ("partner",)),
    ),
    institutions: (
      lab: [Example Laboratory],
      partner: [Partner Institute],
    ),
    email: "team@example.org",
  ),
)
// ANCHOR_END: example
