#import "@preview/touying-ambrosia:0.1.0": *
#import "../template/project-brand.typ": project-theme

// Edit these settings in an IDE. Each ending is an ordinary counted slide.
#let layout = "all" // "centered", "plain", "split", "cover"
#let palette = "ocean"
#let layout = sys.inputs.at("layout", default: layout)
#show: project-theme.with(palette: palette,
  config-info(title: [A Clear Last Slide], author: [Alex Researcher],
    email: "alex@example.org", short-title: [Closing Layouts]),
)

// Theme-wide default: project-theme(ending-layout: "split", ...).
// Shared contacts are preferred; otherwise personal author emails are collected.
#for name in if layout == "all" { extensions.ending-layout-names } else { (layout,) } {
  ending-slide(layout: name, title: [Questions?])[
    One clear result. One useful next step.
    #parbreak()
    #link("https://github.com/inspiros/touying-ambrosia")[Project And Materials]
  ]
}

// Same descriptor pattern as titles; body content stays positional for pauses.
#let contact-card = ambrosia-ending-layout(base: "split", name: "contact-card", side-width: 38%)
#ending-slide(layout: contact-card, title: [Keep In Touch], contacts: ("group@example.org",))[
  + State the result you want the audience to remember.
  #pause
  + Give them a concrete next step.
]

// A quiet ending with no contact or logo reservation.
#ending-slide(layout: "plain", contacts: none, logos: none, title: [Thank You])[]

#let photograph = ambrosia-ending-layout(base: "cover", name: "photograph",
  background-image: image("../assets/kyklo.webp", width: 100%, height: 100%, fit: "cover"),
  background-overlay: self => self.colors.cover.transparentize(35%),
)
#ending-slide(layout: photograph, title: [Let's Discuss])[Methods, Evidence, And Next Steps]
