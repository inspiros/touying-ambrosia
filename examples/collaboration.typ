#import "@preview/touying-ambrosia:0.1.0": ambrosia
#import "showcase.typ": kyklo-theme

// Fictional collaboration: edit metadata and numbering directly in an IDE.
#let palette = "ocean"
#let affiliation-numbering = "*" // "1", "a", "I", or a custom numbering function
#show: kyklo-theme.with(
  affiliation-numbering: affiliation-numbering,
  flavor: "minimal", palette: palette,
  ambrosia.config-info(
    title: [A Collaborative Research Presentation],
    subtitle: [Names, Affiliations, And Contact Details],
    authors: (
      (name: [Alice Researcher], short: [A. Researcher], affiliations: ("kyklo", "olympus"), email: "alice@example.org"),
      (name: [Bob Collaborator], affiliations: ("partner",), email: "bob@partner.example"),
      (name: [Charlie Scientist], affiliations: ("kyklo",)),
    ),
    institutions: (
      kyklo: [Kyklo Laboratory],
      olympus: [Olympus Institute],
      partner: [Helios Polytechnic],
    ),
    emails: ("project@research.example",),
    short-author: [Researcher et al.],
    short-title: [Collaborative Research],
  ),
)
#ambrosia.title-slide()

= Shared Results

== A Clear Contribution
#ambrosia.block(style: "poster", kind: "success", watermark: "body", title: [Result])[
  A shared container with a clear purpose.
  #ambrosia.badge(kind: "success")[Validated]
]
#ambrosia.source-note[Data and contact information belong near their context.]
#ambrosia.ending-slide(title: [Questions?])[Let's discuss.]
