# Palettes

`flavor` controls geometry; `palette` controls colors. The twelve presets remain useful starting points: `light`, `ocean`, `forest`, `sand`, `rose`, `slate`, `nocturne`, `nebula`, `midnight`, `evergreen`, `ember`, and `graphite`.

## Compose A Palette

```typst
#let lab-colors = ambrosia-palette(base: "light", name: "My lab", primary: rgb("2b6b51"))
#show: ambrosia-theme.with(palette: lab-colors)
```

The scoped spelling is `ambrosia.palette(...)`. `base` accepts a preset name or another descriptor. `name` identifies the result in diagnostics and showcases; descriptors do not enter a global registry.

`primary` supplies the accent seed. Accent text is adjusted for contrast on the slide and block surfaces, so a very light seed can become darker. The neutral `light` preset derives its alternate surface from that seed. Other presets preserve their curated surfaces.

`rotate: 35deg` rotates the base accent and surface/text hues by that relative angle in OKLCH. Neutral black/white stays neutral. Rotation runs first, then an explicit `primary` and named role overrides apply. Semantic info/success/warning/danger hues retain their meanings unless explicitly overridden.

```typst
#let violet = ambrosia-palette(base: "ocean", name: "Violet", rotate: 65deg)
#let paper = ambrosia.palette(base: lab-colors, name: "Warm paper",
  background: rgb("faf7f0"), surface: rgb("fffdf7"), surface-alt: rgb("e9eee5"))
```

Base roles: `background`, `foreground`, `surface`, `surface-alt`, `muted`, `border`, `chrome`, and `dark` (a boolean). Semantic roles: `info`, `success`, `warning`, `danger`. Advanced roles include `cover`, `on-cover`, `on-accent`, `accent-strong`, `on-accent-strong`, `on-chrome`, and `chrome-muted`. Explicit foreground/on-color overrides are the author's responsibility; accent, muted, and semantic text receive contrast adjustment. Changing `dark` alone does not construct a dark palette: start from a dark preset.

Use palette descriptors for theme-wide changes. Touying's `config-colors(...)` remains available for final or per-slide overrides.

## Show The Actual Colors

<!-- ambrosia-example: palette -->
[Editable source](site/examples/palette.typ).
<!-- /ambrosia-example -->

```typst
#slide(title: [Our visual language])[
  #ambrosia-palette-showcase()
]
```

`ambrosia.palette-showcase(...)` is equivalent. The component shows the current palette name and ten role swatches with hex codes. It reads the current page/background and theme colors, including institution accents and local slide overrides.

Options: `roles: ("primary", "surface", "foreground")`, `columns: 3`, `title: [Custom heading]` (or `none`), and `codes: false`. Automatic columns adapt to available width and text size. It also works inside an Ambrosia block.

Institution-specific palette presets belong to their wrappers. Core presets keep their general meaning in every wrapper.

Try the palette example with a seed (`--input palette=light --input primary=2b6b51`) or relative rotation (`--input palette=ocean --input rotate=65`). The [demo](../examples/demo.typ) includes a showcase in its current palette and an image slide using the Kyklo illustration.
