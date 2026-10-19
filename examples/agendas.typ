#import "@preview/touying-ambrosia:0.1.0": *
#import "../template/project-brand.typ": project-theme

// Edit these defaults in your IDE. No command-line input is required.
#let style = "list" // list: compact; cards: short overview; path: connected hierarchy
#let palette = "ocean"
#let style = sys.inputs.at("style", default: style)
#let palette = sys.inputs.at("palette", default: palette)
#set heading(numbering: "1.1")
#show: project-theme.with(
  palette: palette,
  outline-fill: none, // change to repeat[.] for dotted leaders
  agenda-style: style, // default for BOTH overviews and automatic section dividers
  agenda-text-size: 1.15em, // relative to body text; try 1.2em or 20pt
  font: "DejaVu Sans",
  config-common(new-section-slide-fn: new-section-slide.with(neighbors: 1)),
  config-info(title: [From Question To Result], author: [Presenter], short-title: [Agendas]),
)

// depth includes heading levels, not just children. Native links and logical
// slide numbers stay available in every style. Try depth: 2 to add slide titles.
#outline-slide(depth: 1)

= Ask The Question
A short chapter summary shares the fitted region in its own quiet panel.
== The Starting Point
What is the problem, and why does it matter?
== What We Need To Learn
State one concrete question.

= Design The Approach
The divider centers this section and its children. Neighbors remain quiet.
== A Useful Baseline
Establish the comparison.
== A Clear Method
Explain the approach and its assumptions.

= Examine The Evidence
// No summary here: the expanded branch has no empty introduction panel/gap.
== The Main Result
Show the evidence at an appropriate scale.
== Limits And Tradeoffs
Make the scope of the result clear.

= Choose The Next Step
== A Practical Takeaway
Turn the result into a decision.

// Per-slide style overrides the theme-wide choice. For example, use cards in
// the opening and a path when revisiting progress near the end of the talk.
#outline-slide(style: "path", depth: 1, title: [Where We Have Been])
#ending-slide(title: [Questions?])[]

// Appendix agendas use their own heading scope, just like native navigation.
#show: appendix
= Supporting Material
== Additional Evidence
A detail kept out of the main argument.
