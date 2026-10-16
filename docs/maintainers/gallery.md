# Gallery Design

The README compares choices one dimension at a time:

- **Layouts:** identical content, branding, font, and `ocean` palette across all seven flavors. A second, collapsible sheet compares their covers.
- **Title layouts:** independent cover compositions with the same metadata and project logo; the featured hierarchy is clearer with multiple logos in the demo.
- **Ending layouts:** four closing compositions with the same message, project branding, and contact address.
- **Navigation:** the same minimal layout/palette with no structural navigator, tabs, dots, context bands, tree strips, two panes, breadcrumbs, segmented rails, and left/right sidebars.
- **Palettes:** twelve compact cards with the same structure, showing background, foreground, accent, and alternate surface.
- **Components:** short, uncluttered cards rendered using the actual public APIs. The credit card uses a fixed 520 × 134 pt canvas with a 0.5 em margin, rather than the taller component frame.
- **Slide helpers:** representative slide types on one sheet.

This covers the available layouts and palettes without enumerating every combination. The generated images have captions outside the slide area, so the comparison does not change the theme geometry.

## Preview A Choice

Open [gallery.typ](../../examples/gallery.typ) in your IDE and edit `view`, `flavor`, or `palette` near the top. `view: "layout"` provides real section/navigation targets, `"cover"` compares the flavor's cover, `"title-layout"` selects a native title composition, and `"palettes"` displays the full palette collection. The [title-layout example](../../examples/title-layouts.typ) compares all covers and has editable logo-placement settings. Component views include `"blocks"`, `"annotations"`, `"citations"`, `"people"`, `"palette-component"`, `"navigation-buttons"`, `"roadmap"`, and `"credits"`. `"navigation"` compares structural choices using optional `navigation` and `side` inputs. `"slides"` demonstrates the main slide helpers.

A separate three-level Tree image uses Cambridge with the same palette, making its talk/section/subsection strips visible at a larger size.

The simple [sample](../../examples/sample.typ) remains a small presentation. The richer [demo](../../examples/demo.typ) retains fictional lab branding.

## README Hero And Template Thumbnail

[hero.typ](artwork/hero.typ) is purpose-built artwork: the project
logo and name beside a fan of real slides in light/dark palettes, with different
layouts and navigation. It shows the same content in every slide rather than a
single cover or a grid of all combinations. The small spectrum suggests palette
seeds beyond the presets.

The three miniature slide images are bundled under `assets/gallery/thumbnail-*`,
so the source compiles immediately in an IDE. `scripts/render-thumbnail.py`
refreshes them from `gallery.typ` and compiles the artwork to
`assets/thumbnail.svg`, used by the README. The logo, text, gradients, and frames
are vector artwork; the three real slide renders are embedded images. It uses the
installed development package; `--package-path` supports an isolated package
tree. This is a separate illustration, not an additional presentation layout.

```sh
python3 scripts/render-thumbnail.py
```

The full preview generator calls this script too. Intermediate renders stay
under `target/thumbnail`.

The manifest instead points to `assets/template-thumbnail.png`: the first page
of the initialized starter, without source edits or input overrides. The same
script creates that lossless PNG. This follows the Universe template-thumbnail
requirement; the collage remains separate project artwork.

## Regenerate

```sh
python3 scripts/render-previews.py --update-pdfs
```

Typst renders the source; Pillow assembles comparison sheets and converts them to WebP. The script writes temporary renders under `target/previews` and committed README artwork under `assets/gallery`. Gallery assets are excluded from the installable runtime package. The optional flag also refreshes `docs/manual.pdf`, `examples/demo.pdf`, and `examples/slide-previews.pdf`. The initialized starter PDF is checked under `target` only.

The slide-preview component image is rendered from its dedicated example after the SVG exporter builds exact target snapshots. Its initial source remains IDE-friendly with placeholders; the generator enables images only for the captured README preview.

The agenda comparison uses [agendas.typ](../../examples/agendas.typ) to pair each overview with its focused section transition: list, cards, and path. The same editable source generates all six images.

The image-caption comparison uses [image-slides.typ](../../examples/image-slides.typ) to keep the photograph constant across bottom/top bands and two corner cards.
