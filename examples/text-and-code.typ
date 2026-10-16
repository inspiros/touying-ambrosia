#import "@preview/touying-ambrosia:0.1.0": *

// Edit these settings in an IDE to compare the same content live.
#let palette = "ocean" // try midnight, rose, or graphite
#let code-style = "surface" // plain retains native raw layout
#let quote-style = "stripe" // plain retains native block quotation layout
#show: ambrosia-theme.with(
  palette: sys.inputs.at("palette", default: palette),
  code-style: code-style, quote-style: quote-style, font: "DejaVu Sans",
  config-info(title: [Text, Code, And Quotations], author: [Alex Researcher]),
)

#slide(title: [A Clear Text Hierarchy])[
  Regular text, #alert[an important phrase], #muted[secondary context],
  and #subtle[an optional aside]. All inherit the surrounding size.

  #text(size: 1.2em)[Larger text keeps #ambrosia.muted[the same proportions].]

  #ambrosia-block(style: "stripe", title: [Inside A Container])[
    #muted[The text adapts to the panel's surface.]
    #pause
    #subtle[Reveals still work inside the helper.]
  ]
]

#slide(title: [Native Code, Styled])[
  Inline `score(item)` remains inline. Fenced code receives a bounded panel:

  ```python
  def score(item):
      """Keep the original language and syntax highlighting."""
      return item.value / item.cost
  ```

  #muted[Use native raw options for language, theme, or tabs.]
]

#slide(title: [A Quotation With Context])[
  Inline #quote[quotation marks] retain native Typst behavior.

  #quote(block: true, attribution: link("https://typst.app/")[Example Attribution])[
    A useful quotation deserves its context and source.
    #footnote[An ordinary footnote remains an ordinary footnote.]
  ]

  #subtle[Sample quotation, written for this example.]
]
