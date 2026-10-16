#import "../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "short")
#let style = sys.inputs.at("style", default: "cards")
#set heading(numbering: "1.1")
#show: ambrosia-theme.with(
  agenda-style: style,
  palette: sys.inputs.at("palette", default: "light"),
  text-size: int(sys.inputs.at("size", default: "18")) * 1pt,
  font: sys.inputs.at("font", default: auto),
  config-common(new-section-slide-fn: if mode == "empty" { none } else { new-section-slide }),
  config-info(title: [Agenda Treatments], author: [Tester]),
)
#outline-slide(depth: 2)[Opening introduction.]
#if mode != "empty" {
  for n in range(1, if mode == "single" { 2 } else { 5 }) {
    heading(depth: 1)[Stage #n#if mode == "wrapped" [: A Deliberately Long Section Title That Wraps Onto Another Line And Tests First-Line Alignment]]
    [Section introduction.]
    if n == 2 { pause; [Revealed introduction.] }
    heading(depth: 2)[A Result For Stage #n]
    [Evidence.]
    heading(depth: 2)[A Follow-Up For Stage #n]
    [Discussion.]
  }
}
#outline-slide(depth: 1, numbered: false)
#outline-slide(style: "path", title: [Revisit The Talk])
#ending-slide(title: [Questions?])[]
#show: appendix
= Backup Only
== Supporting Detail
Appendix evidence.
#outline-slide(depth: 2)
