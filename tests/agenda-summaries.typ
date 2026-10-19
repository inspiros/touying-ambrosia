#import "../src/lib.typ": *
#let size = int(sys.inputs.at("size", default: "18")) * 1pt
#let local-size = sys.inputs.at("local-size", default: "auto")
#let agenda-size = sys.inputs.at("agenda-size", default: "auto")
#show: ambrosia-theme.with(
  text-size: size,
  agenda-text-size: if agenda-size == "auto" { 1.15em } else { int(agenda-size) * 1pt },
  agenda-style: sys.inputs.at("style", default: "list"),
  palette: sys.inputs.at("palette", default: "light"),
  config-common(new-section-slide-fn: new-section-slide.with(
    text-size: if local-size == "auto" { auto } else { int(local-size) * 1pt })),
)
#outline-slide(depth: 1, text-size: if sys.inputs.at("overview-size", default: "auto") == "auto" { auto } else { int(sys.inputs.at("overview-size")) * 1pt })
= Without Summary
== First Result
Evidence.

= Metadata Only
#metadata([Metadata must not become a summary.])<summary-fixture>
#speaker-note[Private note; not a chapter summary.]
== Second Result
Evidence.

= With Summary
Explain this chapter's question.
#pause
Then add the approach.
== Third Result
Evidence.

= After Summary
== Fourth Result
Evidence.

#show: appendix
= Supporting Material
== Additional Result
Extra evidence.
