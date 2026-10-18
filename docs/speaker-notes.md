# Extra: Presenter Notes With Touying

Presenter notes and notes-output modes come from **Touying** and are
re-exported by Ambrosia. This optional workflow is independent of the theme.
You can use a compatible presenter viewer or editor; pdfpc is one option.
See [Touying's documentation](https://touying-typ.github.io/) for its broader
presentation and export workflows.

`speaker-note` stores notes alongside the slide content:

```typst
#slide(title: [The Main Result])[
  A short statement for the audience.
  #speaker-note[Explain the motivation.]
  #pause
  The evidence appears.
  #speaker-note[Pause for questions.]
]
```

Notes accumulate across frames. `speaker-note(subslide: 1)[...]` restricts a note
to the first frame; `subslide: none` applies it to every frame.

## Choose An Output

| Output | Use |
| --- | --- |
| Ordinary PDF with note metadata | Audience slides; a compatible tool must read the notes separately. |
| Split slide/notes PDF | Presenter software that separates the page into audience and notes regions, such as pympress or pdfpc. |
| Notes-only document | Rehearsal or printing. |

An ordinary PDF viewer has no private presenter pane. With a split PDF it
shows **both halves**; use presenter software and an extended display to send
only the slide region to the audience. Share the ordinary PDF without visible
notes when distributing the deck.

## One Option: Private Notes In pdfpc

With the default theme settings, notes are metadata and are not painted into the
PDF. For a source named `talk.typ`:

```sh
typst compile talk.typ talk.pdf
typst eval --in talk.typ 'query(<pdfpc-file>).first().value' > talk.pdfpc
pdfpc --notes=none talk.pdf
```

Keep the PDF and sidecar together with matching stems. Use the same root/input
settings for both exports and regenerate them after edits. Leave `enable-pdfpc`
enabled. `speaker-note(mode: "md")` exports Markdown; arbitrary Typst graphics
are better suited to typeset notes.

## Touying's Typeset Notes And Handouts

| `config-common` option | Output |
| --- | --- |
| `show-notes-on-second-screen: right` | Slide left, typeset notes right. Also accepts `left`, `top`, `bottom`. |
| `show-only-notes: true` | Rehearsal/print notes with slide thumbnails. |
| `handout: true` | Final animation frame of each logical slide. |

For a split PDF, select its notes region in your presenter software. In pdfpc,
use `--notes=right` (or the corresponding side).

Project the audience window. In pdfpc, `--switch-screens` exchanges the
displays. A notes-only document does not synchronize a second audience PDF
on its own.

## Optional Bundle Export

The [editable notes example](../examples/speaker-notes.typ) includes an opt-in
Typst bundle that writes the PDF and sidecar together:

```sh
typst compile --features bundle --format bundle --root . \
  --input bundle=true --input output=audience \
  examples/speaker-notes.typ target/speaker-bundle
```

Bundle export is experimental; ordinary compile/eval remains available.
