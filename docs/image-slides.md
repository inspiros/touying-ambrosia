# Image Slides And Caption Placement

`image-slide` fills a counted slide with an image and hides page chrome.
`fit: "cover"` fills the page; `"contain"` keeps the complete image. Source paths,
`alt`, and other image arguments retain native Typst behavior and resolve from
the calling document.

The default remains a bottom band:

```typst
#image-slide("photos/lab.jpg",
  caption: [A Place To Explore], credit: [Photo: institution],
  alt: "A view of the laboratory",
)
```

Use native alignment values for placement. A narrower width and outer margin
turn the band into an inset card:

```typst
#image-slide("photos/lab.jpg",
  caption: [A Place To Explore],
  credit: [Photo: #link("https://example.org")[Source]],
  caption-position: top + right,
  caption-width: 42%,
  caption-margin: 1em,
  alt: "A view of the laboratory",
)
```

| Option | Default | Meaning |
| --- | --- | --- |
| `caption-position` | `bottom` | Native alignment: `top`, `bottom + right`, or even `center + horizon`. An omitted horizontal axis uses left; an omitted vertical axis uses bottom. |
| `caption-width` | `100%` | Percentage of the region after margins, an absolute/`em` length, or a relative length such as `50% - 1em`. |
| `caption-margin` | `0em` | Outer inset. Accepts native lengths/percentages or dictionaries, e.g. `(left: 2em, right: 1em, y: 1em)`. |
| `caption-fill` | `auto` | Translucent palette chrome. A color/gradient replaces it; `none` removes the panel. |
| `caption-text-fill` | `auto` | Palette text for the default panel; readable text for an explicit solid fill. Explicit colors override it. Links follow the same fill. |

For a top band use `caption-position: top`. For either corner, set its native
alignment and choose a narrower width. Text inside the panel remains left
aligned; placement controls the panel's location rather than paragraph alignment.
Caption-only and credit-only panels work; omitting both draws only the image.

A white card automatically chooses dark text. With `caption-fill: none` or a
custom gradient, set `caption-text-fill` to suit the photograph. Automatic
contrast does not analyze image pixels; review text over the actual image.

Margins, panel padding, caption size (`0.9em`), and credit size (`0.65em`)
follow the presentation text size. The panel is measured and must fit inside
the inset image region. An excessive width or height produces a diagnostic
instead of silently clipping the caption or adding another slide.

Reuse a local preset with ordinary function composition:

```typst
#let image-card = image-slide.with(
  caption-position: bottom + right, caption-width: 42%, caption-margin: 1em,
)
#image-card("photos/lab.jpg", caption: [Our Laboratory])
```

See the [editable comparison](../examples/image-slides.typ). Its defaults can be
changed directly in an IDE; no command-line flags or export script are required.
