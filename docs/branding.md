# Primary And Partner Logos

`primary-logos` identifies the presenter or joint project. It follows the
flavor's ordinary header/footer placement, and is used by native section,
focus, and ending slides. `logos` is the partner collection, normally shown
only on the opening. Neither collection requires an institution type.

```typst
#show: ambrosia-theme.with(
  primary-logos: (image("lab.svg"), image("project.svg")),
  logos: (image("university.svg"), image("funder.svg")),
  title-logo-distribution: "grouped",
  config-info(title: [A Joint Presentation], author: [Presenter]),
)
```

`primary-logos: auto` (the default) uses `config-info(logo: ...)`. An explicit
collection replaces that fallback; `none` or `()` removes it. Arrays preserve
order; dictionaries use their values in insertion order. The core has no
built-in marks. See the [editable example](../examples/branding.typ).

Ordinary header/footer rows give the primary collection at most 30% of their
available width. The strip shrinks together when necessary, retaining aspect
ratios and space for the title/navigation. Flavors with no ordinary logo
placement retain that choice; `footer-logo: true` opts into a reserved footer
row. Custom `header-logo` / `logo-focus` content overrides the automatic strip
at that placement; `auto` restores it.

## Horizontal Title Rows

The default `title-logo-distribution: "equal"` keeps equally bounded cells.
`"grouped"` puts primary marks against the left edge and partners against the
right, with flexible space between. Groups retain their internal order; a
missing group leaves the other against its own edge. Both groups share one
bounded row and shrink together if crowded.

This applies to above/below rows and header bands. Split panels retain their
vertical grid. The featured layout promotes all primary marks to its large
region; partners keep a smaller centered equal-cell grid, independently of
grouped distribution. A descriptor overrides the theme:

```typst
#title-slide(layout: ambrosia-title-layout(base: "header",
  logos-distribution: "equal"))
```

`title-logos` / per-slide `logos` replaces the complete opening collection.
Since a flat replacement has no role metadata, its first entry becomes primary
for grouped/featured rendering. To feature several marks, use `primary-logos`
and leave `title-logos: auto`. `ending-logos` remains a complete local override;
its automatic value collects all primary marks.

## Adaptive Artwork

Entries can be native image content or `self => content` callbacks. Callbacks
receive the actual surface as `self.store.logo-background`, including dark
headers on light slides. Select variants with `palettes.prefer-light(...)`.
Keep caller-relative paths by passing native `image(...)` content, or read
wrapper-owned assets in the wrapper itself.
