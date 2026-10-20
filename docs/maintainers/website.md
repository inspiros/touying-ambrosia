# Documentation Website

The public book is built with **mdBook 0.5.4**, **Python 3.11+**, and
**Typst 0.15+**. It reuses `docs/*.md`; `docs/SUMMARY.md` controls the chapter
order. Only listed public chapters and their referenced images enter the site.
Maintainer notes, tests, and implementation files are not copied into it.

## Preview Locally

Install mdBook once, either from its [official releases](https://github.com/rust-lang/mdBook/releases/tag/v0.5.4)
or with Cargo:

```sh
cargo install mdbook --version 0.5.4 --locked
```

From the repository root:

```sh
python3 scripts/build-docs.py --serve
```

Open <http://127.0.0.1:8000/>. The server watches the original Markdown guides,
website theme, examples, and package code. It updates staged chapters and lets
mdBook reload the browser. `Ctrl+C` stops the server. Use `--port 8018` for
another port, or `--mdbook /path/to/mdbook` for a downloaded executable.
The default host is local-only (`127.0.0.1`).

A one-time build needs no running server:

```sh
python3 scripts/build-docs.py
python3 scripts/build-docs.py --pages
```

The first writes `target/book/`. The second also prepares `target/site/`,
containing the current guide at the root and at `/v0.1.0/`. All output, isolated
package aliases, and cached renders live in gitignored `target/`. No system
package installation is modified. This build needs no third-party Python modules.

## Enable GitHub Pages

1. Commit and push the website files to `master` in `inspiros/touying-ambrosia`.
2. Open the repository's **Settings → Pages**. Under **Build and deployment**,
   choose **GitHub Actions** as the source. No `gh-pages` branch is needed.
3. Open **Actions → Documentation** and select **Run workflow** on `master`.
   This is also how to retry the initial deployment if the first push ran before
   Pages was enabled. If GitHub requests environment approval, approve the
   `github-pages` deployment there.
4. After both `build` and `deploy` are green, open
   <https://inspiros.github.io/touying-ambrosia/> or the versioned guide at
   <https://inspiros.github.io/touying-ambrosia/v0.1.0/>.

Changes to public Markdown guides, `docs/site/`, assets, package code, the
manifest, or the website builder/installer rebuild and deploy automatically
from `master`. Maintainer notes, compiled PDFs, and unrelated repository changes
do not trigger a build. Pull requests targeting `master` use the same path
filters to validate the book without deploying. Manual runs remain available. The workflow pins mdBook's download checksum and
the GitHub Actions. It uses GitHub's Pages deployment token, not a personal token.

## Add A Code/Output Pair

Keep one complete, IDE-friendly `.typ` source in `docs/site/examples/`. Mark the
part shown beside the output with these comments:

```typst
// ANCHOR: example
#ambrosia-block(style: "stripe")[One useful idea.]
// ANCHOR_END: example
```

Imports and theme setup can remain outside those markers. The downloaded full
source includes them. Examples should use a fixed/omitted date so previews are
reproducible. Register the source, selected physical page/animation frame, alt
text, and context in `docs/site/examples.toml`. List any companion files in
`resources`; they are linked next to the full source download.

Insert this into the relevant Markdown guide:

```md
<!-- ambrosia-example: my-example -->
[Editable source](site/examples/my-example.typ).
<!-- /ambrosia-example -->
```

GitHub shows the fallback source link. The website replaces the complete region
with copyable, highlighted source and the actual compiled PNG. Code pairs use
the same panel and syntax colors as standalone code. All slide/gallery previews
open in a native dialog: Escape closes it; Actual Size enables full-resolution
inspection without navigating away. A build fails if
the source does not compile, its requested page is missing, a registered example
is unused, or a local HTML link/image/anchor is broken. Typst examples render
again when package code or example inputs change; ordinary prose/CSS edits reuse
the cache. Nothing executes in the reader's browser.

## Links And Versions

Links between chapters stay within the website. Links to the PDF manual,
repository examples, or source files use the package's version tag. Referenced
images are copied locally; no gallery CDN is needed. README links can point to
the versioned guide while the concise PDF remains an alternative.

The current site documents API `0.1.0`; documentation corrections can be deployed
without moving its source release tag or changing runtime files. Before the
next package version, extend the deployment to retain the older book alongside
the new one. The initial workflow publishes only the current version; its
versioned path alone does not archive earlier deployments. Do not silently
overwrite old API documentation with a new API under the old path.

Keep the PDF manual concise. The Markdown guides are the detailed public source;
there is no second set of prose to synchronize for the website. Website files
already live under the excluded `docs/`, `scripts/`, and `.github/` directories,
so the prepared Universe submission only needs its README link updated.

## Agent Guidance

`skills/touying-ambrosia/` is a portable consumer skill, distributed from GitHub
and excluded from the Typst package. `docs/agent-skill.md` explains installation
and invocation, with a release-tagged source link and an optional pinned
installation URL. Update those references alongside the supported API version.

Keep `SKILL.md` focused on authoring decks. The starter and optional recipes
must use exported APIs; update their supported version and documentation links
alongside API changes. `tests/ci.py` compiles the starter against an isolated
package install. Compile changed recipes too, and check installation in a
disposable project when changing the bundle structure. Do not add maintenance
or release instructions to the consumer skill.
