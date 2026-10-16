# Presentation Patterns

A dedicated helper is useful when a slide needs distinct page geometry or counting behavior. Most research slides can stay compositions of `slide`, `grid`, `figure`, and `ambrosia-block`; that keeps content flexible across flavors and palettes.

## Available Slide Types

| Purpose | Helper |
| --- | --- |
| Opening and metadata | `title-slide` |
| Agenda or current roadmap | `outline-slide` |
| Ordinary content | `slide` or headings |
| Section transition | `section-slide`, optionally as `new-section-slide-fn` |
| One central message | `focus-slide` |
| Full-page photograph or figure | `image-slide` |
| References | `bibliography-slide` |
| Closing, contact, or questions | `ending-slide` |
| Supporting material | `appendix` or `backup-slide` |

Explicit `title:` is useful for reusable compositions; heading-driven slides integrate naturally with outlines. `cambridge` uses level-three slide headings, while other flavors use level two.

## Compositions Worth Including In A Talk

| Slide | Suggested composition |
| --- | --- |
| Problem and contribution | Two panels: the question, then the specific result. |
| Before/after or competing methods | A two-column `grid` with identical panel geometry and comparable evidence. |
| Method or pipeline | Numbered stages in a grid, with one caption describing the flow. |
| Main result | A large figure, a short takeaway, a source note, and a limitation if needed. |
| Demonstration | A screenshot in `image-slide` or an ordinary figure, with steps or a link nearby. |
| Quote | Native `quote` in a quiet panel; use `footcite` for a bibliographic source. |
| Project or research plan | `ambrosia-roadmap` with phases, concurrent tasks, milestones, and optional details. |
| Short chronological timeline | Native shapes/grid with dates and short milestones. |
| Summary or takeaways | Three concise statements; `focus-slide` can emphasize the most important. |
| Acknowledgements and funding | A grid of names and marks on an ordinary or ending slide. |
| Resources/contact | `ending-slide` with a short readable URL and an optional QR code. |
| Discussion | One open question or two alternatives, leaving room for conversation. |

For example, comparison panels can share a preset:

```typst
#let comparison-panel = ambrosia-block.with(style: "poster")
#slide(title: [What changed?])[
  #grid(columns: (1fr, 1fr), gutter: 1em,
    comparison-panel(title: [Before])[The baseline and its limitation.],
    comparison-panel(title: [After])[The result and supporting evidence.],
  )
]
```

Prefer the same scale, units, and chart bounds when comparing evidence. Do not communicate success or uncertainty through color alone; semantic badges also need descriptive text.

## Related Components

Use `ambrosia-block.with(...)` for reusable panels, badges and source notes for
compact annotations, and [roadmaps](roadmap.md) for concurrent time spans.
Weighted flows can use the optional [Sankey recipe](diagram-recipes.md).
