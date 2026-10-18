# Utilities

Import utilities from the package entrypoint after any direct Touying import. The theme installs their styling. See [the utilities example](../examples/utilities.typ) for a complete presentation.

## Text Hierarchy And Native Content

`alert` emphasizes a phrase. `muted` and `subtle` reduce its
visual prominence without changing the surrounding font, size, weight, or
spacing. Their scoped names are `ambrosia.muted` and `ambrosia.subtle`.

```typst
Regular text, #alert[the key point], #muted[secondary context],
and #subtle[an optional aside].
```

On solid pages and Ambrosia block surfaces, tones retain at least 4.5:1 text
contrast. Subtle fades muted ink by at most 20%; the roles can converge when
there is little contrast headroom. On gradient fills, they retain the inherited ink. Nested blocks, late `context` content, and reveals are supported.
For image backgrounds or arbitrary native containers with custom fills, use
native `text(fill: ...)` to choose ink for that surface.

Native fenced code and `raw(block: true)` receive a palette surface, thin border,
and compact padding. Inline raw stays inline. Language, explicit syntax theme,
and other native raw options remain available. `code-style: "plain"` disables
the panel while retaining the theme's existing code font and syntax defaults.

Native `quote(block: true)` receives an accent stripe. Inline quotation marks,
block attribution, links, footnotes, and reveals retain native behavior.
`quote-style: "plain"` disables the stripe treatment. Both style options can be
set on the theme or locally with `config-store`. This adds no code, quotation,
comparison, or equation slide type; ordinary slides remain the composition tool.
Try the [editable text/code example](../examples/text-and-code.typ).

## One Block, Several Styles

`ambrosia-block` is the shared container. Select a visual treatment with `style`, and a semantic accent with `kind`:

```typst
#ambrosia-block(style: "poster", kind: "info", title: [Observation])[
  A result worth discussing.
  #ambrosia-block(style: "outlined", title: [Details])[
    Before #pause After.
    #alert[An important qualification.]
  ]
]
```

| Style | Appearance |
| --- | --- |
| `plain` | Quiet panel with an accent heading. |
| `framed` | Attached accent title bar and panel. |
| `poster` | Separate rounded title bar and body, inspired by the Touying poster. |
| `outlined` | Transparent bordered panel with a ruled heading. |
| `stripe` | Subtle panel with a left accent stripe. |
| `tabbed` | Centered accent title tab crossing the panel's top border. |

Kinds are `accent` (default), `info`, `success`, `warning`, `danger`, and `neutral`. Every style works with every palette. Titles accept strings, content, or headings; omitting the title produces a body panel.

`kind` expresses the container's purpose through a palette-defined accent. It affects headings, borders, and local alert/list accents; it does not add theorem numbering, change the content, or choose the geometry.

| Kind | Intended use |
| --- | --- |
| `accent` | General content in the presentation/team accent. |
| `info` | Context, observations, or explanation. |
| `success` | Validated results or completed work. |
| `warning` | Assumptions, uncertainty, or limitations. |
| `danger` | Failures or critical caveats. |
| `neutral` | Supporting material with a restrained accent. |

Use a descriptive title as well as color. An explicit `fill:` replaces the kind's accent. The name `ambrosia-block` reflects its block layout behavior; the prefix avoids colliding with Typst's native `block`. The scoped equivalent is `ambrosia.block`. The former `tblock` and `framed-tblock` functions have been removed; use `ambrosia-block(style: "framed", ...)` for the latter.

Choose a presentation-wide default with `ambrosia-theme(block-style: "poster", ...)`. The default otherwise follows the flavor. Create your own presets without new imports:

```typst
#let result = ambrosia-block.with(style: "stripe", kind: "success", title: [Result])
#result[Measured improvement.]
```

The appearance options are `fill` (accent), `background` (body fill), `text-fill`, `title-fill`, `shadowed`, `radius`, `inset`, `stroke`, `width`, and `gap`. `background: none` supports transparent bodies. Solid custom fills choose contrasting text automatically; explicit text colors take precedence. Gradients and images require an appropriate explicit foreground.

`shadowed: auto` follows the style, then the flavor preset: plain/framed blocks retain classic shadows, while poster/outlined/stripe/tabbed are flat. Explicit `true` or `false` overrides that choice. Dimensions default to `em` units.

The tabbed style reserves room for its centered title, including wrapped long titles. Its body can be transparent, its title can carry a watermark, and explicit shadows follow the tab and panel separately. A missing title produces the ordinary body panel.

Shadows follow physical panels. Poster headings and bodies cast separate shadows, preserving their gap. Transparent panels shadow their border rather than painting a dark rectangle under the content; a transparent borderless panel has no shadow. A framed block with a transparent body shadows its filled heading and outer border. Transparent borders with different side widths use their largest width for the shadow contour.

For custom native containers, `ambrosia-shadow` (or `ambrosia.shadow`) accepts `hollow: <length>` to shadow a border of that thickness. Its default `hollow: none` retains a filled silhouette; `fill: none` disables the shadow.

Nested blocks and alerts expose their bodies to Touying's animation parser. Plain content also works inside `context`. Animation marks must remain visible to the parser before layout; putting `pause` inside an opaque `context` remains unsupported by Touying.

Block watermarks are optional: `watermark: true` or `"body"` stamps the body; `watermark: "title"` stamps the heading region. They adapt to the actual surface, scale with text, and stay clipped to the panel. Prefer one decorated container on a slide; nested stamps can overlap. Block content is not measured or scaled to add the decoration, preserving footnote and animation behavior.

## Fitted Outlines And Section Transitions

`outline-slide` and the default `new-section-slide` use a compact list. Set `agenda-style: "cards"` or `"path"` on the theme, or `style:` on either helper, for section cards or a connected hierarchy. Cards use up to two overview columns and fall back to a list for long decks. See [agendas](agendas.md) and the [editable example](../examples/agendas.typ). The default list and path use one column. They measure content and scale text/relative spacing together, with `outline-min-scale: 80%` as the theme default. Override a helper with `min-scale:`.

Section transitions keep the current section and its expanded children at the vertical center. Only immediate previous/next sections appear faintly; distant sections disappear. Use `new-section-slide.with(neighbors: 0)` for just the current branch, or `neighbors: 2` for two neighbors on either side. When space is scarce, the renderer drops neighbors, collapses deeper headings, then shows as many current children as fit.

An overview first collapses excess depth. If even the top-level list cannot fit at the minimum scale, it shows a window around the current position (the beginning before the first section). `outline-slide(start: 15)` begins an explicit forward window at the fifteenth eligible entry. `overflow: "error"` requests a diagnostic instead of windowing.

Every omitted heading is accounted for by a linked `… +N` indicator. It jumps to the first omitted heading. Large omitted sets do not create extra slides or silently spill. For a complete long agenda, split it intentionally into multiple overviews or use Typst’s native `outline` in a deliberately composed slide.

`depth`, `level`, and `numbered` control selection and heading prefixes. Entry numbers at the right refer to logical slides, so animation frames do not inflate them. Main and appendix scopes remain separate. Extra overview content and section introductions share the measured space; an oversized single entry/introduction raises a diagnostic.

## Citation Footnotes

`footcite` provides citation footnotes. The default development behavior uses a compact, linked author-year marker and a full APA entry at the foot of the slide:

```typst
A useful reference #footcite(<knuth84>).
#hidden-bibliography("references.bib")
```

The marker resembles `[Knuth1984]`. A packaged CSL stylesheet uses Typst's native citation processor to select the first author's family name and year, including `a`/`b` suffixes when different cited works would have the same label. Repeated use of one key retains its identity; two different works need distinct bibliography keys. Missing authors fall back to editors, then the title; missing dates use `n.d.`. Long fallback titles can need a manual marker.

For presentations, author-year markers give readers a recognizable identity even when the full entry appears on an earlier slide. The slide-local number of an ordinary footnote identifies a note on that slide; it should not be treated as a paper identifier.

### Marker Modes

Set `footcite-marker` in the theme, or override one call with `marker`:

| Mode | Behavior |
| --- | --- |
| `"author-year"` (default) | Native CSL marker, e.g. `[Knuth1984a]`. |
| `"number"` | Stable presentation-wide ID, e.g. `[1]`, assigned among footcite identities. |
| `"key"` | Literal bibliography key; an explicit scope is prefixed. |
| `"local"` | Legacy inline APA citation plus a slide-local superscript. |
| Content, e.g. `[Knuth84]` | Manual bracketed marker; routing and full entries remain automatic. |

```typst
#show: ambrosia-theme.with(footcite-marker: "number", ...)
#footcite(<knuth84>, marker: "author-year")
#footcite(<knuth84>, marker: [Knuth84], label: <knuth-note>)
See @knuth-note.
```

Numeric IDs identify `(scope, key)` pairs among visible footcite sources. They are independent of native bibliography numbering when other citation forms or bibliography groups coexist. Author-year disambiguation is native to each bibliography group; independent groups can reuse the same author-year label. Use a custom marker or the key mode when the group must be explicit to readers.

Non-local citation markers do not consume ordinary footnote numbers. Custom labels and repeated citations link to the actual full entry, including an entry on an earlier slide. An explicit marker override keeps its appearance even if the first occurrence used another marker; the deduplicated full entry retains its first marker. Choose one mode consistently for a presentation when matching marker appearance matters.

### Entry Formatting And Repetition

By default, a full entry appears on its first logical slide and remains visible on later animation frames of that slide. Repeated citations on the same page share that entry. `ambrosia-theme(footcite-once: false)` repeats full entries on every cited slide; this is useful when slides may be shared individually. Covered citations do not reveal entries prematurely.

`foot-style: "apa"` is the new default. Set `foot-style: auto` to use the assigned bibliography's style. `cite-style` (default APA) and `form` control an optional ordinary inline citation. `inline: auto` includes it in local mode; set `inline: true` or `false` explicitly to override. `supplement` is forwarded to the native citations. Custom CSL styles can be supplied as `path("custom.csl")` or bytes.

Explicit `numbering:` selects local mode for compatibility unless `marker:` is also supplied. In numeric mode it formats the stable ID. To recover the old behavior, use `footcite-marker: "local"` and `foot-style: auto`.

Footnote text defaults to `0.65em`, configurable through `footnote-text-size`. Dense references still need author judgement: shorten or move them to a bibliography slide rather than filling most of a slide with notes.

`hidden-bibliography` registers its bibliography on the last animation frame, so one logical slide does not create several bibliography instances. Ordinary `@key` citations use native Typst processing with the configured `cite-marker` style. Note-producing CSL styles such as `chicago-notes` already create notes; use them as ordinary citations instead of nesting them in an explicit citation footnote. Touying's automatic bibliography-as-footnote option is an alternative to these explicit helpers.

## Native Inline Citations

Both `#cite(<key>)` and `@key` now use compact `[AuthorYear]` labels by default. A native `set cite(style: ...)` rule supplies the same CSL used by footcite; no replacement cite function or citation-rewriting show rule is involved. Typst keeps supplements, citation forms, bibliography links, grouping, multiple-source routing, and year suffixes.

```typst
Normal #cite(<knuth84>). Shorthand @knuth84.
Explicit formatting #cite(<knuth84>, style: "apa").
```

Set `cite-marker: "native"` in the theme to inherit the bibliography's citation style. `footcite-marker` and `bibliography-marker` remain independent. To use a conventional bibliography/citation pair, set both `cite-marker: "native"` and `bibliography-marker: "native"`, then select a native bibliography style. An explicit citation `style:` always takes priority. Ordinary heading/figure references such as `@fig-label` retain their native reference behavior.

## Matching Bibliography Markers

`bibliography-slide` defaults to the same native compact author–year CSL as the footcite marker. Labels such as `[Knuth1984a]` match even when bibliography sorting differs from citation order. With `cite-marker: "native"`, ordinary citations inherit that bibliography style too. The bibliography uses a compact reference format with author, year, title, publication details, and DOI/URL when present.

```typst
#footcite(<knuth84>)
#bibliography-slide("references.bib")
```

Set `bibliography-marker: "native"` in the theme or `marker: "native"` on a bibliography slide to restore Typst's bibliography style. An explicit `style: "apa"` (or native CSL path/bytes) automatically selects native mode unless `marker` is supplied explicitly. `marker: "author-year"` requires Ambrosia's bundled CSL; it cannot be combined with another bibliography style. Native Typst controls disambiguation, links, source formats, groups, and routing; no external bibliography library is used.

The matching default covers author–year mode. Footcite's presentation-wide numeric IDs, literal keys, and custom markers are separate conventions; native bibliography styles do not automatically reproduce them. Choose a coherent marker/style pair for a presentation. `hidden-bibliography` registers sources using native settings and does not display a reference list.

## Multiple Bibliographies

Typst 0.15 assigns unscoped citations to the nearest appropriate bibliography. Native `target` and `group` options are forwarded by the bibliography helpers. For independent sources that reuse keys, give each a `scope`:

```typst
#footcite(<shared-key>, scope: "methods")
#hidden-bibliography("methods.bib", scope: "methods", group: none)

#footcite(<shared-key>, scope: "results")
#bibliography-slide("results.bib", scope: "results", group: none)
```

Scopes target both the marker and full citation through Typst's bibliography selector. Deduplication uses key plus scope. Use either `scope` or a native `target` selector on a bibliography helper, not both. Unscoped keys keep once-per-presentation behavior; scope independent sources explicitly when they reuse keys.

## Small Annotations

`ambrosia-badge` adds a compact semantic label. It accepts the same kinds as blocks, an optional solid `fill`, and `shadowed: true` for a subtle shadow (default false). Shadowed badges retain their inline size. `ambrosia-source-note` adds a local muted source/credit line without creating a citation or consuming a footnote:

```typst
#ambrosia-badge(kind: "success", shadowed: true)[Validated]
#ambrosia-badge(kind: "warning")[Preliminary]
#ambrosia-source-note[Image: #link("https://example.org")[Source].]
```

Use words as well as colors to convey status. These components support nested content and Touying animation visibility.

## Project Roadmaps

`ambrosia-roadmap` (or `ambrosia.roadmap`) adds a palette-aware project timeline with phases, concurrent task tracks, milestones, and detail drawers. It supports custom units and fractional time spans, custom period labels, and measured height fitting. See [the roadmap guide](roadmap.md) and [editable example](../examples/roadmap.typ).

## Slide Helpers

`section-slide` creates a counted divider with an optional subtitle, logo, and body. Use it manually or as Touying's section callback:

```typst
#section-slide(title: [Results], subtitle: [What changed?])
// Or configure automatic dividers:
#show: ambrosia-theme.with(
  config-common(new-section-slide-fn: section-slide),
  ...
)
```

`image-slide` creates a full-page image with an optional readable caption/credit overlay. String paths resolve relative to the caller:

```typst
#image-slide("images/lab.jpg",
  caption: [Our laboratory], credit: [Photo: institution],
  alt: "View of the laboratory",
)
```

It accepts native image arguments plus `fit` (default `"cover"`) and per-slide `config`. `fit: "contain"` preserves the entire image. Image slides hide headers/footers and count normally. Use `caption-position: top + right`, `caption-width: 42%`, and `caption-margin: 1em` for a corner card. `caption-fill` and `caption-text-fill` control its appearance. See [image captions](image-slides.md) and the [editable example](../examples/image-slides.typ).

`slide(header: none, footer: none)` hides decorations; content or functions can replace them. `focus-slide` accepts `fill` and optional `text-fill`; solid light backgrounds choose dark text automatically. `title-slide` honors metadata and complete logo-list overrides; `layout` selects a native composition independently of flavor. See [title layouts](title-layouts.md). Visible third-level headings contribute to automatic subtitles without covered headings appearing early.

See [presentation patterns](presentation-patterns.md) for other slide compositions.

## Speaker Notes

Touying's `speaker-note` is already available. For private presenter notes use
an ordinary slide PDF with its `.pdfpc` sidecar, or configure a compatible viewer
to split a double-page notes PDF. See the [presenter workflow](speaker-notes.md)
and [editable example](../examples/speaker-notes.typ).

## Appendix

```typst
#ending-slide(title: [Thank you])[Questions?]
#show: appendix
= Backup section
== Supporting result
Backup content.
```

The main slide total freezes while appendix slide counters continue, displayed as Roman numerals in the footer. Main outlines/navigation exclude appendix headings before the appendix starts; appendix outlines use their own heading scope.

For numbered appendix headings, use `#show: appendix.with(numbering: "A.1")`. Headings restart at A; the theme receives section bodies so Touying's deferred counter reset executes before that first section. This also preserves introductory content under section headings.

`backup-slide` is a separate helper that freezes the slide counter as well.

See [navigation](navigation.md) for optional transparent PDF controls and existing flavor navigation. Stripe blocks keep their left corners square; their right corners follow `radius`.

## Linked Slide Thumbnails

`ambrosia-slide-preview` links a small framed image to another slide, including a chosen animation frame. Without an image it shows a clickable placeholder. Exact capture uses exported SVGs and the optional build helper; it does not replay live source content. See [the workflow](slide-previews.md).

## Ending Layouts

Use theme `ending-layout` or per-slide `layout` for centered, plain, split
takeaway/contact, and cover compositions. `ambrosia-ending-layout` adjusts their
geometry without a new flavor; `contacts` and `logos` override one closing.
See [ending layouts](ending-layouts.md).

## Selected Publications

For a presenter's own works with highlighted author names, see the optional
[publication recipe](publications.md) and [editable example](../examples/publications.typ).
It imports Pergamon explicitly and keeps native citations independent.
