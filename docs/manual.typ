// Open in a Typst IDE with the repository as document root.
// CLI: typst compile --root . docs/manual.typ docs/manual.pdf
// Slide snapshots are bundled; no Python step is needed to read this manual.
#import "../src/lib.typ" as core
#import "manual-style.typ": *
#import "examples/snippets.typ" as snippets
#show: manual

#grid(columns: (1fr, auto), align: horizon,
  [#text(size: 0.8em, tracking: 0.12em, fill: muted)[A SHORT MANUAL]
   #v(0.4em)
   #text(size: 2.9em, weight: "bold", fill: accent)[Touying Ambrosia]
   #v(0.4em)
   One presentation, many flavors.],
  image("../assets/logos/touying-ambrosia.svg", height: 5.2em),
)
#v(1em)
Ambrosia is an institution-neutral theme for Typst and Touying. Choose geometry,
colors, branding, and navigation separately. Ordinary Typst content and Touying
animations remain the authoring tools.

== Your First Deck
#pair(snippets.start, "start")
Most flavors use level-two headings for slides; Cambridge uses level three.
Level-one headings start sections and insert fitted agenda dividers. Explicit
`slide` calls are useful for custom compositions in any flavor:
#source(```typst
= Introduction
== A Clear Result
One useful claim, with its evidence.
#pause
A qualification on the next animation frame.
#slide(title: [Two Perspectives])[First column.][Second column.]
#ending-slide(title: [Questions?])[]
```)

== Find Your Way
#grid(columns: (1fr, 1fr), gutter: 1em,
  [#link(<design>)[2 · Geometry And Color] \
   #link(<people>)[3 · Covers, Logos, And People] \
   #link(<navigation>)[4 · Navigation And Agendas] \
   #link(<images>)[5 · Slide Patterns And Images]],
  [#link(<blocks>)[6 · Content Blocks] \
   #link(<citations>)[7 · Citations And Bibliographies] \
   #link(<utilities>)[8 · Text And Small Components] \
   #link(<roadmaps>)[9 · Project Roadmaps] \
   #link(<output>)[10 · Output And Customization]],
)

#note[Use `typst init @preview/touying-ambrosia:0.1.0 my-slides` for the complete
  #guide("template/template.typ", [starter]), including Ambrosia branding.
  A checkout install defaults to `@local`; use that namespace for development
  imports. The base theme starts without any logo.]

#pagebreak()
= Geometry And Color <design>
A *flavor* defines the composition: header/footer geometry, logo placement,
slide heading level, cover defaults, and component presets. A *palette* supplies
semantic colors. *Navigation* reserves its own space independently. Choosing
one does not constrain the others.

#choices((
  ([`minimal`, `simple`], [Quiet defaults or a spacious classic treatment.]),
  ([`dewdrop`, `stargazer`], [Lightweight dot navigation or accent headings with section tabs.]),
  ([`darmstadt`, `cambridge`], [Structured bands; Cambridge uses level-three slide headings.]),
  ([`portico`], [A metadata band and optional contrasting right outline panel.]),
))

== Twelve Starting Palettes
#grid(columns: (1fr,) * 4, gutter: 0.6em,
  ..core.palettes.palette-names.map(name => {
    let p = core.palettes.resolve(name)
    block(width: 100%, inset: 0.55em, radius: 0.3em, fill: p.background,
      stroke: 0.04em + p.border)[
      #text(size: 0.85em, weight: "bold", fill: p.foreground, name)
      #v(0.3em)
      #grid(columns: (1fr,) * 4, gutter: 0.2em,
        ..(p.accent, p.surface-alt, p.muted, p.chrome).map(c =>
          rect(width: 100%, height: 0.7em, fill: c, stroke: none)))
    ]
  }),
)

#api("palettes.typ", "ambrosia-palette")

#live(```typ
#let custom = ambrosia-palette(
  primary: rgb("2b6b51"))
#let p = palettes.resolve(custom)
#rect(fill: p.accent, stroke: none,
  inset: 0.8em)[
  #text(fill: p.on-accent)[My Accent]
]
```)

Pass the descriptor to `ambrosia-theme(palette: custom, ...)`. The light preset
derives its alternate surface from the seed; other presets retain their curated
surfaces. Start from a dark preset to make a dark theme. Explicit ink overrides
need an appropriate contrasting surface.
#guide("docs/palettes.md", [Palette roles and overrides]) ·
#guide("examples/palettes.typ", [Editable palette example])

#pagebreak()
= Covers, Logos, And People <people>
`title-layout` and `ending-layout` override a flavor's defaults.
A local `title-slide(layout: ...)` or `ending-slide(layout: ...)` takes priority.
Extend a preset with `ambrosia-title-layout(base: ..., ...)` or
`ambrosia-ending-layout(base: ..., ...)` when a few dimensions need adjustment.

#choices((
  ([Opening], [`stacked`: centered panel; `header`: top logo band; `plain`: left typography;
    `split`: side logo panel; `featured`: prominent primaries; `cover`: immersive color/photo.]),
  ([Closing], [`centered`: questions panel; `plain`: left typography;
    `split`: takeaways beside contacts; `cover`: immersive color/photo.]),
))

== One Logo Or Several
`primary-logos` is the repeated brand collection. With `auto`, it falls back to
`config-info(logo: ...)`. `logos` adds opening partners. `title-logos` replaces
that complete ordered list; `none` hides it. Ordinary header and footer logo
settings remain independent. Native image paths stay relative to the caller.

Equal cells are the default. `title-logo-distribution: "grouped"` aligns primary
marks left and partners right in horizontal rows. The featured layout instead
gives primaries their own region and centers the remaining partners.

#grid(columns: (1.15fr, 1fr), gutter: 1em, align: horizon,
  source(```typst
// Inside ambrosia-theme.with(...):
title-layout: "header",
primary-logos: (image("lab.svg"),),
logos: (image("university.svg"),),
config-info(
  title: [A Collaborative Talk],
  authors: (
    (name: [Alex Researcher],
      affiliations: ("lab",),
      email: "alex@example.org"),
    (name: [Sam Collaborator],
      affiliations: ("lab",)),
  ),
  institutions: (lab: [Example Lab],),
  short-author: [Researcher et al.],
  short-title: [Collaboration],
),
```),
  [#snapshot("cover")
   #v(0.5em)
   #text(size: 0.85em, fill: muted)[Header layout with Ambrosia's project logo.
     This snapshot uses simpler metadata than the recipe at left.]],
)

== Linked Metadata And Fitted Covers
Institution markers link to their title-page entries. Set
`affiliation-numbering: "*"`, `"a"`, or a native numbering function;
`ambrosia-affiliation("lab")` reuses the marker elsewhere. Authors flow into one
to three balanced columns; `author-columns` pins the count. Shared `emails`
supplement personal addresses; endings collect the appropriate contacts.

Title metadata fits as one unit, down to `title-min-scale: 65%` by default.
If it still cannot fit, a diagnostic asks for less content instead of creating an
extra page. Large consortia usually benefit from a separate contributor slide.
#guide("docs/people.md", [People and footers]) ·
#guide("docs/title-layouts.md", [Title layouts]) ·
#guide("docs/ending-layouts.md", [Ending layouts])

#pagebreak()
= Navigation And Agendas <navigation>
Choose `navigation` explicitly, keep `auto` for the flavor preset, or use `none`
to reclaim its space. Navigators follow visible headings and logical slides;
animation frames share one position. PDF links target the original slides.

#choices((
  ([`tabs`], [Linked level-one section labels in a compact header.]),
  ([`dots`], [Logical-slide dots grouped by section.]),
  ([`context`], [Current section/subsection in a compact band.]),
  ([`tree`], [Talk title and current ancestors in thin, indented strips.]),
  ([`panes`], [Sections beside the current section's children.]),
  ([`breadcrumbs`], [Linked ancestor path in the ordinary title slot.]),
  ([`sidebar`], [A bounded outline in a reserved left or right column.]),
  ([`segments`], [Section labels and local progress in a footer rail.]),
))

#grid(columns: (1fr, 1.2fr), gutter: 1em, align: horizon,
  source(```typst
#show: ambrosia-theme.with(
  flavor: "cambridge",
  navigation: "tree",
  navigation-buttons: true,
  section-progress: false,
)
// Hide locally and release space:
#slide(config: config-store(
  navigation: none,
))[A wide figure.]
```),
  snapshot("navigation"),
)
`navigation-side`, `navigation-width`, and `navigation-depth` tune a sidebar.
`sidebar-background: none` is the default; `auto` enables the flavor’s panel paint.
`ambrosia-navigation(base: ..., ...)` adjusts a descriptor, such as a segmented
rail's header/footer placement. Header bands and sidebars reserve space;
transparent `navigation-buttons` and the global `progress-bar` are independent.
Long navigators window around the current location rather than growing forever.

== The Agenda Is Slide Content
`agenda-style` chooses `"list"`, `"cards"`, or `"path"` for the opening outline
and automatic section transitions. `outline-slide(style: ...)` overrides one
view. Cards suit a short talk; crowded cards fall back to the compact list.
`agenda-text-size` defaults to `1.15em`; either helper accepts local `text-size`.
Set `outline-fill: repeat[.]` on the theme, or `fill:` on one overview/divider,
for dotted leaders. The core default is `none`.

Section dividers center the current section and expanded children, with quiet
neighbors (`neighbors: 0`, `1`, or `2`). Fitting removes neighbors and excess depth
before introducing linked omission markers. Nothing spills onto a second page.
Text between the chapter heading and its first slide becomes a quiet summary
panel; chapters without visible summary content add no panel or summary gap.
#source(```typst
#show: ambrosia-theme.with(
  config-common(new-section-slide-fn:
    new-section-slide.with(style: "path", neighbors: 1)),
)
#outline-slide(style: "cards", depth: 1)
```)
#guide("docs/navigation.md", [Navigator configuration]) ·
#guide("docs/agendas.md", [Agenda selection and fitting]) ·
#guide("examples/navigation.typ", [Editable navigation example])

#pagebreak()
= Slide Patterns And Images <images>
Use `slide` or ordinary headings for results, comparisons, tables, quotations,
and equations. Multiple positional bodies make columns. Native `grid`, `figure`,
`table`, and `quote` remain useful inside them.

`focus-slide[One message]` creates an immersive emphasis slide and freezes the
logical counter. `section-slide(title: [...])[]` is a simple counted divider;
`new-section-slide` is the fitted agenda transition. `backup-slide[...]` freezes
the counter for an interlude. `ending-slide` stays counted and uses normal flow.

#pair(snippets.image-example, "image")

#api("theme/special.typ", "image-slide")

#note[Positions use native alignments: `top` creates a top band; `bottom + right`
  can place an inset card. Margins reduce the region before width is calculated.
  The image is cropped with `cover`; `contain` keeps the complete image.
  Panel and link ink adapt to the selected fill. A photograph's contrast remains
  the author's choice.]
#guide("docs/image-slides.md", [Caption placement and contrast]) ·
#guide("examples/image-slides.typ", [Editable image comparison])

#pagebreak()
= Content Blocks <blocks>
Choose *style* for appearance and *kind* for semantic meaning. Both are independent
of flavor and palette. A block is a nonbreaking container, with optional title;
`ambrosia.block` is its scoped spelling.
#pair(snippets.block-example, "blocks")

#api("components/blocks.typ", "ambrosia-block")

For a reusable preset: `#let result = ambrosia-block.with(style: "poster", kind: "success")`.
Styles are plain (quiet panel), framed (joined colored header), poster (detached header),
outlined (transparent frame), stripe (square left accent), and tabbed (centered
title crossing the border). Nested blocks and pauses keep their normal behavior.
The theme's `block-style` sets the default. Watermarks require a configured
`watermark-logo`; they are not inserted by the neutral theme automatically.
#guide("docs/utilities.md", [Block styling and nesting])

#pagebreak()
= Citations And Bibliographies <citations>
Author/year labels connect a short reference to the same work throughout a talk.
By default, `footcite`, native `cite`, `@key`, and the bibliography use matching
compact CSL identifiers, including disambiguation. Ordinary footnotes retain
their native numbering. Footnote citations appear once per presentation by
default, with subsequent markers linking back to the full entry.

#source(```typst
== A Useful Reference
A full note #footcite(<knuth84>); an ordinary citation @knuth84.
#bibliography-slide("references.bib")
// Or register a source without a visible reference list:
// #hidden-bibliography("references.bib")
```)

#api("citations.typ", "footcite")

== Marker Policy And Multiple Sources
Set `footcite-marker`, `cite-marker`, and `bibliography-marker` on the theme.
The first accepts `"author-year"`, `"number"` (stable citation identity), `"local"`
(native per-slide numbering), or `"key"` (literal database key). The latter two
accept `"author-year"` or `"native"`. Explicit native CSL styles take priority.
`footcite-once: false` repeats the full note on each cited slide.

With Typst 0.15, separate bibliographies can reuse a key. Pass the same `scope`
to `footcite` and `bibliography-slide` to select it explicitly; native citations
can be labeled and selected with a bibliography's `target`. Unscoped keys retain native routing.
#source(```typst
#footcite(<shared>, scope: "methods")
#bibliography-slide("methods.bib", scope: "methods", group: none)
// Alternative: native labeled-citation routing (without scope).
#cite(<shared>) <methods-citation>
#bibliography-slide("methods.bib",
  target: <methods-citation>, group: none)
```)
Author-highlighted publication lists use an optional Pergamon
#guide("docs/publications.md", [recipe and example]); ordinary decks do not import it.

#guide("docs/utilities.md", [Citation behavior and multiple bibliographies]) ·
#guide("examples/utilities.typ", [Citation example])

#pagebreak()
= Text And Small Components <utilities>
`alert[the key point]` applies the accent without forcing bold. `muted`
and `subtle` reduce prominence while inheriting typography. They remain
readable on known solid slide and block surfaces. Arbitrary image/gradient
backgrounds may need explicit native `text(fill: ...)`.

#source(```typst
A #alert[main result], #muted[secondary context],
and #subtle[an optional aside].
#ambrosia-source-note[Source: Example Dataset, 2026.]
```)

#api("components/annotations.typ", "ambrosia-badge")

#source(```typst
#ambrosia-badge(kind: "success", shadowed: true)[Verified]
#ambrosia-badge(kind: "warning")[Preliminary]
```)

== Native Content Gets A Consistent Treatment
Fenced code and block `raw` receive a compact palette surface. Inline code stays
inline. Block `quote` receives an accent stripe. `code-style: "plain"` and
`quote-style: "plain"` disable those treatments. Native language highlighting,
explicit syntax themes, attribution, links, and reveals still work.
Table text defaults to `0.85em`, captions to `0.8em`, and footnotes to `0.65em`,
relative to the default `text-size: 18pt`.

== Show Colors Or Credit The Theme
`ambrosia-palette-showcase()` shows the actual current roles, including local
color overrides. Use `roles: (...)`, `columns: 3`, or `codes: false` to simplify it.
`ambrosia-shadow[...]` decorates native content; built-in blocks/badges expose
their own `shadowed` option for shadows matched to their geometry.

`ambrosia-credit-card()` is an optional small package credit with logo, PDF link,
and bundled repository QR. Nothing adds it automatically. `qr: false` hides the
code; `width: ...` changes its size. Institution wrappers can supply their own
project credit. Ordinary acknowledgements need only text or a block.

#note[Use familiar names for slides and Touying operations. Ambrosia-specific
  generic utilities use the `ambrosia-` prefix to avoid native collisions.
  A scoped import also exposes `ambrosia.block`, `ambrosia.badge`,
  `ambrosia.muted`, and the other helpers. Import Ambrosia after Touying when
  using both wildcard imports.]
#guide("docs/api.md", [Public names and scoped equivalents]) ·
#guide("examples/text-and-code.typ", [Text and code example]) ·
#guide("docs/credits.md", [Credit card options])

#pagebreak()
= Project Roadmaps <roadmaps>
Use a roadmap when duration, overlap, and milestones matter. Time is elapsed
from zero: `start: 0, end: 2.5` lasts 2.5 units. Units change labels, not the values.
Tasks on the same track must be ordered and disjoint; concurrent work uses
separate tracks.
#pair(snippets.roadmap-example, "roadmap")

#api("components/roadmap.typ", "ambrosia-roadmap")

Group dictionaries inside an array to share a track. Phase records need `name`
and `end`; starts default to the previous end. A task's `details` can be content
or a `(content: ..., start: ..., end: ...)` drawer below its track. Phases, tasks,
and milestone records accept `kind` or a solid `fill`.

Fractional boundaries retain proportional spacing. Very dense plans produce a
fitting diagnostic at `min-scale`, rather than an overflow page. Whole-component
reveals work; pauses inside task dictionaries are not an animation interface.
The roadmap does not schedule dependencies or convert calendar dates.
#guide("docs/roadmap.md", [Data model and custom tick labels]) ·
#guide("examples/roadmap.typ", [Editable project and event plans])

#pagebreak()
= Output And Customization <output>
== A Small Configuration Model
#choices((
  ([Theme keywords], [Geometry, palette, navigation, typography, logos, and slide-layout defaults.]),
  ([`config-info(...)`], [Title, people, institution IDs, emails, date, and short footer labels.]),
  ([`config-store(...)`], [Per-slide component and navigation options.]),
  ([`config-common(...)`], [Touying behavior, section callback, and output mode.]),
  ([`config-page(...)` / `config-colors(...)`], [Final page and color overrides; custom chrome owns its spacing.]),
))

#source(```typst
#slide(config: config-store(navigation: none))[
  A local change without altering the rest of the talk.
]
#show: appendix
== Supporting Detail
Visible backup material with separate Roman slide numbers.
```)

== Footer Labels And Speaker Output
Give `config-info(short-author: ..., short-title: ...)` concise footer text.
Dates appear only when metadata supplies one. The footer reserves the complete
date and slide count, then fits author/title down to `footer-min-scale: 80%`
before clipping with an ellipsis. Covers use the full metadata.

Touying's `#speaker-note[...]` stays invisible in ordinary slide output. Export
its matching `.pdfpc` sidecar to get private notes in pdfpc. The
#guide("docs/speaker-notes.md", [presenter guide]) and
#guide("examples/speaker-notes.typ", [editable example]) show both commands and
an optional single-compilation bundle export.

`config-common(show-notes-on-second-screen: right)` creates a double-width PDF;
launch it with #box[`pdfpc --notes=right`] to separate audience and notes halves.
A normal viewer displays both. `show-only-notes: true` creates a rehearsal
page with a slide thumbnail. `handout: true` keeps each slide's last animation
frame. Use an extended desktop for separate presenter/projector views.

== Linked Miniature Slides
#source(```typst
#ambrosia-slide-preview(<result>, width: 35%,
  thumbnail: image("previews/result.svg"),
  caption: [Return To The Result], frame: "last")
```)
The thumbnail is an ordinary static image; the PDF destination comes from the
live target label and selected animation frame. Without `thumbnail`, a linked
placeholder remains. Typst cannot capture a finished page during that same run.
The optional standalone Python exporter creates persistent SVGs in a separate
pass. Browser-only authors can upload already exported images. The shipped
example and this manual bundle snapshots, so normal IDE preview needs no script.

== Extend Only What You Need
Palette, flavor, navigation, title, and ending constructors accept descriptors.
Custom callbacks can own a fully different composition. Institution wrappers
should use the supported `extensions` module to add their own logos, palettes,
and custom cover compositions. The experimental Sankey stays an optional diagram
recipe, outside the public API.

#guide("docs/slide-previews.md", [Snapshot workflow]) ·
#guide("docs/extensions.md", [Renderer extension contract]) ·
#guide("docs/diagram-recipes.md", [Standalone diagram recipe])

#note[The #guide("docs/api.md", [API index]) and linked guides list all options.
  Tidy extracts the typed API tables; slide snapshots come from
  #guide("docs/examples/slides.typ", [shared examples]).]
