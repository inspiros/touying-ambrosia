# Speaker Notes

`speaker-note` stores presenter notes. Keep an ordinary slide PDF and export a
matching `.pdfpc` sidecar for private notes in pdfpc:

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

## Private Presenter View

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

## Typeset Notes And Handouts

| `config-common` option | Output |
| --- | --- |
| `show-notes-on-second-screen: right` | Slide left, typeset notes right. Also accepts `left`, `top`, `bottom`. |
| `show-only-notes: true` | Rehearsal/print notes with slide thumbnails. |
| `handout: true` | Final animation frame of each logical slide. |

For a split PDF, launch pdfpc with `--notes=right` (or the corresponding side).
Opening it in an ordinary viewer shows **both halves**. Share the ordinary PDF
when distributing slides without visible notes.

Use an extended desktop and project the audience window. `pdfpc --switch-screens`
exchanges the displays. A notes-only PDF needs an external synchronized viewer;
it does not make ordinary PDF content private.

## Optional Bundle Export

The [editable notes example](../examples/speaker-notes.typ) includes an opt-in
Typst bundle that writes the PDF and sidecar together:

```sh
typst compile --features bundle --format bundle --root . \
  --input bundle=true --input output=audience \
  examples/speaker-notes.typ target/speaker-bundle
```

Bundle export is experimental; ordinary compile/eval remains available.
