# Create Your Own Theme

Compose an `ambrosia-flavor` descriptor and wrap the core theme with your own
defaults. Keep colors in a palette and assets in the wrapper:

```typst
#import "@preview/touying-ambrosia:0.1.0" as core
#let lab-flavor = core.ambrosia-flavor(
  base: "minimal", name: "my-lab", top-margin: 3em,
  block-style: "poster",
  title-background: self => self.colors.surface-alt,
)
#let lab-theme(..args, body) = {
  let options = (flavor: lab-flavor, palette: "ocean") + args.named()
  show: core.ambrosia-theme.with(..options, ..args.pos())
  body
}
```

Re-export the public API and pin a tested core version. Put your defaults
first so that the user's options and configurations override them; per-slide
overrides still apply last. New flavor names need no core registry changes.

## Descriptor Options

`extensions.flavor-defaults` lists supported keys; `extensions.flavor-names`
lists built-ins. Renderers access the resolved descriptor with
`extensions.current-flavor(self)`. Color callbacks read semantic `self.colors`.

| Options | Control |
| --- | --- |
| Heading level, margins, spacing | Slide geometry. |
| Title/ending layout, surfaces, typography | Opening and closing presets. |
| Header, footer, logo treatment | Ordinary page chrome. |
| Navigation preset and color callbacks | Suggested navigator and paint. |
| Block style/shadows, watermark kinds | Component defaults. |

With `header-logo: true`, `header-logo-placement` accepts `"title"` (inset title
row), `"corner"` (a top-aligned reserved column), or `"edge"` (full-width bands
behind edge-attached artwork). Thin context/tree bands use the separate corner
column in edge mode. `header-logo-fade` optionally softens the paint boundary.
`header-logo: none` hides the mark and releases its space.

## Renderer Hooks

| Key | Contract |
| --- | --- |
| `title-renderer` | `(self: none, config: (:), ..info) => slide` |
| `ending-renderer` | `(self: none, config: (:), title: none, body) => slide` |
| `header-renderer`, `footer-renderer` | `self => content` |

`auto` uses the general renderer. Header/footer `none` hides their decoration;
`none` title/ending renderers produce an empty/supplied body respectively.

Prefer [native title](title-layouts.md) and [ending](ending-layouts.md) descriptors
for common compositions. Custom callbacks must return an actual slide:
`extensions.render-title-slide`, `render-ending-slide`, or `render-slide` retain
citation/appendix handling. Keep bodies positional for Touying's reveal parser.
A custom cover should fit all metadata with `extensions.fit-title`.

## Assets

Logo callbacks receive `self.store.logo-background`; choose variants using
`palettes.prefer-light(...)`. `watermark-logo: fill => SVG bytes` supplies a
monochrome symbol. Read wrapper-owned SVGs locally before passing bytes/XML to
`assets.colorize-svg` or `assets.transparentize-svg`.

For a complete institution wrapper, see
[touying-greyc-ambrosia](https://github.com/inspiros/touying-greyc-ambrosia).
The [fictional branding example](../examples/showcase.typ) is a smaller starting point.
