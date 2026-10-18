# Metadata And Citation Recipes

Read only the relevant recipe. These target Ambrosia 0.1.0.

## Collaborators And Affiliations

Replace the starter's `config-info(...)` argument with:

```typst
config-info(
  title: [A Collaborative Talk],
  authors: (
    (name: [Alex Researcher], affiliations: ("lab",), email: "alex@example.org"),
    (name: [Sam Collaborator], affiliations: ("partner",)),
  ),
  institutions: (
    lab: [Example Laboratory],
    partner: [Partner Institute],
  ),
  short-author: [Researcher & Collaborator],
  short-title: [Collaborative Talk],
)
```

Set `affiliation-numbering: "*"` on the theme for symbol markers; `"1"` is
the default. Markers link to institution entries. Authors flow into balanced
rows; `author-columns` on the theme can fix one to three columns. Large groups
may need a separate contributor slide. Short footer labels shrink and then
truncate; avoid using full affiliation lists there. See [people](https://inspiros.github.io/touying-ambrosia/v0.1.0/people.html).

## Shared Citation Labels

Put real bibliography records in `references.bib` beside the deck. For example,
this complete BibLaTeX record can be used to test the snippet:

```bib
@book{knuth84,
  author = {Knuth, Donald E.},
  title = {The TeXbook},
  year = {1984},
  publisher = {Addison-Wesley}
}
```

With the starter's import and theme setup, add:

```typst
#slide(title: [A Reference])[
  An ordinary reference @knuth84.
  A full reference at the foot of the slide #footcite(<knuth84>).
]
#bibliography-slide("references.bib")
```

Native `cite` / `@key`, `footcite`, and the default bibliography share compact
author-year markers. `footcite` deduplicates its full note across the talk;
later slides link back to the first note. Set `footcite-once: false` on the
theme to repeat the note on each cited slide. Ordinary footnotes remain
separate. Use `hidden-bibliography` instead of `bibliography-slide` when no
visible reference slide is wanted.

For multiple bibliographies with overlapping keys, pair
`footcite(<key>, scope: "methods")` with
`bibliography-slide("methods.bib", scope: "methods", group: none)`.
For native citation styles set both `cite-marker: "native"` and
`bibliography-marker: "native"` on the theme, then select the bibliography
style normally. See [citations](https://inspiros.github.io/touying-ambrosia/v0.1.0/citations.html)
for scope routing and marker overrides. Do not invent publication data.
