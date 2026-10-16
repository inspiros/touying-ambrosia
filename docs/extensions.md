# Institution Wrappers And Custom Flavors

`ambrosia-theme` accepts a built-in flavor name or an `ambrosia-flavor` descriptor. A descriptor supplies coordinated defaults for geometry, component treatments, and appearance callbacks. Its navigation is a suggestion used by `navigation: auto`; explicit navigation choices own their space reservation. See [the flavor boundary](flavors.md). Palettes own colors, and logo callbacks own branding. Core code never imports an institution wrapper.

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

A wrapper should re-export the core's public API and add its own theme and branding helpers. It should pin the core dependency to a tested version. [`examples/showcase.typ`](../examples/showcase.typ) demonstrates fictional Kyklo branding; the README links to an independently maintained institution wrapper.

## Flavor Descriptors

Use `ambrosia-flavor(base: "minimal", name: "custom", ...)`, or `ambrosia.flavor(...)` with scoped imports. `base` can itself be a descriptor; explicit overrides win. `extensions.flavor-defaults` provides the general geometry defaults without inheriting a named flavor. Built-in names are listed by `extensions.flavor-names`.

The descriptor is validated and normalized during setup, then stored in `self.store.flavor-definition`. Its name is available as `self.store.flavor`. Renderers use `extensions.current-flavor(self)`, so downstream names never need to appear in a core registry. Unknown option names and invalid renderer types raise diagnostics.

The supported descriptor keys are the entries of `extensions.flavor-defaults`. They include slide heading level/margins, title widths/surfaces/text, navigation style/colors, header/logo/footer treatments, block style/shadows, watermark slide kinds, and ending-slide treatment. Color callbacks receive the resolved Touying `self` and should read semantic roles from `self.colors`.

With `header-logo: true`, `header-logo-placement: "title"` (the default)
places an inset mark in the slide-title row. `"corner"` instead reserves a
right-hand column across the header, aligned flush with the page top. Navigation
and title rows share the remaining width. This suits artwork designed to meet
the edge, without overlaying slide content. The collection or custom
`header-logo` callback stays within 30% of page width. Theme
`header-logo: none` hides the mark and releases its column. Flavor
`header-logo-fade: 1.5em` reserves an empty label gutter at the right edge and
fades header paint into the page behind the corner mark. The default `0em`
retains a hard edge. The fade applies to solid page fills; a non-solid page
background retains the ordinary header treatment.

`header-logo-placement: "edge"` also attaches artwork to the top edge, but
reserves label space while painting full-width bands behind it. Only thin
`context`/`tree` navigation switches to the separate corner column and optional
fade. This supports artwork with edge-attached decorative strokes. The callback receives the actual
backing surface in `self.store.logo-background` for adaptive artwork.

`title-layout` sets a native cover composition or descriptor as the flavor's default. Theme `title-layout` and per-slide `title-slide(layout: ...)` override it without defining another flavor. Use [title layouts](title-layouts.md) for common branding placement and typography; reserve `title-renderer` for fully custom composition. Explicit native layout choices also override a custom title renderer.

`ending-layout`, `ambrosia-ending-layout`, and `ending-slide(layout: ...)` use the
same precedence for [closing compositions](ending-layouts.md). Existing custom
ending callbacks retain their positional-body contract. Native endings keep
bodies in ordinary flow for footnotes, citations, and animation frames.

## Renderer Hooks

| Descriptor key | Contract |
| --- | --- |
| `title-renderer` | `(self: none, config: (:), ..info) => rendered slide` |
| `ending-renderer` | `(self: none, config: (:), title: none, body) => rendered slide` |
| `header-renderer`, `footer-renderer` | `self => content` |

`auto` uses the general renderer. Header/footer `none` hides the corresponding decoration. A `none` title renderer produces an empty slide body; a `none` ending renderer renders only the supplied body. Ordinary page configuration still applies. An absent override inherits its base value, so a deliberate `none` stays disabled when extending a descriptor.

Custom title and ending callbacks return an actual slide. Delegate to `extensions.render-title-slide` / `render-ending-slide`, or assemble a layout with `extensions.render-slide(self: self, ...)`. These helpers keep Ambrosia's citation and appendix processing. Keep content bodies positional so Touying can inspect animation markers.

The extension module also supplies `fit-title`, watermark layers, author/affiliation/contact renderers, `call-or-display`, heading queries, and the frame helper. A custom cover should include all title metadata in `fit-title` while keeping decorative backgrounds outside the measured content. `extensions.render-title-slide` already does this.

## Branding And Overrides

Pass `primary-logos` for one or more repeated marks, or use the single
`config-info(logo: content-or-callback, logo-light: ...)` fallback. `logos` holds
opening partners. `title-logo-distribution: "grouped"` opts into left/right
groups; the neutral default is equal. Custom `header-logo` / `logo-focus`
content overrides its automatic strip; use `auto` to restore it. The supported
branding renderers and collection resolvers are available from `extensions`
for custom covers. See [branding](branding.md). A `watermark-logo: fill => SVG bytes` callback provides a monochrome symbol; the core controls size, clipping, and opacity. Choose light/dark variants from the actual surface behind each logo, not only from the palette's `dark` flag.

For SVG transformations, load package-owned files in the wrapper with its own `read(...)`, then pass bytes/XML into `assets.colorize-svg` or `transparentize-svg`. A path string passed to a helper in a different package is resolved there. Caller-owned image/bibliography helpers preserve their original arguments; custom CSL paths should use `path("local.csl")` or bytes.

Apply core defaults, then institution presets, then user theme options/configuration dictionaries, and finally per-slide configuration. Explicit user choices take precedence. Keep legacy branding assets and custom renderers in the institution package, with no copied core implementations.
