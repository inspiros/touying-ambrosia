# What A Flavor Defines

A flavor is a coordinated presentation-style preset. It supplies the visual
composition of a talk: header and footer treatment, title/ending-slide geometry,
logo positions, spacing, heading conventions, and default block/watermark
appearance. Choosing one is a convenient starting point; individual settings
remain overridable.

Cambridge and Darmstadt are Ambrosia compositions inspired by Beamer's visual
styles. They are not intended as exact ports. Their default navigator is part
of the preset, and a different navigator can be chosen independently. Future
flavors can add visual compositions without duplicating navigation components.

The configuration separates these responsibilities:

| Choice | Responsibility |
| --- | --- |
| `flavor` | Composition and visual treatments, including a suggested navigator |
| `palette` | Semantic colors used by those treatments and components |
| Branding | Logos, institutions, authors, and watermark artwork |
| `navigation` | A navigation arrangement with its own space reservation |
| `title-layout` | Cover composition overriding the flavor's suggested layout |
| `ending-layout` | Closing composition overriding the flavor's suggested layout |

A flavor can choose **where semantic colors are used**, such as an accent-filled
header, without specifying literal colors. A palette supplies those colors.
Similarly, a flavor suggests navigation through `navigation: auto`; choosing a
different navigator replaces that suggestion and adjusts the reserved space.
Buttons and progress indicators are independent additions.

Title composition has the same override model: `title-layout: auto` follows the
flavor, while a native layout or descriptor changes the opening without a new
flavor. Per-slide `title-slide(layout: ...)` is more specific. See
[title layouts](title-layouts.md) for header-only logos, side branding, and plain
typographic covers.

Endings follow the same pattern through `ending-layout` and per-slide `layout`;
see [ending layouts](ending-layouts.md).

## The Portico Preset

Portico coordinates a narrow metadata band, flat cover/blocks, compact footer,
and an optional contrasting outline panel. It defaults to a transparent right-hand sidebar; use
`navigation-side: "left"` to move it. Like a portico framing an entrance, the
panel frames the talk without competing with its content.

`sidebar-background: none` keeps its outline column transparent by default. Set
`auto` to enable the palette-based panel treatment, or supply a solid color.
Its width and label padding remain the same; the label ink adapts to the surface.

Its panel uses the palette's `chrome`, `on-chrome`, and `chrome-muted` roles.
It remains distinct on light and dark pages, with inset labels clear of the
panel edges. These are the flavor's existing `navigation-background`,
`navigation-primary`, and `navigation-secondary` callbacks; custom flavors can
reuse them without another styling API.

`flavor: "minimal", navigation: "sidebar"` retains Minimal's quiet title band,
logo, cover/watermark presets, compact footer, and transparent outline column.
`flavor: "portico", navigation: none` keeps Portico's metadata band, flat
surfaces, and spacing while reclaiming the full body width. Choosing a header
navigator instead uses Portico's contrasting navigation colors there.

There is no need for a flavor per navigator or per palette. Add a flavor when a
coordinated composition earns a name; use a navigation descriptor when only the
wayfinding arrangement changes. See [navigation](navigation.md) and
[custom flavors](extensions.md).
