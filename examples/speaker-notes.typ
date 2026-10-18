#import "../src/lib.typ": *

// Preview normally in a Typst IDE. Edit the default below to compare outputs:
// "audience": ordinary slides, with invisible notes available for .pdfpc export.
// "split": slide + notes on one double-width page; run pdfpc --notes=right.
// "notes": a rehearsal document with notes and a slide thumbnail.
#let output = sys.inputs.at("output", default: "audience")
#assert(output in ("audience", "split", "notes"), message: "Output must be audience, split, or notes.")
// For split output, top/bottom produce double-height pages instead.
#let sides = (right: right, left: left, top: top, bottom: bottom)
#let notes-side = sides.at(sys.inputs.at("notes-side", default: "right"))

// A single presentation body supports ordinary IDE/CLI compilation and the
// optional bundle export below. Changing output never requires editing notes.
#let presentation = [
  // Put pdfpc metadata before the theme show rule so it cannot become a slide.
  // These settings go into the sidecar, not the slide's visible content.
  #pdfpc.config(duration-minutes: 12)
  #show: ambrosia-theme.with(
    flavor: "minimal", palette: "ocean",
    config-common(
      show-only-notes: output == "notes",
      show-notes-on-second-screen: if output == "split" { notes-side } else { none },
    ),
    config-info(title: [Speaker Notes], author: [Presenter]),
  )

  #slide(title: [Introduce The Question])[
    A concise statement for the audience.
    #speaker-note[
      Explain the motivation before showing the result.
    ]
    #pause
    The evidence appears on the next animation frame.
    #speaker-note[
      Emphasize the result and pause for questions.
    ]
  ]

  #slide(title: [Discuss The Next Step])[
    Invite the audience to consider the next experiment.
    // Markdown mode is useful for pdfpc's text notes. Split-page notes instead
    // render this as Typst content, so use Typst markup for their visible style.
    #speaker-note(mode: "md")[- Ask which assumption should be tested first.]
  ]
]

// Normal, stable workflow (run from the repository root):
// typst compile --root . examples/speaker-notes.typ target/speaker-notes.pdf
// typst eval --root . --in examples/speaker-notes.typ 'query(<pdfpc-file>).first().value' > target/speaker-notes.pdfpc
// pdfpc --notes=none target/speaker-notes.pdf
//
// Optional Typst 0.15 experimental bundle export, using this same source:
// typst compile --features bundle --format bundle --input bundle=true --root . examples/speaker-notes.typ target/speaker-bundle
// Produces speaker-notes.pdf and speaker-notes.pdfpc together in that directory.
#if sys.inputs.at("bundle", default: "false") == "true" {
  pdfpc.bundle-assets()
  document("speaker-notes.pdf", presentation)
} else {
  presentation
}
