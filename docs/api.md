# API Index

Browse by object rather than following the introductory guides. Each group
links to usage, options, and editable examples. Prefer prefixed names with a
wildcard import, or the scoped `ambrosia` API when combining libraries.

## Slides

These helpers keep the same names inside `ambrosia`, such as
`ambrosia.title-slide()` and `ambrosia.slide(...)`.

| Helper | Purpose | Guide |
| --- | --- | --- |
| `slide` | Ordinary content; two positional bodies create columns. | [Composition](presentation-patterns.md#compose-ordinary-content) |
| `title-slide` | Opening metadata and logos. | [Title Layouts](title-layouts.md) |
| `outline-slide` | Fitted presentation overview. | [Agendas](agendas.md) |
| `new-section-slide` | Current-section agenda; automatic transition by default. | [Agendas](agendas.md#select-and-fit) |
| `section-slide` | Simple counted divider. | [Slide Helpers](presentation-patterns.md) |
| `focus-slide` | Central message with frozen slide counter. | [Slide Helpers](presentation-patterns.md) |
| `image-slide` | Full-page image and caption/credit placement. | [Image Slides](image-slides.md) |
| `bibliography-slide` | Visible reference list. | [Citations](citations.md) |
| `ending-slide` | Closing content, contacts, and marks. | [Ending Layouts](ending-layouts.md) |
| `backup-slide` | Interlude with frozen slide counter. | [Slide Helpers](presentation-patterns.md) |
| `appendix` | Show rule starting a separately numbered appendix. | [Appendix Numbers](people.md#appendix-numbers) |

## Components

| Global names | Scoped equivalents | Guide |
| --- | --- | --- |
| `ambrosia-block` | `ambrosia.block` | [Block Styles And Kinds](utilities.md#block-styles) |
| `ambrosia-badge`, `ambrosia-source-note` | `ambrosia.badge`, `ambrosia.source-note` | [Text And Annotations](utilities.md#text-and-annotations) |
| `alert`, `muted`, `subtle` | Same names inside `ambrosia` | [Text And Annotations](utilities.md#text-and-annotations) |
| `ambrosia-shadow` | `ambrosia.shadow` | [Shadows](utilities.md#block-styles) |
| `footcite`, `hidden-bibliography` | Same names inside `ambrosia` | [Citations](citations.md) |
| `ambrosia-affiliation` | `ambrosia.affiliation` | [Linked Affiliations](people.md#linked-affiliations) |
| `ambrosia-roadmap` | `ambrosia.roadmap` | [Roadmaps](roadmap.md) |
| `ambrosia-palette-showcase` | `ambrosia.palette-showcase` | [Palettes](palettes.md) |
| `ambrosia-slide-preview` | `ambrosia.slide-preview` | [Linked Slide Previews](slide-previews.md) |
| `ambrosia-navigation-buttons` | `ambrosia.navigation-buttons` | [Transparent Buttons](navigation.md#transparent-buttons) |
| `ambrosia-credit-card` | `ambrosia.credit-card` | [Theme Credits](credits.md) |

## Configuration And Descriptors

| Global names | Scoped equivalents | Guide |
| --- | --- | --- |
| `ambrosia-theme` | `ambrosia.theme` | [Configuration Layers](configuration.md) |
| `config-info` | `ambrosia.config-info` | [Authors And Institutions](people.md) |
| `ambrosia-flavor` | `ambrosia.flavor` | [Flavors](flavors.md) |
| `ambrosia-palette` | `ambrosia.palette` | [Palettes](palettes.md) |
| `ambrosia-navigation` | `ambrosia.navigation` | [Navigation](navigation.md) |
| `ambrosia-title-layout` | `ambrosia.title-layout` | [Title Layouts](title-layouts.md#adjust-a-preset) |
| `ambrosia-ending-layout` | `ambrosia.ending-layout` | [Ending Layouts](ending-layouts.md#adjust-a-preset) |
| `config-common`, `config-store`, `config-page`, `config-colors` | Same names inside `ambrosia` | [Configuration Layers](configuration.md#choose-the-right-configuration-layer) |

Touying configuration and animation helpers are re-exported. Start with
[content and reveals](getting-started.md#add-content-and-reveals) for `pause`
and the [Touying documentation](https://touying-typ.github.io/) for their full API.
Its re-exported `speaker-note` (`ambrosia.speaker-note`) is covered separately
in [Extras: Presenter Notes With Touying](speaker-notes.md).
`agenda-style` configures overview and automatic section-divider bodies
together; either helper accepts a local `style:` override.

## Imports

The scoped import is convenient when combining packages:

```typst
#import "@preview/touying-ambrosia:0.1.0": ambrosia-theme, ambrosia
#show: ambrosia-theme.with(
  flavor: "minimal", palette: "ocean",
  ambrosia.config-info(title: [Research], author: [Presenter]),
)
#ambrosia.title-slide()
#ambrosia.slide(title: [A Result])[
  #ambrosia.block(style: "poster", kind: "success", title: [Result])[Evidence.]
]
```

A wildcard import remains available. If importing Touying directly too, import
Ambrosia after it to select Ambrosia's presentation overrides.

Institution wrappers use the supported `extensions` module and
`ambrosia-flavor` builder; see [Create Your Own Theme](extensions.md).
Other internal source paths are implementation details.
