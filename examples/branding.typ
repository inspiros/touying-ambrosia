#import "@preview/touying-ambrosia:0.1.0": *
#import "../template/logo-data.typ": display-data

// Change these defaults in an IDE; no command-line setup is required.
#let flavor = "minimal" // try simple, cambridge, darmstadt, or stargazer
#let layout = "header" // try stacked, plain, featured, or split
#let distribution = "grouped" // equal keeps one uniformly spaced logo grid
#let palette = "light" // try midnight to see the adaptive artwork
#let mark(name) = self => image(bytes(display-data(name,
  dark: palettes.prefer-light(self.store.at("logo-background", default: self.page.fill)))))

#show: ambrosia-theme.with(
  flavor: flavor, palette: palette, title-layout: layout,
  primary-logos: (mark("kyklo-logo"), mark("touying-ambrosia")),
  logos: (mark("olympus-institute"), mark("helios-polytechnic")),
  title-logo-distribution: distribution,
  config-info(title: [A Shared Research Identity], author: [Alex Researcher]),
)
#title-slide()
#slide(title: [Two Primary Marks])[
  Both primary marks follow the flavor's ordinary header or footer placement.
  The two partner logos appear only on the opening.
]
#ending-slide(layout: "split", title: [Keep In Touch])[
  The closing card repeats both primary marks.
]
