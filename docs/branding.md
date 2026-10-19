# Branding

The core starts unbranded. Supply native images or `self => content` callbacks:

```typst
#show: ambrosia-theme.with(
  primary-logos: (image("lab.svg"), image("project.svg")),
  logos: (image("university.svg"),),
  title-logo-distribution: "grouped",
)
```

| Option | Role |
| --- | --- |
| `primary-logos` | Repeated marks in the flavor's ordinary logo positions. |
| `logos` | Opening partners. |
| `title-logos` | Complete replacement for the opening collection. |
| `ending-logos` | Complete replacement for closing marks. |

`primary-logos: auto` falls back to `config-info(logo: ...)`.
`none` or `()` removes a collection. Entries keep their order and proportions;
ordinary header/footer strips use at most 30% of the available width.

## Title Rows

`title-logo-distribution: "equal"` (default) gives bounded equal cells.
`"grouped"` places primary marks left and partners right in horizontal rows.
The featured layout gives primaries their own larger region and centers partners;
split panels retain their vertical grid.

An explicit flat `title-logos` list has no role metadata: its first entry is
primary in grouped/featured layouts. Use `primary-logos` to feature several marks.
See [title layouts](title-layouts.md) for sizing and placement.

## Adapt To Dark Surfaces

A callback receives the actual backing surface in
`self.store.logo-background`. Use `palettes.prefer-light(...)` to select a light
or dark asset; a dark header can occur in a light palette.

Caller-owned `image(...)` paths stay relative to the caller. An institution
wrapper should read its own assets before passing bytes or content to the core.
Custom `header-logo` / `logo-focus` content replaces the automatic strip at that
position; `auto` restores it.

## Watermarks

A watermark is a large, faint symbol behind title, outline, and section slides.
The core has none of its own. Give `watermark-logo` a function that receives the
ink color and returns SVG data:

```typst
#let symbol = read("symbol.svg")
#show: ambrosia-theme.with(
  watermark-logo: fill => symbol.replace("#000000", fill.to-hex()),
  watermark: true, watermark-height: 40%, watermark-opacity: 8%,
)
```

| Option | Default / Effect |
| --- | --- |
| `watermark` | `auto` follows the flavor (Simple, Minimal, and Dewdrop use it); `true` covers title, outline, and section slides; `false` turns it off. |
| `watermark-height` | `50%` of the page height. |
| `watermark-opacity` | `5.5%`. Like every Ambrosia opacity, it is a percentage. |

The ink follows the slide's actual background. Individual slides accept
`watermark: true` or `false`, including `ending-slide`, and blocks can carry a
smaller mark with `ambrosia-block(watermark: true)`.

[Editable branding](../examples/branding.typ) · [Footer logos](people.md#footer-labels-and-logos)
