#import "../src/lib.typ": *
#let style = sys.inputs.at("numbering", default: "i")
#let total = sys.inputs.at("total", default: "false") == "true"
#let pattern = { if style == "none" { none }
  else if style == "custom" {
    if total { (n, total) => [Extra #n of #total] } else { n => [Extra #n] }
  } else if style == "invalid" { false } else { style } }
#show: ambrosia-theme.with(
  flavor: "minimal", appendix-numbering: pattern, appendix-total: total,
  config-common(new-section-slide-fn: none,
    handout: sys.inputs.at("mode", default: "slides") == "handout"),
  ..if sys.inputs.at("mode", default: "slides") == "continuous" {
    (footer-ad: self => context [#utils.slide-counter.get().first() / #utils.slide-counter.final().first()],)
  } else { (:) },
)
#slide(title: [Main One])[Main body.]
#slide(title: [Main Two])[Main body.]
#show: appendix
#slide(title: [Appendix One])[
  Appendix body.
  #pause
  Another animation frame.
]
#slide(title: [Appendix Two], config: if sys.inputs.at("mode", default: "slides") == "local" {
  config-store(appendix-numbering: "S1", appendix-total: true)
} else { (:) })[Appendix body.]
#backup-slide(title: [Uncounted Backup])[Retains the previous number.]
