# Optional Theme Credits

<!-- ambrosia-example: credits -->
[Editable source](site/examples/credits.typ).
<!-- /ambrosia-example -->

```typst
#ambrosia-credit-card() // or ambrosia.credit-card()
#ambrosia-credit-card(qr: false, width: 60%)
```

The card gives interested audience members a way to find the theme. It is never
added automatically. Place it in an ordinary slide, an ending, or beside an
acknowledgement block. Its logo follows the card's surface color. Package names,
logos, and QR codes are native clickable links in the exported PDF.

The bundled QR points to the repository, which works before Universe publication
and can keep directing readers to the current release, installation instructions,
and examples. There is no version in that URL. A future switch to Universe is
optional; existing printed codes can keep working through the repository README.

The QR is a static black-on-white SVG with medium error correction and a
four-module white quiet zone. It stays legible on dark palettes. Typst Universe
and IDE consumers need no script, network request, or extra package to render it.
`qr-size` defaults to `4.5em`; avoid making it too small for your viewing distance.

| Option | Behavior |
| --- | --- |
| `width: 100%` | Fill the containing column; a native length/ratio can reduce it. |
| `qr: true` | Use the project's bundled QR; omit it if none was provided. |
| `qr: false` | Hide the QR and release its column. |
| `qr: content` or callback | Contain user-supplied QR artwork in the same square. |
| `qr-size: 4.5em` | Square size, including the QR's own quiet zone. |
| `title`, `link-label` | Customize/localize the “Made with Typst” and “Source and Examples” labels. |
| `project: auto` | Use the theme's credit identity, or pass a descriptor. |

Institution wrappers supply a descriptor through `config-store(credit-project: ...)`:

```typst
#let project = (
  name: "My Institution Theme",
  url: "https://example.org/theme",
  logo: image("theme.svg"),
  qr: image("theme-qr.svg"), // optional; must encode the same URL
  based-on: (name: "Touying Ambrosia", url: "https://github.com/inspiros/touying-ambrosia"),
)
#ambrosia-credit-card(project: project)
```

Only `name` and `url` are required. Supplying a different URL never reuses the
default project's QR. Institution packages should resolve their own assets to
image content/bytes, so consumer paths stay independent of the package directory.
A wrapper can supply its own identity and add a link to the neutral core.

Acknowledgements vary between names, paragraphs, funder logos, and detailed
contribution lists. A normal `ambrosia-block` with `style: "outlined"` or
`"plain"` preserves that flexibility; no special slide type is required.
See the editable [example](../examples/credits.typ).
