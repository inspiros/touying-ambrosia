# Title Layouts

Choose a cover composition independently of flavor and palette. Most decks need
a preset and a few adjustments; a custom renderer is for artwork or composition
that does not follow the native layouts. Open the [editable example](../examples/title-layouts.typ)
in your IDE to compare the choices.

| `title-layout` | Composition |
| --- | --- |
| `auto` | Follow the flavor's title layout or custom title renderer. |
| `"stacked"` | Centered logo row, title panel, and author metadata. The general default. |
| `"header"` | Logos in a full-width top band; centered title and metadata below. |
| `"split"` | Left-aligned title/metadata beside a quiet logo panel. |
| `"plain"` | Left-aligned logo row and typography, without a title panel. |
| `"featured"` | First logo prominently above the title; remaining logos in a smaller row below the metadata. |
| `"cover"` | Full-page color or photograph, contrasting text, and no ordinary page chrome. |

```typst
#show: ambrosia-theme.with(
  title-layout: "header", palette: "ocean",
  config-info(title: [My Presentation], author: [Presenter]),
)
#title-slide()
// Override only this opening; later slides retain their ordinary flavor.
#title-slide(layout: "split", subtitle: [A Different Opening])
```

The header layout replaces the ordinary navigation/header on the title slide.
It reserves the logo band's height, including padding and additional logo rows,
and hides the repeated footer logo. The normal footer metadata remains. With no
title logos, the band vanishes. Other presets retain the flavor's ordinary title
chrome; a structural sidebar is hidden on all covers.

## One Logo Or Many

`title-logos` is a complete ordered collection of content or `self => content`
callbacks. There are no required lab/institution/partner roles. A single
university logo is simply a one-element array:

```typst
#show: ambrosia-theme.with(
  title-layout: "header",
  title-logos: (image("university.svg"),),
  config-info(title: [My Presentation], author: [Presenter]),
)
#title-slide()
// Complete local replacement, in this order:
#title-slide(logos: (image("first.svg"), image("second.svg")))
#title-slide(logos: none) // hide title branding and reclaim its space
```

The default `title-logos: auto` collects `primary-logos` followed by the
theme's `logos` collection. Automatic primary logos fall back to
`config-info(logo: ...)`. This keeps institution wrapper defaults useful;
explicit `title-logos` or per-slide `logos` replaces that whole collection.
`title-logos: none` hides it globally. No logo is duplicated automatically in a
second title region. Ordinary header/footer/focus branding still uses its own
settings and `primary-logos` (or the single `config-info(logo: ...)` fallback).

The default equal distribution means equal cell allocation, not identical visible ink area: aspect
ratios and whitespace inside the artwork still matter. Images are contained
without stretching. Logos share bounded cells and keep their proportions. `logo-columns: auto`
uses up to six columns for balanced rows, or one in the split panel; larger collections
wrap. Set an explicit count for larger or wider artwork. A callback receives `self.store.logo-background`, the actual surface
behind the image, for choosing a light/dark variant. Recoloring arbitrary SVGs
is left to the owner of that artwork.

For separate primary/partner rows, use `title-logo-distribution: "grouped"`.
The core defaults to equal cells; institution wrappers can preset grouping.
See [branding](branding.md) for repeated primary collections and alignment.

## Feature Primary Logos

`title-layout: "featured"` promotes the primary collection (or the first entry
of an explicit flat title list). It gets its own `3em` region above the title. The remaining logos
share a `1.4em` row below the metadata. No institution type is inferred, and no
entry is duplicated. With one logo there is no partner row; with no logos all
branding space vanishes.

Since the primary collection already has its own region, the partner row uses
ordinary centered cells even when `title-logo-distribution` is `"grouped"`.
An explicit descriptor `logos-align` still controls alignment inside those cells.

The automatic list starts with `primary-logos`, followed by `logos`.
This makes the preset useful for the common main-brand-plus-partners case;
[the demo](../examples/demo.typ) features Kyklo above its four partners. An
explicit `title-logos` list can feature any mark by putting it first. Ordinary
headers and footers keep their independent branding settings.

```typst
#let branded-opening = ambrosia-title-layout(base: "featured",
  featured-logo-height: 3em, logo-height: 1.5em)
#show: ambrosia-theme.with(title-layout: branded-opening)
```

## Color And Photograph Covers

`"cover"` uses the palette's `cover` / `on-cover` pair. A photograph is optional:

```typst
#let photograph = ambrosia-title-layout(base: "cover",
  background-image: image("photograph.webp", width: 100%, height: 100%, fit: "cover"),
  background-overlay: self => self.colors.cover.transparentize(35%),
)
#title-slide(layout: photograph)
```

Native image content keeps paths relative to the caller. The overlay controls
contrast; the core does not analyze the photograph. Decoration stays outside
title fitting and follows the slide in notes and second-screen output.

## Adjust A Preset

```typst
#let university-cover = ambrosia-title-layout(
  base: "header", name: "university-cover",
  logos-align: right, logo-height: 1.8em, logo-columns: 2,
  header-background: self => self.colors.chrome,
  title-shadow: false, title-radius: 0em,
)
#show: ambrosia-theme.with(title-layout: university-cover)
```

The scoped constructor is `ambrosia.title-layout`. A descriptor can extend another
descriptor. The supported keys are:

| Options | Purpose |
| --- | --- |
| `composition` | `"centered"` or `"split"`. |
| `alignment` | `left`, `center`, or `right` for title/metadata. |
| `logos-placement` | `"above"`, `"below"`, `"header"`, `"side"` (split only), or `"none"`. |
| `logos-align`, `logo-height`, `logo-columns`, `logo-gap` | Alignment, maximum cell height, columns, and spacing. |
| `logos-distribution` | `auto` inherits theme `title-logo-distribution`; `"equal"` uses equal cells, `"grouped"` aligns primaries left and partners right in horizontal rows. |
| `featured-logo`, `featured-logo-height` | Promote the primary collection into its own larger region. |
| `header-background`, `header-inset` | Top band's fill and vertical padding; `none` gives a transparent band. |
| `title-background`, `title-text`, `title-shadow`, `title-width` | `auto` inherits the flavor treatment; explicit values override it. |
| `title-size`, `subtitle-size`, `title-inset`, `title-radius`, `gap` | Typography and spacing, using `em` by default. |
| `side-width`, `side-background` | Split panel's width ratio and fill. |
| `immersive`, `page-background`, `foreground` | Page chrome, fill, and metadata ink for cover compositions. |
| `background-image`, `background-overlay` | Optional native image content/callback and a color/gradient/callback overlay. |

Fill/ink options accept ordinary values or `self => value` callbacks. Explicit
solid title fills choose contrasting ink unless `title-text` is supplied.
`logo-height: auto` follows the theme's `title-logo-height`. The header preset
uses a compact `1.8em`; set `auto` there to inherit the theme's value instead.

All body metadata and in-body logos form one fitted unit. `title-fit` and
`title-min-scale` continue to apply; `title-slide(fit: ..., min-scale: ...)`
overrides them locally. The header's logo band keeps its configured size while
the title/metadata fit the remaining area. Excessively dense content raises an
actionable diagnostic instead of adding an overflow page.

## Precedence And Custom Covers

A per-slide `layout` overrides theme `title-layout`, which overrides the flavor
preset. Per-slide `config-store(title-layout: ..., title-logos: ...)` is also
supported. Explicit native layout choices bypass a flavor's custom title
renderer; leaving the choices at `auto` retains it. A fully bespoke institutional
cover is a useful reason to supply a custom renderer.

A flavor can set `title-layout: "header"` or a descriptor as its default.
`title-renderer` remains available for fully custom layouts; see
[renderer hooks](extensions.md). [Ending layouts](ending-layouts.md) use the same
preset, descriptor, and local-override pattern.
