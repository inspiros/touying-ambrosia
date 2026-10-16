# Ending Layouts

Use `ending-layout` in the theme or `ending-slide(layout: ...)` on one slide.
`auto` follows the flavor, including a custom ending renderer. An explicit native
layout overrides that renderer. The scoped constructor is `ambrosia.ending-layout`.
Try the [editable example](../examples/ending-layouts.typ).

| Preset | Arrangement |
| --- | --- |
| `"centered"` | Centered question/thanks panel, body, and contacts. Inherits the flavor's panel treatment. |
| `"plain"` | Left-aligned typography, body, and contacts without a title panel. |
| `"split"` | Takeaways or next steps on the left; logo and contacts in a quiet card on the right. |
| `"cover"` | Full-page palette color or optional photograph, contrasting text, and no ordinary chrome. |

```typst
#show: ambrosia-theme.with(
  ending-layout: "split",
  config-info(title: [My Talk], author: [Presenter], email: "person@example.org"),
)
#ending-slide(title: [Questions?])[
  - One result to remember.
  - One useful next step.
]
```

Endings remain counted logical slides. Their positional bodies retain native
paragraphs, figures, links, footnotes, citations, and Touying reveals. Bodies stay
in normal slide flow; automatic title-metadata fitting does not shrink an ending's
body. Give dense concluding material a separate ordinary slide.

## Logos And Contacts

`ending-logos: auto` collects `primary-logos` (falling back to `config-info(logo: ...)`), so an ending does not
automatically repeat every partner mark from the opening. The centered/plain
presets hide that collection; split puts it in the contact card, and cover places
it above the title. Set `ending-logos` globally or `ending-slide(logos: ...)`
locally for a complete ordered collection. `none` hides it.

By default, shared `emails` / `email` metadata is preferred. Otherwise authors'
personal addresses are collected. Duplicates are removed and string addresses
retain their mailto links. `contacts: ("group@example.org",)` replaces that list
locally, and `contacts: none` hides it. These are email fields; use native links
in the body for a project website, materials, or a social profile.

If a split ending has neither contacts nor side logos, its side column vanishes.
No empty contact card is retained. A native image or QR code can be placed in
the body without a separate specialized ending preset.

## Adjust A Preset

```typst
#let closing = ambrosia-ending-layout(base: "split", name: "contact-card",
  side-width: 38%, logo-height: 2em, title-size: 1.7em)
#ending-slide(layout: closing, title: [Keep In Touch],
  contacts: ("group@example.org",))[
  #link("https://example.org/project")[Project And Materials]
]
```

Descriptor keys follow the [title-layout](title-layouts.md) vocabulary:

| Options | Purpose |
| --- | --- |
| `composition`, `alignment` | `"centered"` or `"split"`; left/center/right text alignment. |
| `logos-placement`, `logos-align`, `logo-height`, `logo-columns`, `logo-gap` | None/above/below/side placement and bounded logo geometry. |
| `title-background`, `title-text`, `title-shadow`, `title-width` | `auto` follows the flavor; explicit values override it. |
| `title-size`, `title-inset`, `title-radius`, `gap` | Typography and spacing, using `em` by default. |
| `side-width`, `side-background` | Width ratio and fill of the contact card. |
| `immersive`, `page-background`, `foreground` | Page chrome, fill, and body ink. |
| `background-image`, `background-overlay` | Optional native image content and its contrast overlay. |

Surface/ink options accept values or `self => value` callbacks. Logo callbacks
receive `self.store.logo-background`. Native links and footnotes choose readable
ink when a special slide changes the page fill. Custom title text colors remain
the caller's responsibility.

Photograph covers use the same native-image setup as title covers. Background
decoration follows the slide in presenter notes and second-screen output.

Flavors can preset `ending-layout`; fully custom renderers retain the existing
`ending-renderer(self: none, config: (:), title: none, body)` contract. Existing
wrappers need no copied renderer to use the native presets.
