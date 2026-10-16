#import "../src/lib.typ": *
#import "../src/theme/flavors.typ": flavor-names, get-flavor
#assert.eq(type(ambrosia.block), function)
#assert.eq(type(muted), function)
#assert.eq(type(subtle), function)
#assert.eq(ambrosia.muted, muted)
#assert.eq(ambrosia.subtle, subtle)
#assert("portico" in flavor-names and not "sidebar" in flavor-names)
#assert.eq(type(ambrosia.flavor), function)
#assert.eq(flavor-names.len(), 7)
#assert(not "legacy" in flavor-names)
#let custom = ambrosia-flavor(name: "fictional", footer-renderer: none)
#assert.eq(custom.name, "fictional")
#assert.eq(custom.footer-renderer, none)
#assert.eq(ambrosia-flavor(base: custom, name: "other", top-margin: 3em).top-margin, 3em)
#assert.eq(get-flavor("cambridge").slide-level, 3)
#assert.eq(palettes.palette-names.len(), 12)
#assert.eq(palettes.contrast(white, white), 1)
#assert(calc.abs(palettes.contrast(white, black) - 21) < 0.001)
#let data = "<svg><path fill=\"#123456\"/><path fill=\"#abcdef\"/></svg>"
#let recolored = assets.colorize-svg(data, source: rgb("123456"), target: rgb("fedcba"))
#assert(recolored.contains("#fedcba") and recolored.contains("#abcdef"))
#for name in palettes.palette-names {
  let p = palettes.resolve(name)
  for background in (p.background, p.surface, p.surface-alt) {
    assert(palettes.contrast(p.foreground, background) >= 4.5)
    assert(palettes.contrast(p.accent, background) >= 4.5)
  }
}
#for paths in assets.asset-paths.showcase.values() {
  for p in paths.values() { assert(str(assets.read-asset(p)).contains("<svg")) }
}
#context {
  let body = block(width: 2em, height: 1em)[A]
  assert.eq(measure(ambrosia-shadow(fill: none, body)), measure(body))
  assert.eq(measure(extensions.frame(stroke: none, body)), measure(body))
}
All neutral assertions passed.

#let custom-palette = ambrosia-palette(primary: rgb("246844"))
#assert.eq(palettes.resolve(custom-palette).accent.to-hex(), "#246844")
#assert.eq(custom-palette.surface-alt, auto)
#assert.eq(palettes.resolve(custom-palette).surface-alt, rgb("246844").lighten(90%))
#let rotated = ambrosia-palette(base: "ocean", rotate: 70deg)
#assert.ne(rotated.background, palettes.palette-definitions.ocean.background)
#assert.eq(palettes.resolve(rotated).info, palettes.readable-accent(rgb("2475b0"),
  (rotated.background, rotated.surface, rotated.surface-alt)))
#assert.eq(ambrosia.palette(base: rotated, name: "my-colors", surface: white).name, "my-colors")

#assert.eq(type(ambrosia.navigation), function)
#assert.eq(type(ambrosia.navigation-buttons), function)
#assert.eq(ambrosia-navigation(name: "custom-rail", width: 8em).width, 8em)

#assert.eq(type(ambrosia.title-layout), function)
#assert.eq(ambrosia-title-layout(base: "header", logo-columns: 2).logo-columns, 2)
#assert.eq(ambrosia-flavor(title-layout: "plain").title-layout, "plain")
#let cover = ambrosia-title-layout(base: "plain", name: "left-cover")
#assert.eq(ambrosia-title-layout(base: cover, title-shadow: true).alignment, left)
#assert.eq(type(ambrosia.ending-layout), function)
#assert.eq(ambrosia-ending-layout(base: "split", side-width: 40%).side-width, 40%)
#assert.eq(ambrosia-flavor(ending-layout: "cover").ending-layout, "cover")
#assert(ambrosia-title-layout(base: "featured").featured-logo)

#assert.eq(type(ambrosia.credit-card), function)
#assert.eq(ambrosia-navigation(base: "tree").height, auto)
