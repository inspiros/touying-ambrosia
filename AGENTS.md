# Repository Guide

This guide is for reviewing or maintaining **touying-ambrosia**, the neutral
presentation core. Start with [CONTRIBUTING.md](CONTRIBUTING.md) for setup and
the [maintainer index](docs/maintainers/README.md) for implementation notes.
Presentation users have a separate [API index](docs/api.md) and
[authoring skill](skills/touying-ambrosia/SKILL.md); that skill is not a package
maintenance workflow.

## Code Map

| Area | Responsibility |
| --- | --- |
| `src/lib.typ`, `src/ambrosia.typ` | Prefixed/global exports and scoped authoring API. Keep their intended counterparts consistent. |
| `src/theme/base.typ`, `src/configs.typ` | Theme setup and metadata configuration. |
| `src/theme/` | Slide rendering, chrome, fitting, output modes, and appendix behavior. |
| `src/components/`, `src/components/context.typ` | Reusable components and Touying's raw-wrapper protocol for nested reveals. |
| `src/palettes.typ`, `src/theme/flavors.typ`, `src/navigation.typ` | Independent color, geometry, and navigation descriptors. |
| `src/extensions.typ` | Supported interface for institution wrappers. |
| `template/` | Complete initialized user project, with Ambrosia's own branding. |
| `examples/`, `assets/` | Demonstrations and artwork; fictional branding is repository-only. |
| `tests/`, `scripts/` | Regression checks, copied-package installs, documentation/artwork builds. |
| `docs/` | User guides and manual; developer notes are under `docs/maintainers/`. |

## Review Focus

- Flavor, palette, navigation, and branding are independent. Preserve explicit
  user and per-slide overrides, including meaningful `none` values.
- Components participate in Touying's reveal parser. Replacing raw wrappers
  with opaque `context` rendering can hide nested `pause` commands.
- Main and appendix counters, outlines, and navigation have separate scopes.
  Animation frames share a logical slide; appendix bodies must remain visible.
- Logo variants follow their actual backing surface. Caller-owned images keep
  caller-relative paths; resolve package-owned assets before passing them across
  package boundaries.
- A document must not mix relative and package imports of the same core.
  Typst treats them as distinct modules, affecting function-identity checks.
- Linked development installs expose the checkout. Copied installs must honor
  exclusions; fictional logos, docs, agent files, and build tools are not runtime
  dependencies. Preserve vendored license notices.
- Sankey/publication helpers are optional examples. `ambrosia-kit` is a future
  proposal, not an implemented dependency. See [architecture](docs/maintainers/architecture.md).

## Validation

Use Typst 0.15+, Python 3.11+, and Poppler. Run commands from this root:

```sh
python3 -m unittest discover -s tests -p 'test_*.py'
python3 tests/ci.py
```

The second is the bounded CI suite. `python3 tests/run.py` runs the exhaustive
matrix; choose relevant fixtures for a focused change. For documentation-only
work, check links and rebuild the affected manual/site rather than rerunning
every visual combination. `python3 scripts/build-docs.py` validates the website
and its compiled examples; it needs mdBook 0.5.4. Report what was actually run.

Use `develop/` for disposable sources and `target/` for output. Keep maintained
examples editable in an IDE. Regenerate committed PDFs/gallery images only
when their inputs change. See [artwork](docs/maintainers/gallery.md).

## Cross-Repository And Release Work

The sibling `touying-greyc-ambrosia` owns institution branding and the legacy
cover. General fixes belong here; changes to the core theme signature require
the wrapper's signature-sync check. The wrapper's live development alias and
its published exact-version dependency serve different purposes.

Follow [release preparation](docs/maintainers/releasing.md) for source tags and
trimmed submission contents. The initial joint submission adds core `0.1.0`
and GREYC `0.2.0`; the published GREYC `0.1.0` directory stays untouched.
