#import "@preview/touying-ambrosia:0.1.0": *
#import "../template/project-brand.typ": project-theme

// Edit the native alignment, width and margin to preview your own composition.
#let compare = true // false: render just the editable settings below
#let position = top + right
#let width = 42% // a percentage of the region left AFTER margin
#let margin = 1em // use 0em with 100% width for an edge-to-edge band
#let palette = "ocean"
#show: project-theme.with(palette: sys.inputs.at("palette", default: palette), font: "DejaVu Sans",
  config-info(title: [Image Captions], author: [Presenter]),
)
#let choices = (
  (name: [Bottom Band], position: bottom, width: 100%, margin: 0em),
  (name: [Top Band], position: top, width: 100%, margin: 0em),
  (name: [Top Right Card], position: top + right, width: 42%, margin: 1em),
  (name: [Bottom Left Card], position: bottom + left, width: 42%, margin: 1em),
)
#for choice in if compare { choices } else { ((name: [Your Own Placement], position: position, width: width, margin: margin),) } {
  image-slide("../assets/kyklo.webp", caption: choice.name,
    credit: [An Illustrative Laboratory · #link("https://example.org")[Image Details]],
    caption-position: choice.position, caption-width: choice.width, caption-margin: choice.margin,
    alt: "An imaginary laboratory, used to compare caption positions")
}
// You can opt into a quiet light panel or set caption-fill: none and choose a
// text color for your photograph. These overrides don't change the palette.
#image-slide("../assets/kyklo.webp", caption: [A Quiet Light Panel],
  caption-position: bottom + right, caption-width: 38%, caption-margin: 1em,
  caption-fill: white, // automatic dark text contrasts with this explicit fill
  alt: "An imaginary laboratory, with a white caption panel")
