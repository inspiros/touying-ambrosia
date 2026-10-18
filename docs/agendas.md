# Agendas And Section Transitions

`outline-slide` and the automatic `new-section-slide` share three agenda styles.
The default stays `"list"`; palette, flavor, and navigation remain independent.

| `style` | Best use | Behavior |
| --- | --- | --- |
| `"list"` | A compact overview or a long talk | Linked hierarchy with logical slide numbers. |
| `"cards"` | A short talk with distinct parts | Up to two columns of section cards; children stay inside their section. The current section receives a stronger border and surface. |
| `"path"` | An ordered argument or revisiting progress | A vertical rail with linked nodes centered on each heading’s first line; the current section has a filled node. |

```typst
#show: ambrosia-theme.with(
  agenda-style: "cards", // overview AND automatic section dividers
  config-common(new-section-slide-fn: new-section-slide.with(neighbors: 1)),
  config-info(title: [A Clear Argument], author: [Presenter]),
)
#outline-slide(depth: 1)
// ... ordinary headings and content ...
#outline-slide(style: "path", title: [Where We Have Been])
```

A helper's `style:` overrides `agenda-style`; `auto` follows the theme. To mix
an opening card overview with compact section dividers, use
`outline-slide(style: "cards")` and leave the theme default alone. Alternatively,
configure `new-section-slide.with(style: "path")` for path transitions only.
See the [editable example](../examples/agendas.typ), which includes section
introductions, a later overview, and appendix material.

## Leaders Between Titles And Slide Numbers

Set `outline-fill` on the theme, or `fill` on one `outline-slide` or
`new-section-slide`, to insert leaders between each heading and its logical
slide number:

```typst
#show: ambrosia-theme.with(outline-fill: repeat[.])
#outline-slide()                    // inherits the theme
#outline-slide(fill: none)          // hide leaders for this overview
#outline-slide(fill: repeat[–])      // custom repeated content
```

The core default is `outline-fill: none`. The GREYC wrapper defaults to
`repeat[.]`; set `outline-fill: none` there for an open layout. `fill: auto`
inherits the theme, and `none` disables it locally. The setting applies to list,
card, and path entries, including automatic section transitions and quiet
neighbor rows. Wrapped titles put their leaders and number on the final line;
selection, fitting, and native links are preserved.

These agendas render custom fitted rows, so a native
`set outline.entry(fill: ...)` rule does not style them. Such rules still apply
to native Typst outlines.

## Selection And Fitting

`depth`, `level`, and `numbered` have the same meaning in every style. Headings
retain their own numbering; the smaller trailing number is a logical slide
number, with Roman numerals in the appendix. Animation frames share one entry.
Both overview and divider links follow the current main/appendix scope.

Overview cards form at most two columns. More than six root sections or eighteen
eligible headings automatically selects the compact list. This threshold uses
the requested heading depth, before anything is collapsed or omitted, so long
talks never become an unexplained grid of tiny cards. Cards and paths use the
same measured fitting and omission accounting as the list.

An overview first removes excess depth, then shows an explicitly marked window
if necessary. `start: 15` begins a forward window at the fifteenth eligible entry;
`overflow: "error"` requests a diagnostic instead. Each linked `… +N` accounts
for excluded headings and jumps to the first omitted heading. No style creates
extra pages implicitly.

Automatic dividers keep the current section and its children at the horizon.
`neighbors: 0`, `1` (default), or `2` adds that many quiet root headings on either
side. Neighbors use the compact row treatment in all styles. When space is
scarce, neighbors disappear before deeper children collapse or become a marked
window. A section card remains one column.

Introductions and extra overview content share the measured region. The theme's
`outline-min-scale` defaults to `80%`; each helper can override it with
`min-scale:`. Text and relative geometry shrink together. An individual heading
or introduction that cannot fit at this limit raises a useful diagnostic.

These treatments change the agenda body only. The manual `section-slide` stays
a simple title divider, while `navigation` continues to control page chrome.

Path nodes follow measured first-line cap heights, including enlarged section headings and wrapped titles. Connectors share one horizontal center and run only between node edges; a single entry has no connector.
