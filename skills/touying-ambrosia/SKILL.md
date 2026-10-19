---
name: touying-ambrosia
description: Create, edit, and troubleshoot Typst presentations using touying-ambrosia or an institution wrapper around it. Use when this theme is requested or already imported, for its configuration, slide helpers, components, and layout checks.
---

# Touying Ambrosia

Author editable presentations with Ambrosia's public API. This skill targets
**touying-ambrosia 0.1.0**, **Typst 0.15+**, and **Touying 0.8.0**. It supplies
theme-specific guidance; research, source conversion, and other export formats
remain separate tasks. Preserve the user's content, branding, and chosen theme.

## Start Or Continue A Deck

- Inspect the existing entrypoint and imports first. Keep its namespace and
  version; do not replace an institutional wrapper with the neutral core.
  For another API version, confirm signatures in its matching documentation
  rather than downgrading the package to match this skill.
- For a new core deck, copy [assets/starter.typ](assets/starter.typ) into the
  presentation project and edit its defaults. The starter needs no companion
  images, bibliography, or Python scripts.
- Import `@preview/touying-ambrosia:0.1.0`, which imports Touying itself. A
  configured `@local` installation is also valid. Do not add a second Touying
  version or edit package caches to fix an error.
- Prefer exported helpers. Old names `tblock`, `framed-tblock`, and
  `footnote-cite` are not part of this API. Use `ambrosia-block` and `footcite`.
- For parameters beyond the recipes here, consult the matching
  [API index](https://inspiros.github.io/touying-ambrosia/v0.1.0/api.html)
  and linked guide before introducing a new option. If unavailable, inspect an
  installed package's public signatures rather than guessing.

## Configure The Right Layer

- `ambrosia-theme.with(...)`: flavor, palette, navigation, logos, typography,
  title/ending layouts. Flavor is geometry, palette is color, navigation is
  independent. `navigation: auto` follows the flavor; `none` removes it.
- `config-info(...)`: metadata and short footer labels. Pass it as a positional
  argument to the theme. Read [references/recipes.md](references/recipes.md)
  when adding collaborators, affiliations, or bibliography entries.
- `config-common(...)`: Touying behavior and output modes. For example,
  `new-section-slide-fn: none` disables automatic section transitions.
- `slide(config: config-store(...))`: local component overrides. A local
  `config-store(navigation: none)` reclaims navigator space for a wide figure.
- Use palette/layout descriptors or `.with(...)` presets for repeated choices.
  Custom header/footer renderers take responsibility for their own spacing.
- Opacity options are percentages, such as `navigation-buttons-opacity: 35%`
  and `watermark-opacity: 5.5%`; plain numbers are rejected.

The neutral core starts without branding. Supply caller-owned images through
`primary-logos` for repeated marks and `logos` for opening partners. Use
`title-layout: "header"` for one shared top row, or `"featured"` for prominent
primary marks. Logo callbacks should choose dark/light variants using the
actual surface in `self.store.logo-background`, not just the palette name.
See [branding](https://inspiros.github.io/touying-ambrosia/v0.1.0/branding.html)
for callback examples.

## Compose Slides

- `=` starts a section; `==` starts a slide in most flavors. Cambridge uses
  `===`. Explicit `slide(title: [...])[...]` works in every flavor.
- Use ordinary slides, native `grid`, figures, and tables for routine content.
  Two positional slide bodies create columns. Use specialized helpers when
  their geometry or counting behavior is wanted:

  | Helper | Use |
  | --- | --- |
  | `title-slide`, `ending-slide` | Opening metadata and closing content; local `layout:` overrides the preset. |
  | `outline-slide`, `new-section-slide` | Fitted overview and current-section agenda. |
  | `section-slide` | Simple counted divider. |
  | `focus-slide`, `backup-slide` | Emphasis or interlude with frozen slide counter. |
  | `image-slide` | Full-page image with optional caption/credit placement. |
  | `bibliography-slide` | Visible bibliography. |

- `ambrosia-block` separates geometry (`style`) from semantic color (`kind`).
  Nest blocks when useful; use `ambrosia-badge`, `alert`, `muted`, and `subtle`
  for smaller annotations. Do not replace Typst's native `block` or `box`.
- Keep `pause` and other animation commands visible to Touying's parser;
  avoid hiding them inside opaque `context` wrappers.
- `outline-slide` and automatic section dividers share `agenda-style`
  (`"list"`, `"cards"`, or `"path"`) and `agenda-text-size`. Text between a `=`
  heading and its first slide becomes that section's summary on its divider.
- `#show: appendix` starts visible, separately numbered backup material and
  freezes the main total. Appendix numbering defaults to local Roman numerals;
  `appendix-numbering: "1", appendix-total: true` selects decimal local totals.

## Check The Result

When a CLI is available, compile from the presentation project root:

```sh
typst compile --root . main.typ main.pdf
```

Use the project's actual entrypoint/output paths. Inspect changed slides and
dense covers in an IDE preview or rendered pages. If PNG inspection is useful:

```sh
typst compile --root . --format png --ppi 110 main.typ 'slide-{0p}.png'
```

Check crowded metadata, footers, tables/captions, dark logo contrast, navigation
space, animation frames, and appendix visibility. Split dense content or adjust
its local layout before shrinking the whole presentation. Preserve the normal
18pt default unless the user wants a different size. Report compilation or
visual checks that the environment could not perform.

## Optional Features And Limits

- Touying's re-exported `speaker-note[...]` is private metadata by default.
  Presenter tools can consume notes through their supported workflows; pdfpc
  is one option and requires a matching exported sidecar. A split slide/notes
  PDF visibly contains both halves in an ordinary viewer. Follow the [notes guide](https://inspiros.github.io/touying-ambrosia/v0.1.0/speaker-notes.html)
  when presenter notes are requested.
- `ambrosia-slide-preview` links an existing thumbnail to a slide. It cannot
  capture another slide in the same compilation. Automated SVG snapshots need
  a separate Python export; see [linked previews](https://inspiros.github.io/touying-ambrosia/v0.1.0/slide-previews.html).
- Roadmaps are supported components. Sankey diagrams and selected-publication
  highlighting are independent example recipes, not exported Ambrosia APIs.
- For institutional wrappers, retain their documented branding parameters and
  use the shared Ambrosia components. See [extensions](https://inspiros.github.io/touying-ambrosia/v0.1.0/extensions.html).
