# Selected Publications

A presenter's publication list is useful in research talks, progress reviews,
and applications. It belongs inside an ordinary `slide`; it does not require a
new slide type or replace the presentation's reference bibliography.

The [editable example](../examples/publications.typ) and its
[BibTeX data](../examples/publications.bib) show a list filtered by author,
newest-first ordering, highlighted author names, and a separate journal list.
The entries are fictional. Open the source in an IDE and edit the identities,
resource file, or entry-type filter to see the result immediately.

## Optional Dependency

Only this example imports `@preview/pergamon:0.8.0`, using the `pergamon`
namespace. Ambrosia's entrypoint, runtime implementation, starter, and ordinary
tests do not import it. Presentations that do not use the recipe acquire no
Pergamon dependency. The first compilation of the example needs the package
and its dependencies available in the normal Typst cache or online.

There is deliberately no Ambrosia wrapper around Pergamon's bibliography API.
Its own options remain available directly, without a second set of names or
version-specific forwarding code. Repeated use can inform a future utility.

## Why Use Pergamon Here?

Typst's native bibliography supports independent reference lists, full entries,
and CSL formatting. Its public API does not expose a per-author rendering
callback with structured given/family name fields. Local text show rules can
highlight known rendered strings, but they cannot reliably distinguish an
author from the same name in a paper title or handle changes in name formatting.
CSL also has no general condition for matching a particular author's identity.

Pergamon exposes parsed author records to a field formatter. The example
customizes only `parsed-author`; paper titles and other fields keep their own
formatting. It uses public Pergamon helpers for name formatting and punctuation.

## Match Identities Before Formatting

The example defines explicit aliases:

```typst
#let presenter-names = (
  (family: "Morgan", given: "Alex"),
  (family: "Morgan", given: "A."),
)
```

Both fields must match the parsed data exactly. Robin Morgan stays unhighlighted;
Alexander Morgan does not match Alex automatically. Include a shortened alias
only when it identifies the intended person in your resource. Prefixes,
diacritics, and spelling variants should be represented explicitly when needed.
This is a comparison against your bibliography data, not automatic identity
resolution.

The formatter compares names before applying `name-format`. Switching between
`"{given} {family}"` and `"{family}, {given}"` therefore does not change which
person is highlighted. Change `highlight-name` to use bold, underline, or another
local treatment. The example keeps names visible instead of using a short
“et al.” list that could hide the presenter.

`is-own-work` filters on the same parsed author records. Additional filters can
select `reference.entry_type == "article"` or `"inproceedings"`; sorting and
other grouping options belong to Pergamon. Divide a long list across slides
explicitly.

## Keep Native Citations Independent

A local `pergamon.refsection` contains each publication list. `show-all: true`
prints the selected works without artificial citations; `title: none` leaves the
slide title in charge. `read("publications.bib")` stays at the call site so paths
resolve correctly in IDE previews and CLI builds. `eval-mode: none` displays
bibliographic text literally.

Native `cite`, `@key`, `footcite`, and Ambrosia bibliography slides remain
available outside those lists. Pergamon labels and citation state are independent
of native CSL labels; Ambrosia's compact citation-marker settings do not restyle
them. Avoid wildcard-importing Pergamon over the native citation functions.

The name/field formatter can also be reused in an ordinary report or thesis;
only the enclosing slide composition is presentation-specific.

## Optional Verification

```sh
python3 tests/check_publications.py
```

These checks explicitly opt into Pergamon. They verify the selected identities,
actual bold name spans, excluded works, entry-type filtering, animation frames,
and coexistence with native footnotes on light/dark slides. They require Poppler's
`pdftotext` and `pdftohtml`, plus the optional Typst packages.
