#import "../src/lib.typ": *
// Appendix agenda entries must use the same numbering as appendix footers.
#let style = sys.inputs.at("numbering", default: "i")
#show: ambrosia-theme.with(
  flavor: "minimal",
  appendix-numbering: if style == "none" { none } else if style == "custom" { n => [Annex #n] }
    else if style == "custom-total" { (n, total) => [Annex #n of #total] } else { style },
  appendix-total: style == "custom-total",
  config-common(new-section-slide-fn: none),
)
== Main Slide
Main body.
#show: appendix
== Backup One
Backup body.
== Backup Two
Backup body.
#outline-slide(depth: 2)
