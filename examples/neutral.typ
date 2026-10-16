#import "../src/lib.typ": *
// Start completely unbranded; edit these values directly in your IDE.
#let flavor = "minimal"
#let palette = "light"
#show: ambrosia-theme.with(flavor: flavor, palette: palette, config-info(title: [Ambrosia], subtitle: [Your Layouts, Colors, And Content], author: [Presenter]))
#title-slide()
#slide(title: [A Neutral Starting Point])[
  #ambrosia-block(kind: "info", title: [Independent Choices])[
    A flavor chooses geometry. A palette chooses colors. Branding belongs to you.
  ]
]
#ending-slide(title: [Questions?])[]
