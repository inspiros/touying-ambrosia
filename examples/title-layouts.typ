#import "@preview/touying-ambrosia:0.1.0": *
#import "../template/project-brand.typ": project-theme
#import "logo-data.typ": display-data

// Edit these values in your IDE. Set layout to a single preset, or "all".
#let layout = "all" // "stacked", "header", "split", "plain", "featured", "cover"
#let flavor = "minimal" // a title layout overrides just the flavor's cover
#let palette = "ocean"
#let layout = sys.inputs.at("layout", default: layout)
#show: project-theme.with(
  flavor: flavor, palette: palette,
  config-info(
    title: [One Presentation, Many Openings], subtitle: [Title Layouts In Ambrosia],
    authors: (
      (name: [Alex Researcher], affiliations: ("lab",), email: "alex@example.org"),
      (name: [Sam Collaborator], affiliations: ("lab",), email: "sam@example.org"),
    ),
    institutions: (lab: [An Example Research Group]),
    date: [15 October 2026], short-title: [Title Layouts],
  ),
)

// Theme-wide: project-theme(title-layout: "header", ...).
// Per slide: layout changes only this cover, and keeps its metadata/links.
#for name in if layout == "all" { extensions.title-layout-names } else { (layout,) } {
  title-slide(layout: name, subtitle: [The #name Layout])
}

// A descriptor changes a preset without a new flavor or renderer.
// A transparent header also works: header-background: none.
#let partner-header = ambrosia-title-layout(base: "header", name: "partners",
  logos-align: center, logo-height: 1.8em, logo-columns: 3,
  title-shadow: false, title-radius: 0em,
)
#let partner(name) = self => image(bytes(display-data(name,
  dark: palettes.prefer-light(self.store.logo-background))))

// An explicit logos collection is the complete ordered list on this cover.
// No main/partner/institution roles are needed, and the footer keeps its logo.
#title-slide(layout: partner-header, subtitle: [Equal Partners In One Header],
  logos: (partner("olympus-institute"), partner("helios-polytechnic"), partner("delphi-forum")))

// This restores all space reserved for title branding.
#title-slide(layout: "plain", logos: none, subtitle: [An Unbranded Opening])

// Common photographic cover: ordinary native image content retains this file's path.
// The overlay protects contrast; tune its transparency to suit your photograph.
#let photograph = ambrosia-title-layout(base: "cover", name: "photograph",
  background-image: image("../assets/kyklo.webp", width: 100%, height: 100%, fit: "cover"),
  background-overlay: self => self.colors.cover.transparentize(35%),
)
#title-slide(layout: photograph, subtitle: [A Photographic Cover])

#slide(title: [The Ordinary Flavor Continues])[
  Title composition, flavor, palette, and the deck's ordinary branding can be chosen independently.
  #ambrosia-block(style: "tabbed", title: [One Configuration, Clear Choices])[
    Use a layout preset for composition, a descriptor for adjustments, and a renderer for a fully custom cover.
  ]
]
