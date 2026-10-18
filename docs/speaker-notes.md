# Speaker Notes And Presenter Output

Touying's `speaker-note` is already available through Ambrosia. The presentation
viewer decides what goes to each screen. A split-page PDF contains both the slide
and notes on each page; a normal PDF viewer displays that whole page. To get a
private presenter view, use a compatible viewer and tell it which output format
you exported.

The [editable example](../examples/speaker-notes.typ) supports all three modes:

| Example `output` | Export | Intended use |
| --- | --- | --- |
| `"audience"` (default) | Ordinary slides; notes available as metadata | Recommended with a matching `.pdfpc` sidecar |
| `"split"` | Slide and notes on halves of one larger page | pdfpc with `--notes=right`, or another viewer configured to split the page |
| `"notes"` | Notes with a small slide preview | Rehearsal, printing, or a synchronized separate presenter document |

Ambrosia styles the typeset note panel. Touying owns note collection, overlay
selection, and export; pdfpc owns the presenter/audience windows. No extra
Ambrosia notes API or package dependency is needed.

## Write Notes In Your IDE

```typst
#slide(title: [The Main Result])[
  A short statement for the audience.
  #speaker-note[Explain the motivation before showing the evidence.]
  #pause
  The evidence appears.
  #speaker-note[Emphasize the result and pause for questions.]
]
```

In the default output, notes are not painted into the audience PDF. An IDE
preview therefore shows only slides. In the example, change the `output` default
to `"split"` or `"notes"` to inspect the notes without a command-line build.
These are example settings; in your own deck use the Touying controls below.

Multiple notes on the same frame accumulate. Notes before `pause` remain on
later frames, while a note after it first appears on that later frame. For
precise control, `speaker-note(subslide: 1)[...]` limits a note to the first
frame; `subslide: none` applies it to every frame. The `.pdfpc` export also
records which physical PDF pages are overlays of the same logical slide.

## Recommended: Ordinary PDF Plus A pdfpc Sidecar

Keep the normal settings (also their defaults):

```typst
#show: ambrosia-theme.with(
  config-common(
    show-notes-on-second-screen: none,
    show-only-notes: false,
  ),
)
```

The same configuration works with `greyc-theme`. pdfpc metadata is enabled by
default; do not disable `enable-pdfpc` for this workflow.

From the core repository root, compile the example and export its metadata:

```sh
mkdir -p target
typst compile --root . --input output=audience \
  examples/speaker-notes.typ target/speaker-notes.pdf
typst eval --root . --input output=audience --in examples/speaker-notes.typ \
  'query(<pdfpc-file>).first().value' > target/speaker-notes.pdfpc
pdfpc --notes=none target/speaker-notes.pdf
```

For your own source, replace `examples/speaker-notes.typ` and the output stem.
Keep the PDF and sidecar together with matching stems: `talk.pdf` and
`talk.pdfpc`, rather than `talk.pdf.pdfpc`. pdfpc loads the sidecar automatically.
The notes appear in its presenter console, not the audience window. `--notes=none`
means the PDF has no split-page notes region; it does not disable sidecar notes.
Use the same root and input settings for compilation and metadata export, and
regenerate both files after changing the presentation.

pdfpc's sidecar notes are text/Markdown, rather than fully typeset Typst content.
Use `speaker-note(mode: "md")[...]` when exporting markup for pdfpc's Markdown
renderer; arbitrary Typst equations, images, and custom layouts cannot be
reproduced faithfully there. Choose split-page output when those matter.

Optional timer/notes settings use Touying's existing `pdfpc.config` helper. The
example puts it **before the theme show rule**, keeping metadata out of the
slide parser's visible body:

```typst
#pdfpc.config(duration-minutes: 12)
#show: ambrosia-theme.with(/* presentation configuration */)
```

## Split Pages For Typeset Notes

```typst
#show: ambrosia-theme.with(
  config-common(show-notes-on-second-screen: right),
)
```

Touying doubles each page's width, placing the audience slide on the left and
notes on the right. Configure pdfpc to split it:

```sh
typst compile --root . --input output=split \
  examples/speaker-notes.typ target/speaker-split.pdf
pdfpc --notes=right target/speaker-split.pdf
```

`--notes=right` identifies the **notes half**. pdfpc projects the other half and
keeps the notes for the presenter. `left`, `top`, and `bottom` also work: match
the viewer flag to `show-notes-on-second-screen`. Top/bottom layouts double the
page height. The example accepts, for instance, `--input notes-side=bottom`;
launch that result with `pdfpc --notes=bottom`.

Opening a split PDF normally shows both halves. Distribute the ordinary
audience PDF when sharing slides without visible notes.

## Notes-Only And Handouts

`config-common(show-only-notes: true)` produces notes with slide thumbnails.
This is a rehearsal/print document, not a flag telling an ordinary PDF viewer to
hide material from the audience. A two-PDF presenter workflow needs an external
viewer capable of synchronizing the two documents.

`config-common(handout: true)` keeps the final animation frame of each logical
slide. It is independent of notes output. Navigation controls are suppressed in
Ambrosia's handout and notes-only modes.

## Set Up The Two Displays

Use an **extended desktop**, with the presenter console on the laptop and the
audience window on the projector. Desktop mirroring sends the same view to both
screens. If the windows are assigned backwards, use `pdfpc --switch-screens`
alongside the appropriate `--notes` option. For a video call, share the audience
window rather than the presenter console.

## Optional: Export Both Files In One Compilation

Typst 0.15's **experimental bundle export** can emit the PDF and `.pdfpc`
together. The example contains an opt-in branch for it:

```sh
typst compile --features bundle --format bundle --root . \
  --input bundle=true --input output=audience \
  examples/speaker-notes.typ target/speaker-bundle
pdfpc --notes=none target/speaker-bundle/speaker-notes.pdf
```

It produces `speaker-notes.pdf` and `speaker-notes.pdfpc` in the destination
directory. The normal IDE/PDF workflow does not enable that branch. No Python
helper is required. The explicit `bundle=true` input selects the example's
bundle composition; it is not an Ambrosia theme option.

For your own bundle source, put `pdfpc.bundle-assets()` at the bundle's top level
and wrap your deck in `document("talk.pdf", [...])`. Touying supplies both
helpers' integration with the notes metadata. Keep the ordinary compile/eval
workflow as the stable alternative while bundle export remains experimental.

## Verification

```sh
python3 tests/check_speaker_notes.py
python3 tests/check_speaker_notes.py --bundle  # also checks experimental export
```

These checks verify the exported PDF content, page dimensions, sidecar notes,
logical-slide/overlay mapping, and bundle pairing. They do not drive a live
multi-monitor presenter session. They require Typst and Poppler's `pdfinfo` and
`pdftotext`.
