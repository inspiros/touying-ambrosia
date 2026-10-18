# Navigation

<!-- ambrosia-example: navigation -->
[Editable source](site/examples/navigation.typ).
<!-- /ambrosia-example -->

Choose structural navigation independently of flavor, then enable small PDF buttons and progress indicators as needed. Open [the editable example](../examples/navigation.typ) in your IDE.

```typst
#show: ambrosia-theme.with(
  flavor: "minimal", palette: "ocean",
  navigation: "sidebar", navigation-side: "right",
  navigation-width: 9em, navigation-depth: 2,
  navigation-buttons: true,
  section-progress: true,
)
```

## Structural Choices

| `navigation` | Arrangement |
| --- | --- |
| `auto` (default) | Follow the flavor preset. |
| `none` | Hide structural navigation and recover its reserved space. |
| `"tabs"` | Linked section tabs in a header row. |
| `"dots"` | Miniature logical-slide dots grouped by section. |
| `"context"` | Current section/subsection in a compact header band. |
| `"tree"` | Talk title and current ancestors in two/three thin indented strips. |
| `"panes"` | Two linked lists: sections and subsections of the current section. |
| `"breadcrumbs"` | Linked ancestor path in the title slot. |
| `"sidebar"` | Bounded outline in a reserved left/right column. |
| `"segments"` | Linked section segments with local progress, in a reserved footer row. |

Dewdrop/Darmstadt default to dots, Stargazer to section tabs, Cambridge to the context band, Portico to a right outline column, and Simple/Minimal to none. Flavors keep their own typography and header/footer treatments; palettes supply their colors. See [what a flavor defines](flavors.md). The `portico` flavor pairs its metadata band and body-aligned title with an optionally painted sidebar panel; the same navigator can be used with another flavor.

A local override releases space only on that slide:

```typst
#slide(config: config-store(navigation: none))[A wide figure.]
#slide(config: config-store(navigation: "breadcrumbs"))[Linked context.]
```

A header navigator declares a height budget. Built-in tabs and dots stay inside fixed rows with one-line labels. Crowded section groups window around the current section with linked omission marks; crowded dot groups window around the current logical slide. Animation frames share one dot. Context headings clip long labels to one line with an ellipsis. Changing it adjusts the body top margin relative to the flavor's default. The standard header also keeps a half-em gap before the first body line. A segmented rail reserves a footer row. A sidebar reserves its width plus a gap; title alignment and body content move together. Hiding a sidebar restores the full body width. Buttons and an optional footer logo share one compact row; section progress has its own small footer reservation. Caller foregrounds are preserved.

Custom page headers own their spacing. By default a structural header reservation is managed only for the standard Ambrosia header; `config-store(navigation-header-managed: true)` opts a custom renderer into the height calculation. A custom header must render the desired navigation itself. Native `page.margin: auto` remains under Typst's control, so use explicit margins for structural reservations.

## Sidebar

`sidebar-background: none` is the default, giving a transparent column, including
in Portico. Set it to `auto` to use the flavor's navigation paint, or supply a
solid color.
The sidebar's reserved width stays the same; Portico also retains its label
padding. Label colors adapt for contrast. Per-slide
`config-store(sidebar-background: none)` uses the same override.

`navigation-side: "left" | "right"`, `navigation-width: <length>`, and `navigation-depth: <positive integer>` override the descriptor's defaults. Defaults are right, `9em`, and level two; the gap is `0.8em`. Use `ambrosia-navigation(..., gap: ...)` for a different gap. Widths and spacing scale with presentation text size.

Visible entries link to their original heading. The current entry has an arrow and heavier weight, and ancestors retain the accent. Inactive text uses the flavor's secondary navigation ink. Sidebar paint and both text colors follow the flavor's existing navigation callbacks. With `sidebar-background: auto`, Portico uses a contrasting chrome panel with 0.7 em inner padding; flavors without navigation paint retain a transparent column. Labels have a two-line limit with clipping/ellipsis for unusually long text.

Long outlines first collapse children outside the active section. If still too tall, they show a window around the current entry, keeping its section label for context. Linked `… +N` entries account for omitted headings above/below the current position. The rail never produces another page or shrinks its text indefinitely. Before the first section, it starts at the beginning. Main and appendix scopes are independent.

Title, focus, image, manual section, and ending slides reclaim the sidebar column. A local `config-store(navigation: "sidebar")` can opt an immersive slide back in. The ordinary `new-section-slide` and `outline-slide` retain the selected navigator. Handouts, article output, and notes-only output suppress navigation; second-screen notes keep it confined to the slide half on every side.

## Tabs And Segments

Both show the same **level-one sections**. Their names describe rendering,
not different heading levels:

| Choice | Appearance | Default position | Progress |
| --- | --- | --- | --- |
| `"tabs"` | Linked section labels, highlighting the current section | Header | Current section only |
| `"segments"` | Linked labels with a thin track beneath each | Footer | Logical-slide progress inside every section |

```typst
#show: ambrosia-theme.with(navigation: "segments")
// Move the same segmented view above the title:
#let header-rail = ambrosia-navigation(base: "segments", placement: "header")
```

Animations share one position. Completed sections have full tracks; future
sections have empty tracks. Main talk and appendix have independent scopes.
Equal-width segments keep short section labels readable. Long talks window
around the current section with linked `‹ +N` / `› +N` omission markers. Long
labels clip to one line with an ellipsis.

The segmented view uses a `1.35em` row directly above the footer metadata strip.
The logo/controls row sits above it. It reserves its own body space;
`navigation: none` reclaims that space locally. Header and footer placements
are supported through a descriptor. The built-in rendering needs about `1.35em`.

Global and section progress remain independent. Since the segments already show
section progress, most talks can leave `section-progress: false`. A custom
footer can use the header placement, or render
`extensions.render-navigation-row(self)` and opt into the footer reservation with
`config-store(navigation-footer-managed: true)`. Handout, notes-only, and article
output suppress the navigation; second-screen notes keep it on the slide half.

## Tree Strips

`navigation: "tree"` follows the Antibes/Montpellier family: a linked talk title,
then indented strips for the current section and subsection, with small branch
hooks. It shows only the current path. `panes` also shows neighboring choices;
`breadcrumbs` condenses the path into the slide-title slot.

The talk row uses `config-info(short-title: ...)`, falling back to the full
presentation title. Ordinary level-two slides get two strips (talk + section).
Cambridge's level-three slides get three (talk + section + subsection). The
current slide keeps its ordinary title below the navigator.

`navigation-depth` limits ancestor rows; a limit of one keeps Cambridge to two
strips. By default, `height: auto` reserves `0.75em` per row. A descriptor such as
`ambrosia-navigation(base: "tree", depth: 2, height: 2.4em)` sets an explicit
budget instead. Missing ancestors leave their row empty to keep body positions
stable; labels stay on one line and truncate with an ellipsis. Deeper headings
revealed on later animation frames remain hidden until revealed. Appendix
paths and the talk-row link use appendix scope.

## Two Panes

`navigation: "panes"` follows Beamer's split-navigation family: sections on the
left, and level-two headings within the current section on the right. This
shows neighboring choices as well as the current context. Cambridge's slides
are at level three, so its right pane shows their enclosing subsections. With
level-two slides, that pane shows slide headings.

Each list has an independent window around its active entry. Linked `↑N` / `↓N`
markers account for omitted entries. A section without subsections shows an
empty marker on the right; it does not reuse the previous section's children.
Animation frames keep their active entry, and appendix scope is separate.

The panes reserve a `2.7em` header row and never grow with the outline. This
uses more vertical space than `context` or `breadcrumbs`; it suits teaching
and longer structured talks. Shorter talks often work well with `tabs`, `dots`,
or `segments`. See [the Beamer comparison](beamer-navigation.md).

## Compact Footer Branding

The default footer order, from top to bottom, is:

1. One shared row for optional navigation buttons and the footer logo.
2. The segmented rail, when selected.
3. Author/title/date/slide metadata, then optional progress indicators.

`footer-logo-height` defaults to `1.1em`. The row shares the logo and controls horizontally with small padding; it does
not stack two separate rows. `footer-logo: false` hides the logo. With no logo or buttons, the row
vanishes. A custom larger logo still reserves enough space to keep clear of
content. Custom footer renderers own their own layout.

A translucent logo behind content remains an opt-in branding choice, using the
existing watermark facilities. Compact readable footer branding is the default.

## Breadcrumbs

Breadcrumbs reuse the title slot and replace the ordinary title/subtitle pair there. Explicit slide/outline/bibliography titles are retained as the current breadcrumb. The path follows the visible heading hierarchy, with native PDF links to each ancestor. A long path collapses intermediate ancestors; when labels remain too long, root and current headings receive separate width budgets with ellipses. The current heading cannot be pushed out by a long root label.

A heading revealed later within the current animated slide does not appear in breadcrumbs or the sidebar before its frame. Future sections can still appear in the outline as normal presentation context.

## Progress Within A Section

`section-progress: true` adds a small footer bar and linked `current / total` label. It counts logical slides within the current level-one section, including its divider and supporting slides. Animation frames share one position. The denominator stops at the next section or appendix boundary; appendix sections restart locally. Before a section, no local progress is shown.

The global `progress-bar` remains independent. Special title/focus/image/section/ending slides hide local progress by default; use `config-store(section-progress: true)` to opt in.

## Transparent Buttons

```typst
#show: ambrosia-theme.with(
  navigation-buttons: true, // off by default
  navigation-buttons-opacity: 35%,
  navigation-buttons-actions: ("previous", "section", "outline", "next"),
)
```

The controls sit at the bottom right in the default footer's compact logo/controls row. Custom footers use the overlay fallback above their labels. Their SVG line icons have transparent backgrounds and accessibility descriptions. Disabled destinations are dimmed and unlinked. These are native PDF links, with no JavaScript/history dependency. The viewer must support following links; IDE preview interaction varies.

| Action | Destination |
| --- | --- |
| `first` | First logical slide |
| `previous` | Start of the previous logical slide |
| `section` | Start of the current level-one section |
| `outline` | Nearest preceding outline, or first following outline |
| `next` | Start of the next logical slide |
| `last` | Last logical slide, including appendix |

Focus/image slides hide buttons by default. Handouts, notes-only output, and article output suppress the automatic controls. Use `config-store(navigation-buttons: false)` locally, or `true` to opt an immersive slide in.

For manual placement:

```typst
#ambrosia-navigation-buttons(
  actions: ("first", "outline", "last"), opacity: 60%,
)
```

The scoped form is `ambrosia.navigation-buttons`. Manual placement owns its positioning and visibility; it does not reserve a page margin. `fill:` overrides automatic icon ink.

## Navigation Descriptors

`ambrosia-navigation` (or `ambrosia.navigation`) extends a preset without registering a new global name:

```typst
#let rail = ambrosia-navigation(base: "sidebar", name: "wide-rail",
  width: 10em, gap: 1em, depth: 3, side: "left")
#show: ambrosia-theme.with(navigation: rail)
```

A descriptor has `name`, built-in `kind`, `placement` (`"none"`, `"header"`, `"title"`, `"sidebar"`, `"footer"`), `height`, `width`, `gap`, `side`, `depth`, and `renderer`. Tree alone also accepts `height: auto` for its row-based reservation. `renderer: auto` uses the inherited built-in behavior. A custom `renderer: self => content` receives the resolved theme, including `self.store.navigation-definition`. Header/footer/sidebar renderers are clipped to their declared height/region; title renderers should obey the title slot's bounds. A custom flavor can supply a descriptor through its `navigation` preset. Theme/per-slide choices take priority over it.

## Visual Cross-References

For a clickable thumbnail of another slide inside the body, see [linked slide previews](slide-previews.md). This component works independently of the header/sidebar/footer navigators.
