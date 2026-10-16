#import "../src/lib.typ": *
#let flavor = sys.inputs.at("flavor", default: "minimal")
#let min-scale = if sys.inputs.at("min-scale", default: "auto") == "full" { 100% } else { 65% }
#show: ambrosia-theme.with(
  flavor: flavor,
  palette: sys.inputs.at("palette", default: "nocturne"),
  font: "DejaVu Sans",
  text-size: float(sys.inputs.at("text-size", default: "18")) * 1pt,
  title-min-scale: min-scale,
  config-info(title: [Short title], author: [Tester], date: [SHORT DATE]),
)

#title-slide()

// Deliberately enough metadata to need fitting at large text sizes.
#title-slide(
  title: [A detailed research presentation about reliable scientific methods and their practical applications],
  subtitle: [Results, experimental validation, and perspectives for future research],
  authors: ([First Author], [Second Author], [Third Author], [Fourth Author], [Fifth Author], [Sixth Author]),
  institution: [Kyklo Laboratory, Olympus Institute, Helios Polytechnic, Delphi Forum],
  emails: ("first@example.org", "second@example.org", "third@example.org"),
  date: [DENSE DATE],
)

#slide(title: [After the title])[NEXT SLIDE]
