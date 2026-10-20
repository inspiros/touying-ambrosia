# Contributing To Touying Ambrosia

These instructions are for working on the package. For presentation authoring,
use the [user documentation](docs/README.md).

For a code-review entry point and source map, read [AGENTS.md](AGENTS.md).

Use Typst 0.15+, Python 3.11+, and Poppler for the checks. Artwork scripts also
use Pillow (`python3 -m pip install Pillow`).

## Checkout Setup

```sh
git clone https://github.com/inspiros/touying-ambrosia
cd touying-ambrosia
python3 scripts/install.py --link --reinstall
```

The installer defaults to the **local** namespace: import
`@local/touying-ambrosia:0.1.0` to use that checkout. `--link` makes source/asset
changes visible without reinstalling; omit it for a copied runtime snapshot.
Restart the IDE language server if it retains an old package view.

Published examples and templates deliberately use `@preview`. To test them
against this checkout, create an explicit override in an isolated directory:

```sh
python3 scripts/install.py --namespace preview --link --reinstall --data-dir target/package-data
typst compile --root . --package-path target/package-data/typst/packages examples/sample.typ target/sample.pdf
```

Tests and artwork generators manage their own isolated preview overrides.

```sh
python3 tests/ci.py  # bounded checks used by GitHub Actions
python3 tests/run.py  # exhaustive local matrix
python3 -m unittest discover -s tests -p 'test_*.py'
python3 scripts/render-previews.py --update-pdfs
python3 scripts/build-docs.py --serve  # searchable manual with live reload
```

The Checks workflow runs only when a `v*` release tag is pushed. Run the relevant
checks locally before committing ordinary changes.

General regression tests live here; institution wrappers only need their branding/integration checks. Disposable experiments belong in `develop/`, generated output in `target/`. The selected release PDFs are exceptions: `docs/manual.pdf`, `examples/demo.pdf`, and `examples/slide-previews.pdf` are committed beside their sources. See [development](docs/maintainers/development.md), [release preparation](docs/maintainers/releasing.md), and [CHANGELOG](CHANGELOG.md).

The [component architecture notes](docs/maintainers/architecture.md) describe a future shared
native renderer layer for poster/thesis themes, with thin document-specific adapters.

The [maintainer index](docs/maintainers/README.md) collects implementation,
artwork, architecture, and release notes.

See [the website guide](docs/maintainers/website.md) for mdBook installation,
GitHub Pages activation, and adding compiled code/output examples.
