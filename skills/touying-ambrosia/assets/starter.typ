// A complete unbranded deck. Copy this file into your presentation project.
// Edit these defaults in your Typst IDE; no command-line inputs are required.
#import "@preview/touying-ambrosia:0.1.0": *

#show: ambrosia-theme.with(
  // Geometry, colors, and navigation are independent choices.
  flavor: "minimal",
  palette: "ocean",
  navigation: "context", // auto follows the flavor; none removes navigation.
  title-layout: "plain", // Override on one cover with title-slide(layout: ...).
  ending-layout: "centered",
  config-info(
    title: [From Question To Evidence],
    subtitle: [A Short Presentation],
    author: [Alex Researcher],
    short-title: [Question To Evidence], // A compact footer label.
    email: "alex@example.org",
  ),
  // Disable automatic section agendas for this short talk.
  config-common(new-section-slide-fn: none),
)

#title-slide()
#outline-slide(depth: 1)

= The Question
== Why It Matters
One clear question, with enough context to understand it.

// Explicit slides work with every flavor, independent of heading levels.
#slide(title: [Evidence And Interpretation])[
  #ambrosia-block(style: "stripe", kind: "info", title: [Evidence])[
    Describe an observation, with its source where appropriate.
  ]
][
  #ambrosia-block(style: "plain", kind: "success", title: [Interpretation])[
    Explain what the observation supports.
  ]
]

= The Result
== One Result To Remember
#alert[State the main finding.]
#pause
#muted[Then add its most useful qualification.]
// Notes are metadata by default; export a pdfpc sidecar for presenter view.
#speaker-note[Explain the qualification before moving on.]

#ending-slide(title: [Questions?])[
  One takeaway, and a useful next step.
]

// Appendix slides do not increase the main talk's total.
#show: appendix
== Supporting Detail
Keep extra evidence available for discussion.
