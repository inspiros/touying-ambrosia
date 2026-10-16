#import "../src/lib.typ": *
#let size = float(sys.inputs.at("size", default: "18")) * 1pt
#let brand(name) = self => box(height: 1em,
  fill: self.store.at("logo-background", default: self.page.fill), text(size: 0.65em, fill: self.colors.primary, name))
#show: ambrosia-theme.with(
  flavor: sys.inputs.at("flavor", default: "minimal"),
  palette: sys.inputs.at("palette", default: "light"),
  title-layout: ambrosia-title-layout(base: "header", name: "theme-header", logo-height: 1.5em),
  logos: (brand("DEFAULTPARTNER"),),
  title-logos: (brand("EXPLICITONE"), brand("EXPLICITTWO")),
  text-size: size,
  config-common(new-section-slide-fn: none),
  config-info(title: [A Reliable Opening For A Collaborative Presentation],
    subtitle: [Metadata, Branding, And Readable Layouts], logo: brand("MAINLOGO"),
    authors: (
      (name: [Alice Researcher], affiliations: ("one",), email: "alice@example.org"),
      (name: [Bob Collaborator], affiliations: ("two",), email: "bob@example.org"),
      (name: [Chris Scientist], affiliations: ("one", "two"))),
    institutions: (one: [First Research Group], two: [Second Research Group]),
    date: [TITLE DATE]),
)

// All presets override only the cover; theme and local explicit logos win.
#for name in extensions.title-layout-names { title-slide(layout: name) }
#title-slide()
#title-slide(layout: "header", logos: (brand("LOCALONLY"),))
#title-slide(layout: "header", logos: none)
#title-slide(layout: ambrosia-title-layout(base: "header", name: "wrapped", logo-columns: 2),
  logos: (brand("A"), brand("B"), brand("C"), brand("D"), brand("E")))
#title-slide(layout: ambrosia-title-layout(base: "plain", name: "hidden", logos-placement: "none"))
#title-slide(config: config-store(title-layout: "plain", title-logos: auto))
#slide(title: [Ordinary Slide])[AFTER TITLE]
