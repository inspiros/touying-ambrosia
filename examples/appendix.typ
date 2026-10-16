#import "../src/lib.typ": *

// Edit these options in your IDE: "i", "1", "A", "S1", or none.
// For a literal A prefix, use n => [A#n] (without totals) or
// (n, total) => [A#n / A#total] (with totals).
#show: ambrosia-theme.with(
  flavor: "minimal", palette: "ocean",
  appendix-numbering: "S1",
  appendix-total: true,
  config-info(title: [Main Talk And Supporting Material], author: [Presenter]),
)
#slide(title: [The Main Question])[What should the audience remember?]
#slide(title: [The Main Result])[The main talk ends at slide 2 / 2.]

// This starts the appendix. Its numbering: argument, if supplied, affects
// headings; the theme options above control the footer's slide labels.
#show: appendix
#slide(title: [Supporting Evidence])[
  This is S1 / S2. Animation frames repeat the same logical slide number.
  #pause
  More evidence on the same slide.
]
#slide(title: [Additional Details])[This is S2 / S2.]
// Explicit backup-slide is uncounted, so it repeats S2 / S2.
#backup-slide(title: [An Uncounted Supplement])[A spare slide excluded from the count.]
