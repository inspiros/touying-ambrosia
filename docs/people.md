# Authors, Affiliations, And Footers

Both `config-info(...)` and `ambrosia.config-info(...)` declare Ambrosia's
collaborator fields explicitly for IDE completion. They extend Touying's
metadata configuration and accept additional named fields. Only supplied fields
are emitted, so later calls can update one field without clearing the others;
`none` explicitly clears a field. `authors`/`emails` take precedence over their
singular counterparts. `authors: none` hides authors; `institutions: auto` uses the singular
`institution` field.

Simple `author:`, `institution:`, and `email:` metadata still describe a single presenter. Lists of author content and institution content also work. For explicit associations and personal emails, use records:

```typst
#show: ambrosia-theme.with(
  config-info(
    title: [A collaborative presentation],
    authors: (
      (name: [Alice Researcher], short: [A. Researcher],
        affiliations: ("lab", "cnrs"), email: "alice@unicaen.fr"),
      (name: [Bob Collaborator], affiliations: ("partner",), email: "bob@example.org"),
    ),
    institutions: (
      lab: [institution, Université de Caen Normandie],
      cnrs: (name: [CNRS], address: [France]),
      partner: [Partner University],
    ),
    emails: ("project@example.org",),
    short-author: [Researcher and Collaborator],
    short-title: [Collaborative research],
  ),
)
```

`authors` accepts content/strings or records with `name`, optional `short`, `affiliations`, and `email`/`emails`. Affiliation IDs must exist. `institutions` accepts an ordered dictionary of IDs to content/records, or an array of records with `id` and `name`. Institution records can include an `address`. Superscripts link to the institution on the same title page. Their numbering follows institution order; names and IDs are not inferred.

Personal emails sit under their authors. Shared emails appear below the institution list; repeated personal addresses are excluded from that shared list. String addresses are clickable and can wrap after punctuation without changing their mailto destination. Content-valued email fields retain their supplied formatting.

`ending-slide` reuses shared contacts when supplied, otherwise the authors' personal addresses. Do not repeat those addresses manually in its body.

Names align at the top of each row. The author grid selects one to three columns based on available width and font size, so a narrow custom cover uses fewer columns. Four authors use a balanced two-by-two arrangement when space allows; five, eight, or twelve flow into further rows. Partial final rows keep the chosen alignment instead of leaving names stranded in the first cells of a full-width grid. Set `author-columns: 1`, `2`, or `3` in the theme when needed. All metadata belongs to the title slide's fitted unit. Very dense content raises the same clear title-fit diagnostic; large consortia can use a collective author on the opening and an ordinary contributor slide.

See [the collaboration example](../examples/collaboration.typ).

## Footer Policy

Keep footer labels shorter than cover metadata. `config-info(short-author: ...)` and `short-title:` are the preferred controls.

Without `short-author`, the footer uses author `short` fields (or names): one author directly, two joined with an ampersand, and the first followed by “et al.” for larger lists. This does not abbreviate or guess anyone's surname.

The default footer reserves the actual width of the date and complete logical slide count, including three-digit totals and Roman appendix counters. Remaining fields share the available width. Author/title fields stay on one line, shrink down to `footer-min-scale: 80%`, then use a clipped ellipsis if still too long. This applies equally to explicit `short-author`/`short-title` and derived labels. Dates and counts are kept complete.

The date defaults to `none`: supply `config-info(date: datetime.today())` or date content to display it. A `title-slide(date: ...)` override is local to that cover and does not add a date to other slides' footers. Override `footer-ac` to render different footer content or hide a globally configured date.

Explicit `footer-a-columns` overrides the automatic width allocation. Existing `footer-aa` through `footer-ad` callbacks remain available for advanced layouts. If very large absolute custom content is supplied, provide a shorter footer representation.

## Appendix Slide Numbers

Appendix slide counters restart independently from the main talk. Configure them
on the theme (the same options are available on `greyc-theme`):

```typst
#show: ambrosia-theme.with(
  appendix-numbering: "1",
  appendix-total: true,
)
// Main talk: 1 / 7 … 7 / 7. Appendix: 1 / 3 … 3 / 3.
#show: appendix
```

`appendix-numbering` accepts a native Typst numbering pattern, a function, or
`none`. The default is `"i"`; `appendix-total` defaults to `false`.

| Pattern | Appendix labels |
| --- | --- |
| `"i"` | i, ii, iii |
| `"1"` | 1, 2, 3 |
| `"A"` | A, B, C |
| `"S1"` | S1, S2, S3 |
| `none` | Hidden, regardless of `appendix-total` |

With `appendix-total: true`, string patterns format each side of the fraction,
e.g. `"S1"` gives `S1 / S3`. A function receives the local appendix number;
with totals enabled, it receives both number and appendix total. For example,
`n => [A#n]` produces A1, A2, …; `(n, total) => [A#n / A#total]` includes a total.
The string `"A1"` is a two-level numbering pattern, so use the function for a
literal A prefix.

Animation frames share one logical number. Explicit `backup-slide` calls keep
the preceding number and do not increase the total. Main-talk totals continue
to exclude the appendix. Per-slide `config-store(appendix-numbering: ...,
appendix-total: ...)` can override the display without changing counters.

For continuous numbering across the entire deck, override the footer instead:

```typst
#show: ambrosia-theme.with(
  footer-ad: self => context [
    #utils.slide-counter.get().first() / #utils.slide-counter.final().first()
  ],
)
```

This counts the main talk and appendix together, for example `1 / 10` through
`10 / 10`. A custom `footer-ad` owns the number display and takes precedence over
the appendix options. The upstream-style `9 / 7` is also possible by using
`utils.last-slide-number` as denominator, but it intentionally mixes the full
sequence with the main-talk total.

`appendix.with(numbering: "A.1")` controls **heading numbering**, independently
of these slide-number settings. See the [editable example](../examples/appendix.typ).

## Linked Affiliation Markers

Set `affiliation-numbering: "*"` in the theme for native footnote symbols, `"a"` for letters, `"I"` for Roman numerals, or `n => [#sym.star#n]` for custom content. The default is `"1"`. This can also be set in `config-info(affiliation-numbering: ...)` or overridden on a particular `title-slide`.

Automatic author markers link to their institutions on that physical cover page, including when a cover is repeated or scaled to fit. `ambrosia-affiliation("lab")` (or `ambrosia.affiliation("lab")`) inserts a linked superscript elsewhere, using configured institution IDs and the closest preceding cover's marker, or the first following cover. Shared emails keep their normal mailto links.

When unrelated metadata reuses institution IDs, set `config-info(affiliation-scope: "project-a")` and use `ambrosia-affiliation("lab", scope: "project-a")` as needed. Scopes separate link targets; no global counters or generated labels are required.

Set `title-logo-height` in the theme to control native title logo cells (default `1.8em`); the project-branded starter uses `3.2em` for Ambrosia's square emblem. A title-layout descriptor can override it with `logo-height`. [Title layouts](title-layouts.md) place a complete ordered logo list above the title, in a top band, or beside the metadata, without requiring lab/institution roles.

## Footer Logo

`footer-logo: auto` follows the flavor preset: Cambridge and Darmstadt enable the `primary-logos` collection (or the single `config-info(logo: ...)` fallback) in the compact row shared with navigation buttons, above any segmented rail. `footer-logo: false` hides it; `true` enables it in another flavor. With no logo or buttons, the row vanishes. `footer-logo-height` defaults to `1.1em`; a larger custom logo still reserves enough space to avoid content.

The logo is part of the footer's normal layout, and the body reserves its height. It therefore cannot cover ordinary content or footnotes. `slide(config: config-store(footer-logo: false))[...]` disables it locally and restores the space. `footer: none` also removes the reservation. Custom footer renderers manage their own layout and margins.
