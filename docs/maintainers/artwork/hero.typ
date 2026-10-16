#import "../../../src/lib.typ": ambrosia-shadow

// README hero artwork, independent of presentation page rules. Edit in your IDE.
// The miniature slides are bundled actual theme renders. Refresh them and the
// SVG with `python3 scripts/render-thumbnail.py` after changing the theme.
#let title = [Ambrosia]
#let tagline = [Make It Yours.]
#set text(font: "Inter", size: 18pt, fill: rgb("183454"))
#let unit = 1em / 18
#set page(width: 960 * unit, height: 540 * unit, margin: 0 * unit, fill: rgb("f8f9fd"))
#set par(leading: 0.4em)

// Soft chromatic light ties the palette fan to the colors in the project logo.
#place(top + left, dx: -70 * unit, dy: 40 * unit,
  circle(width: 520 * unit, stroke: none,
    fill: gradient.radial(rgb("a587f524"), rgb("a587f500"))))
#place(bottom + right, dx: 50 * unit, dy: 95 * unit,
  circle(width: 650 * unit, stroke: none,
    fill: gradient.radial(rgb("57aafd25"), rgb("57aafd00"))))
#place(top + right, dx: 50 * unit, dy: -100 * unit,
  circle(width: 520 * unit, stroke: none,
    fill: gradient.radial(rgb("fd7a7b24"), rgb("fd7a7b00"))))

#let card(name, x, y, width, angle) = place(top + left, dx: x * unit, dy: y * unit,
  rotate(angle, reflow: false,
    ambrosia-shadow(radius: 7 * unit, blur: 15 * unit, dx: 0 * unit, dy: 8 * unit,
      fill: rgb("27375a28"),
      block(width: width * unit, height: width * unit * 9 / 16,
        radius: 7 * unit, clip: true, stroke: 0.7 * unit + rgb("ffffffaa"),
        image("../../../assets/gallery/thumbnail-" + name + ".webp", width: 100%, height: 100%)))))

#card("midnight", 485, 37, 400, -10deg)
#card("forest", 438, 173, 422, 7deg)
#card("rose", 493, 307, 415, -5deg)

#place(top + left, dx: 51 * unit, dy: 49 * unit,
  text(size: 12 * unit, weight: "medium", tracking: 0.15em)[TYPST × TOUYING])
#place(top + left, dx: 39 * unit, dy: 91 * unit,
  image("../../../assets/logos/touying-ambrosia.svg", height: 184 * unit))
#place(top + left, dx: 51 * unit, dy: 294 * unit,
  text(size: 20 * unit, weight: "medium", tracking: 0.02em)[touying])
#place(top + left, dx: 47 * unit, dy: 319 * unit,
  text(size: 56 * unit, weight: "bold", tracking: -0.04em, title))
#place(top + left, dx: 52 * unit, dy: 399 * unit,
  text(size: 23 * unit, fill: rgb("4f6380"), tagline))

// A continuous spectrum suggests custom palettes beyond the shipped presets.
#place(top + left, dx: 53 * unit, dy: 466 * unit,
  rect(width: 232 * unit, height: 5 * unit, radius: 3 * unit, stroke: none,
    fill: gradient.linear(rgb("57aafd"), rgb("a587f5"), rgb("fd7a7b"), rgb("fcb944"))))
#place(top + left, dx: 53 * unit, dy: 487 * unit,
  text(size: 10 * unit, weight: "medium", fill: rgb("66778e"))[
    Layouts · Palettes · Branding · Navigation
  ])
