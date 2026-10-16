# Development

Use Typst 0.15+, Python 3.11+, and Poppler (`pdftotext`). Disposable sources belong in `develop/` and generated files in `target/`; both are ignored.

```sh
python3 tests/run.py
python3 -m unittest discover -s tests -p 'test_*.py'
python3 scripts/render-previews.py --update-pdfs
```

The runner installs an isolated preview copy for template/example imports, then checks all seven flavors with twelve palettes and a French case. It verifies nested animations, citations, multiple bibliographies, notes, appendix counters, fitted titles/footers/outlines, and watermarks. Agenda treatments additionally cover cards/path links, appendix overviews, dense fallback, empty outlines, and animated introductions. Path geometry checks tie node centers to text cap heights and verify connector centers/ends with wrapped labels, serif/sans fonts, and single entries. General tests live here; downstream wrappers validate their branded integration and custom covers against a pinned core.

The extension fixtures check independent flavor names, title/header/footer/ending callbacks, inherited explicit `none`, and useful diagnostics. Installed starter checks copy the whole template directory into a separate document root, including its logo helpers and bibliography. Downstream integration checks should compile consumers outside both packages, covering caller-relative SVG/BibTeX/CSL paths and shared citation identity.

The installer honors manifest exclusions. The installer defaults to `@local`. An explicit `--namespace preview` creates a development override; tests and renderers keep that override in isolated package directories. Package copying and exclusion behavior are checked by `tests/test_install.py`.

For live development, install with `python3 scripts/install.py --link --reinstall` and import `@local/touying-ambrosia:0.1.0`. The package directory becomes a symlink to this checkout, so source/asset edits also reach institution wrappers immediately. Use an explicit `--namespace preview --data-dir target/package-data` to test the published imports in checkout examples without replacing a persistent preview installation. Omit `--link` to test a release snapshot with manifest exclusions. Reinstalling between linked and copied modes safely replaces the package entry without following its symlink.

The starter/gallery uses the project-brand helper (Ambrosia logo only), while the fuller demo opts into fictional institutions. Preview generation refreshes orthogonal layout/cover comparisons, palette cards, component cards, and slide helper previews, the selected manual/demo/slide-preview PDFs, a temporary starter check, and the project thumbnail. A 63-case flavor/navigation matrix retains each flavor's native heading level and checks painted labels, header/body clearance, animation-stable dots, and appendix scope. Segmented-navigation tests cover footer/header placement, frame-stable progress, appendix, omitted sections, restored space, buttons/logos, and four notes positions. The slide-preview example includes bundled snapshots so ordinary IDE compilation displays thumbnails; export tests also check embedded image output. Navigation regressions verify native link destinations across animation frames, appendix sections, foreground composition, local visibility, handouts, and speaker-note output. Tree-strip regressions cover two/three rows, links, reveals, empty branches, local hiding, and notes modes; credit cards cover all palettes and packaged QR artwork. Inline-citation tests cover native cite/ref forms and explicit CSL overrides.

See [the gallery design](gallery.md) for sources and generated artwork. Footer-logo regressions fill the body to its boundary and verify that the logo starts below it, including local/global hiding and several text sizes.

Roadmap regressions check custom units, fractional periods, proportional PDF coordinates, grouped tasks and queued detail drawers, boundary markers, light/dark palettes, whole-diagram reveals, height fitting, and useful diagnostics for invalid ranges.

Structural-navigation checks exercise configurable header modes, left/right sidebars, long outline windows, native breadcrumb/outline destinations, restored body margins, frame-stable section progress, appendix scope, custom descriptors, output modes, and all four second-screen directions.

Linked-slide-preview checks run the optional SVG exporter, verify forward/backward links and last-frame selection, and compare bibliography/heading/logical-slide counts before and after images are enabled. Exact thumbnails add no live queryable slide content.

Branded examples use the same package import as their template helpers. Mixing a relative core import and a package import creates separate Typst module identities; even an identical function loaded twice will not compare equal in layout ownership checks. Installed-example tests cover navigation and collaboration through their actual branded helper.

Two-pane tests cover independent section/subsection windows, animation-stable highlighting, empty branches, native links, local space recovery, and appendix scope. Footer checks cover compact shared logo/controls rows above segmented navigation.

Regenerate the optional credit QR with `python3 scripts/generate-credit-qr.py`
(requires `reportlab` for development only). It preserves a four-module quiet
zone and medium error correction; consumers compile the bundled SVG directly.
The same script accepts `--url` / `--output` for institution wrappers.

## Navigation Layout Contract

Per-slide configuration merges before output-mode policy and space reservation.
The renderer normalizes page edges, reserves footer accessories/progress, then
resolves structural navigation once. Explicit edges preserve all four notes-screen
arrangements. Custom headers/footers own their spacing unless they opt into the
managed reservation contract. All navigators share scoped, visible, deduplicated
heading and logical-slide queries.

Corner branding can use a `header-logo-fade` gutter. Built-in labels reserve this
space before the header paint fades into a solid page background; custom header
navigation renderers receive the reduced region as well. Hidden marks release
both the column and fade. Wrapper regressions cover their geometry and color
adaptation; neutral flavors retain a zero-length fade by default.

For document families beyond slides, see [component architecture](architecture.md).

## A Compiled Manual

`docs/manual.typ` is a ten-page guide with a curated API reference generated by
Tidy 0.4.3. The custom `docs/manual-style.typ` owns its typography, tables, links,
and layout. Selected public functions use Tidy's inline `/// -> type | type`
parameter comments and return types. The manual asserts that all displayed
parameters have types, and reads their names/defaults from implementation source.
Tidy remains a documentation dependency; runtime imports do not load it.

Open the source in an IDE using the repository as document root, or run:

```sh
python3 scripts/render-manual.py
# Rebuild slide artwork after changing its shared snippets or theme:
python3 scripts/render-manual.py --refresh-previews
```

Ordinary compilation reads local source and bundled snapshots, so no installed
Ambrosia package or Python step is necessary. Tidy and the runtime dependencies
must be available as usual. For the CLI directly, use
`typst compile --root . docs/manual.typ docs/manual.pdf`.

The palette example is evaluated live. Whole slide examples are compiled
separately from `docs/examples/slides.typ`; their source snippets are shared with
the manual. Refreshing them needs the development package installed, or an
explicit `--package-path` pointing to an isolated package tree. Snapshots use
144-ppi PNG to preserve OKLab mixes when embedded; no presentation show rule,
counter, or heading query runs inside the book. The six images under
`docs/previews` are maintained artwork, not temporary outputs. The compiled manual is committed as `docs/manual.pdf`; selected example PDFs
are committed beside their sources. Disposable page renders and starter checks
belong under `target`.

Image-caption regressions cover native placement, asymmetric margins, text sizes,
light/dark panels, working readable links, height/width diagnostics, and notes
and handout output. Sankey-recipe checks exercise standalone native pages,
proportional weights, bounded bars, cycles, invalid weights and skipped columns.

## Development API Renames

| Previous choice | Current choice |
| --- | --- |
| `"sections"` | `"tabs"` |
| `"chapters"` | `"segments"` |
| `"split"` | `"context"` |

The old names are removed. `panes` is the new two-list selector; `context`
keeps the former current-section/current-subsection display. Preset defaults
are updated, so Stargazer and Cambridge retain their original arrangements.

The earlier boolean `navigator` is now `navigation-buttons`, with corresponding
`navigation-buttons-opacity` and `navigation-buttons-actions`. The manual
helper is `ambrosia-navigation-buttons` / `ambrosia.navigation-buttons`.


