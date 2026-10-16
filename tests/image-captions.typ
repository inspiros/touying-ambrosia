#import "../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "slides")
#let sides = (left: left, right: right, top: top, bottom: bottom)
#let size = int(sys.inputs.at("size", default: "18")) * 1pt
#show: ambrosia-theme.with(palette: sys.inputs.at("palette", default: "ocean"), text-size: size,
  config-common(handout: mode == "handout", show-only-notes: mode == "notes",
    show-notes-on-second-screen: if mode == "second-screen" { sides.at(sys.inputs.at("side", default: "right")) } else { none }),
  config-info(title: [Image Captions], author: [Tester]),
)
#let invalid = sys.inputs.at("invalid", default: "")
#if invalid != "" {
  let options = if invalid == "position" { (caption-position: "top",) }
    else if invalid == "width" { (caption-width: 120%,) }
    else { (caption-width: 20%, caption: lorem(1000)) }
  image-slide("fixtures/image.svg", ..((caption: [Invalid],) + options))
} else {
  let credit = [#link("https://example.org")[Caption Link]]
  image-slide("fixtures/image.svg", caption: [Default Bottom], credit: credit, alt: "Caption Fixture")
  image-slide("fixtures/image.svg", caption: [Top Band], credit: credit, caption-position: top)
  image-slide("fixtures/image.svg", caption: [Top Right], credit: credit,
    caption-position: top + right, caption-width: 42%, caption-margin: 1em)
  image-slide("fixtures/image.svg", caption: [Bottom Left], credit: credit,
    caption-position: bottom + left, caption-width: 16em,
    caption-margin: (left: 2em, right: 1em, top: 0.5em, bottom: 1.5em))
  image-slide("fixtures/image.svg", caption: [Centered], credit: credit,
    caption-position: center + horizon, caption-width: 55%, caption-margin: 1em)
  image-slide("fixtures/image.svg", credit: credit, caption-fill: white,
    caption-position: bottom + right, caption-width: 40%, caption-margin: 1em)
  image-slide("fixtures/image.svg", caption: [Without A Panel], caption-fill: none,
    caption-text-fill: black, fit: "contain", caption-position: top, caption-margin: 1em)
  image-slide("fixtures/image.svg")
}
