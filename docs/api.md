# Public API

Use the prefixed names with wildcard imports, or the scoped `ambrosia` API when combining libraries.

| Family | Global names | Scoped equivalents |
| --- | --- | --- |
| Theme | `ambrosia-theme`, `ambrosia-flavor` | `ambrosia.theme`, `ambrosia.flavor` |
| Title composition | `ambrosia-title-layout` | `ambrosia.title-layout` |
| Ending composition | `ambrosia-ending-layout` | `ambrosia.ending-layout` |
| Colors | `ambrosia-palette`, `ambrosia-palette-showcase` | `ambrosia.palette`, `ambrosia.palette-showcase` |
| Credits | `ambrosia-credit-card` | `ambrosia.credit-card` |
| Slide previews | `ambrosia-slide-preview` | `ambrosia.slide-preview` |
| Diagrams | `ambrosia-roadmap` | `ambrosia.roadmap` |
| Navigation | `ambrosia-navigation`, `ambrosia-navigation-buttons` | `ambrosia.navigation`, `ambrosia.navigation-buttons` |
| Metadata | `config-info`, `ambrosia-affiliation` | `ambrosia.config-info`, `ambrosia.affiliation` |
| Presentation | `slide`, `title-slide`, `outline-slide`, `new-section-slide`, `section-slide`, `image-slide`, `focus-slide`, `ending-slide`, `backup-slide` | Same names inside `ambrosia` |
| References | `footcite`, `bibliography-slide`, `hidden-bibliography` | Same names inside `ambrosia` |
| Touying conventions | `alert`, `appendix`, configuration and animation helpers | Same names inside `ambrosia` |
| Text hierarchy | `muted`, `subtle` | `ambrosia.muted`, `ambrosia.subtle` |
| Custom containers/annotations | `ambrosia-block`, `ambrosia-badge`, `ambrosia-source-note`, `ambrosia-shadow` | `ambrosia.block`, `ambrosia.badge`, `ambrosia.source-note`, `ambrosia.shadow` |

The scoped import is convenient when combining several packages:

```typst
#import "@preview/touying-ambrosia:0.1.0": ambrosia-theme, ambrosia
#show: ambrosia-theme.with(
  flavor: "minimal", palette: "ocean",
  ambrosia.config-info(title: [Research], author: [Presenter]),
)
#ambrosia.title-slide()
#ambrosia.slide(title: [A result])[
  #ambrosia.block(style: "poster", kind: "success", title: [Result])[Evidence.]
]
```

A wildcard import remains available; if directly importing Touying as well, import Ambrosia after it to select Ambrosia's presentation overrides.

The entrypoint exports the intended custom API explicitly. Institution wrappers use the supported `extensions` module and `ambrosia-flavor` builder. Other internal source paths are implementation details.

`agenda-style` configures overview and automatic section-divider bodies together; either helper accepts a local `style:` override. See [agendas](agendas.md).
