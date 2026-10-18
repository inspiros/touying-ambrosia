# Slide Helpers

Use ordinary `slide`, headings, and native Typst content for most slides.
Special helpers change geometry or counting when needed.

| Helper | Purpose |
| --- | --- |
| `title-slide` | Opening with fitted metadata and branding. |
| `outline-slide`, `new-section-slide` | Overview and automatic agenda transition. |
| `section-slide` | Simple counted divider. |
| `focus-slide` | One central message; freezes the slide counter. |
| `image-slide` | Full-page image, optional caption and credit. |
| `bibliography-slide` | References. |
| `ending-slide` | Closing body, contacts, and optional marks. |
| `backup-slide`, `appendix` | Interlude with frozen counter, or a separately numbered appendix. |

## Compose Ordinary Content

Two positional bodies create columns:

```typst
#slide(title: [Two Perspectives])[
  The baseline and its limitation.
][
  The result and supporting evidence.
]
```

Use `grid`, `figure`, `table`, and [blocks](utilities.md) for more control.
`slide(header: none, footer: none)` hides ordinary decorations.
`focus-slide(fill: ..., text-fill: ...)[...]` chooses a custom emphasis surface.

## Further Examples

The optional [publication list](../examples/publications.typ) and experimental
[Sankey diagram](../examples/sankey.typ) are source recipes, not Ambrosia APIs.
Adapt them independently if useful.
