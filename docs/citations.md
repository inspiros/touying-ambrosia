# Citations

Native `cite` / `@key`, `footcite`, and bibliography slides share compact labels
such as **[Knuth1984a]** by default. Typst handles author/year disambiguation and
bibliography links.

<!-- ambrosia-example: citations -->
[Editable source](site/examples/citations.typ).
<!-- /ambrosia-example -->

## Footnote Citations

`footcite(<key>)` adds a full APA reference at the foot of its first logical
slide. Repeated calls share that entry, including across animation frames;
later slides link back to it. Set `footcite-once: false` on the theme to repeat
the full entry on each cited slide.

`footcite-marker` sets the default marker; `marker:` overrides one call:

| Marker | Result |
| --- | --- |
| `"author-year"` | `[Knuth1984a]`, the default. |
| `"number"` | A stable presentation-wide footcite ID. |
| `"key"` | Literal bibliography key, prefixed by scope when supplied. |
| `"local"` | Ordinary inline citation plus a slide-local superscript. |
| Content, e.g. `[Knuth84]` | A custom bracketed marker. |

Numeric footcite IDs are independent of native bibliography numbering. Ordinary
footnotes keep their own numbering; non-local citation markers do not consume it.

| Option | Default / Use |
| --- | --- |
| `foot-style` | `"apa"`; `auto` uses the assigned bibliography's style. |
| `inline` | `auto` includes an inline citation only in local mode. |
| `cite-style`, `form` | Style and form of that optional inline citation. |
| `supplement` | Native citation supplement. |
| `label` | A label for linking to the full note. |

Custom CSL can be supplied as `path("custom.csl")` or bytes. Note-producing CSL
styles should be used with ordinary citations rather than nested in `footcite`.

## Native Styles

To use a conventional citation/bibliography pair:

```typst
#show: ambrosia-theme.with(
  cite-marker: "native",
  bibliography-marker: "native",
)
#bibliography-slide("references.bib", style: "apa")
```

An explicit `cite(..., style: "apa")` always wins. An explicit bibliography
`style` also selects native markers unless `marker` is supplied. Matching
`"author-year"` markers require Ambrosia's bundled CSL; numeric/key/custom
footcite markers are separate conventions.

Use `hidden-bibliography("references.bib")` to register sources without a visible
reference slide.

## Multiple Bibliographies

Give independent sources a `scope` when their keys overlap:

```typst
#footcite(<shared>, scope: "methods")
#hidden-bibliography("methods.bib", scope: "methods", group: none)

#footcite(<shared>, scope: "results")
#bibliography-slide("results.bib", scope: "results", group: none)
```

Scopes select both the marker and full entry. Native `target` and `group`
options are also supported; use either `scope` or `target`, not both. Unscoped
citations keep Typst's normal routing.

[Editable citation example](../examples/utilities.typ)
