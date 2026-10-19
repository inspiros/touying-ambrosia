# Development

Use Typst 0.15+, Python 3.11+, and Poppler (`pdftotext`, `pdfinfo`). Keep
disposable sources in `develop/` and generated output in `target/`; both are
ignored. Start with the [repository map](../../AGENTS.md) and
[checkout setup](../../CONTRIBUTING.md).

## Choose The Relevant Checks

| Command | Coverage |
| --- | --- |
| `python3 -m unittest discover -s tests -p 'test_*.py'` | Installer copy/link transitions, safe replacement, and exclusions. |
| `python3 tests/ci.py` | Bounded GitHub Actions suite: all flavors in light/dark palettes, metadata, citations, appendix, components, selected navigation combinations, SVG previews, notes exports, manual, and installed starters. |
| `python3 tests/run.py` | Exhaustive palette/flavor and navigation matrices plus focused layout/component regressions. |
| `python3 tests/check_speaker_notes.py --bundle` | Audience PDF, overlay-scoped sidecars, split/notes-only pages, and experimental PDF/sidecar bundle. |
| `python3 tests/check_publications.py` | Optional standalone Pergamon publication recipe. |

The runners create their own isolated `@preview` copies. They do not publish or
replace the user's persistent package cache. CI uses Typst 0.15.1 and read-only
repository permissions; it does not rebuild committed artwork. Run the bounded
suite for broad implementation changes and the relevant fixtures for a focused
fix. Documentation-only changes normally need link/build checks.

Regression families cover nested reveals, bibliography identity and scopes,
visible appendix content and frozen main totals, dense title/outline fitting,
footer bounds, contrast, and caller-relative assets. Agenda-summary tests check
metadata-only bodies, absent-panel geometry, local/theme typography, reveals,
and appendix isolation across list/cards/path styles. Navigation checks cover
reserved regions, visible scoped targets, animation-stable positions, local
overrides, appendix isolation, and output modes. Component tests cover native
geometry, nesting, semantic colors, and SVG shadows. Installed starter checks
include the companion branding helpers and bibliography.

Roadmaps test fractional/custom units and fitting. Slide-preview checks export
exact SVGs and verify forward/backward frame destinations without replaying live
headings, counters, or bibliography entries. The Sankey and publication fixtures
exercise optional recipes, not exported APIs. See `tests/run.py` for individual
checks; test names and behavior are more durable than recorded matrix counts.

## Package Installs And Module Identity

The installer defaults to `@local`. Use `--link` for live checkout edits and
omit it for copied release contents that honor the manifest exclusions. For
published imports in examples, use an isolated override:

```sh
python3 scripts/install.py --namespace preview --link --reinstall --data-dir target/package-data
typst compile --root . --package-path target/package-data/typst/packages examples/sample.typ target/sample.pdf
```

An institution wrapper follows the checkout only when its pinned `@preview`
alias points here; the GREYC installer creates that alias. Installing this core
under `@local` alone does not replace a wrapper's `@preview` dependency.
Reinstalling safely replaces a package link without following it into the source.

Keep a single module identity per deck. A relative core import and an equivalent
package import are distinct Typst modules; their functions do not compare equal
in layout-ownership checks. Branded examples and their helpers use consistent
package imports. Copied consumers should be tested outside either checkout.

## Navigation Layout Contract

Per-slide configuration merges before output-mode policy and space reservation.
The renderer normalizes page edges, reserves footer accessories/progress, then
resolves structural navigation. Explicit edges preserve all four notes-screen
arrangements. Custom headers/footers own their spacing unless they opt into
managed reservations. Heading and slide queries are visible, scoped, and
deduplicated across animation frames.

`header-logo-fade` reserves labels before fading header paint into a solid page
background; custom header navigation also receives the reduced region. Hidden
marks release the column and fade. Wrapper tests cover GREYC's traits geometry;
neutral flavors use a zero-length fade by default.

## Documentation And Artwork

`docs/manual.typ` is the concise PDF guide. Its Tidy 0.4.3 reference reads typed
`///` docstrings, parameter names, and defaults from selected public functions.
Tidy is a documentation dependency, not a runtime import. The custom
`manual-style.typ` owns the page design.

```sh
python3 scripts/render-manual.py
python3 scripts/render-manual.py --refresh-previews
python3 scripts/build-docs.py
```

Ordinary manual compilation uses relative source imports and bundled slide PNGs;
the usual Typst dependencies must be available. Refreshing slide snapshots from
`docs/examples/slides.typ` uses package imports, so supply an explicit
`--package-path` when working before publication. No live slide queries run
inside the book. See the [website guide](website.md) for mdBook and live preview.

The starter/gallery uses Ambrosia's project logo. The richer demo uses fictional
artwork through repository-only example helpers. Those SVGs are excluded from
runtime installs. The linked-preview example bundles SVG snapshots for immediate
IDE use; regenerate them after editing target slides.

`python3 scripts/render-previews.py --update-pdfs` refreshes maintained artwork
and the committed `docs/manual.pdf`, `examples/demo.pdf`, and
`examples/slide-previews.pdf`. It needs Pillow. Other output stays in `target/`.
See [gallery design](gallery.md) for the separate README hero and manifest PNG.
`scripts/generate-credit-qr.py` needs ReportLab only when regenerating QR assets;
consumers use the bundled SVG directly.

Future poster/thesis extraction is a [design proposal](architecture.md), not
part of the current dependency graph.
