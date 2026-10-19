# Release Preparation

Keep two different artifacts: the complete source release in the personal
repository, and a small package submission derived from that exact release.
Development installs default to `@local`; tests and artwork use isolated,
explicit `@preview` overrides. Neither operation publishes a package.

## Source Repository

The core release tag is `v0.1.0`. The GREYC wrapper has its own repository and
release tag, `v0.2.0`; its dependency stays exactly
`@preview/touying-ambrosia:0.1.0`. Versions describe each package's API and do not
need to match. The wrapper's breaking API changes warrant a minor release,
rather than a `0.1.1` patch.

Keep source, tests, scripts, example assets, user and maintainer documentation,
and selected compiled PDFs in the personal repository. Relative README links
remain readable on GitHub. Commit these inspection copies beside their sources:

- `docs/manual.pdf`, built by `python3 scripts/render-manual.py`.
- `examples/demo.pdf` and `examples/slide-previews.pdf`.

`python3 scripts/render-previews.py --update-pdfs` refreshes all three after
refreshing the gallery and bundled slide-preview snapshots. Keep temporary
renders and the starter validation PDF under `target`. Do not commit a
`template/template.pdf`: it duplicates the examples and is not starter content.
Fictional affiliation branding lives in `examples/showcase.typ` and
`examples/logo-data.typ`, outside the initialized template. The latter reads
the repository's `assets/logos/` files directly; those fictional marks are
excluded from package installs. The installed `template/logo-data.typ` only
handles Ambrosia's own project mark.

After final testing and wording review, commit the complete source, push the
repository, and create/push its version tag. Tags must exist before links in a
submitted package depend on them. During review of an unmerged submission,
an explicitly authorized correction may refresh an unpublished source tag;
keep the staged files and pinned links consistent. Once published, tags and
package versions are immutable: changes require a new release.
The manual's PDF links target the manifest version's source tag.

## Submission Copy

Prepare the core and wrapper in one pull request, in two new directories:

| Package | Version | Source tag |
| --- | --- | --- |
| `touying-ambrosia` | `0.1.0` | `v0.1.0` |
| `touying-greyc-ambrosia` | `0.2.0` | `v0.2.0` |

Their destination is `packages/preview/<name>/<version>` inside the packages
checkout. Leave the already published GREYC `0.1.0` directory untouched.

The trimmed copy contains:

- `typst.toml`, `README.md`, `LICENSE`, and any third-party license notices.
- All `src/` implementation and runtime assets referenced by it or the starter.
- The starter files under `template/`, including its helper modules and references.
- The manifest's `assets/template-thumbnail.webp`.

Do not copy `.git`, tests, development scripts, docs, examples, generated PDFs,
caches, README gallery/hero artwork, or the example photograph `assets/kyklo.webp`.
Repository guidance (`AGENTS.md`, `CLAUDE.md`) and the consumer `skills/` bundle
also stay in the source repository and are excluded from package installs.
Omit fictional lab and partner logos; only Ambrosia's own light/dark project
marks belong in the core's `assets/logos/` submission. The required
initialized-template thumbnail is the one exception to omitting documentation
artwork.

Rewrite the submission README, without changing the personal repository README:

- Relative documentation, example, PDF, and contributing links become GitHub
  `blob/<tag>/...` URLs in the matching source repository.
- Markdown images and HTML `src` / `srcset` artwork use raw URLs at that tag.
- Links already pointing at a project's `master` or `main` branch, including standalone
  helper downloads, must also be pinned. Cross-project links use the other
  project's version: GREYC documentation points to core `v0.1.0`.
- Keep `LICENSE` and runtime source links local where those files are included;
  anchors and external service links such as Universe badges stay unchanged.
- Check links in the shipped starter README as well; it already pins the helper
  and guide to the core release tag.

Manifest `exclude` controls downloads, not what is committed to the packages
repository. The thumbnail is required in the submission but automatically
omitted from downloads; our installer also omits it. Keep README and licenses
in the bundle. No exporter or submission should run before final source review.

## Submission Checks

1. Check version/import consistency, entrypoints, minimum compiler, SPDX license,
   category, short description, and README examples. No font files may be bundled.
2. Keep upstream notices for copied code. `src/vendor/LICENSE-shadowed` retains
   the original MIT notice. All distributed non-code assets need appropriate
   redistribution terms; institutional marks are not automatically MIT licensed.
3. Verify the thumbnail is a PNG or lossless WebP of a page from the unmodified,
   freshly initialized starter: longer edge at least 1080 px, size below 3 MiB.
   `scripts/render-thumbnail.py` produces that PNG and a separate SVG README hero.
4. Build both trimmed versions in an isolated package tree under `target`, with
   actual copied files and no symlinks. Initialize both starters into separate
   client roots and compile them using only that tree and normal dependencies.
5. Run the regression suites, validate README URLs against the pushed tags, then
   review the proposed package contents. The final files must be copies, never
   Git submodules. A single pull request can contain the new core and its wrapper
   update; explain the dependency in the PR description.

The official [submission rules](https://github.com/typst/packages/blob/main/docs/README.md),
[manifest and thumbnail requirements](https://github.com/typst/packages/blob/main/docs/manifest.md),
[documentation guidance](https://github.com/typst/packages/blob/main/docs/documentation.md),
[asset requirements](https://github.com/typst/packages/blob/main/docs/resources.md),
[licensing rules](https://github.com/typst/packages/blob/main/docs/licensing.md),
and [file inclusion guidance](https://github.com/typst/packages/blob/main/docs/tips.md)
are the final reference. Do not assume an older local packages checkout contains
the latest rules. This guide records preparation, not publication approval.
