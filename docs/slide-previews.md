# Linked Slide Previews

`ambrosia-slide-preview` (or `ambrosia.slide-preview`) makes a small framed thumbnail that links to a labeled slide. It can point backwards or forwards and select an animation frame. See [the editable example](../examples/slide-previews.typ).

```typst
#ambrosia-slide-preview(<result>,
  thumbnail: image("previews/result.svg"), width: 35%,
  caption: [Jump To The Result], frame: "first")
```

Label a slide heading (`== The Result <result>`) or put a zero-size native anchor inside an explicit slide: `#slide(title: [Result])[#metadata(none)<result> ...]`. A label attached only to the outer `#slide[...]<result>` wrapper is reserved by Touying for recall and is not a queryable page anchor. Labels should be unique to the target slide. With no `thumbnail`, the helper renders a clickable frame labeled "Preview Not Exported", so the document can be edited before any images are generated. It does not capture the target automatically. The supplied thumbnail is ordinary content; using native `image(...)` keeps its path relative to the caller.

The frame defaults to `"first"`. Use `"last"` or a positive integer to select a later frame. Logical-slide metadata determines the frame range even when the heading label occurs only on the first frame. The destination is a native PDF page link to that selected frame. If the target label first appears after a reveal, counting starts at its first visible occurrence.

## Two Separate Passes

1. **Capture:** the optional Python helper queries the component's target/frame
   metadata, asks Typst to export each requested physical page as SVG, then writes
   a manifest mapping requests to files. Preview loading is disabled in this
   pass, which also avoids recursive thumbnail capture.
2. **Presentation:** normal Typst compilation reads those SVGs with `image(...)`
   and places each in a linked frame. It resolves the destination from the live
   document's labels and slide metadata. It does not export or save images.

The SVGs are persistent build artifacts, normally under the ignored `target`
folder; they are not recreated on each compile. They can also be checked in for
an example or shared deck. The shipped example does that under
`assets/slide-previews`. Regenerate them when their target content changes.

## Why An Export Step

Typst can query a heading or labeled element, but it does not expose a completed page as a reusable image during the same compilation. Touying's `touying-recall` replays slide content and page behavior; it is not a static thumbnail API. Re-laying out the source body inside a box can change geometry or duplicate counters, citation instances, headings, and navigation metadata.

An exported SVG preserves the actual slide, including its header/footer, colors, diagrams, and selected animation state. Embedded as an image, it contributes no live headings/counters/citations to the host slide. The whole frame has one deliberate link; miniature buttons and links inside the image are static artwork.

## Optional Export Helper

### Get It Without Cloning

Download just
[render-slide-previews.py](https://github.com/inspiros/touying-ambrosia/raw/refs/heads/master/scripts/render-slide-previews.py)
from the project repository. GitHub's **Raw / Download** action also saves the
single file. Run `python3 render-slide-previews.py --help` after downloading it;
the file needs Python 3.9+ and the Typst CLI, with no third-party Python packages.
The repository commands below use its original `scripts/` location; substitute
your downloaded file's path. A repository clone and PyPI package are unnecessary.

The Universe import cannot execute that helper. For browser-only editing, use an
uploaded slide image or the clickable placeholder. Exact snapshots need a local
export pass somewhere; upload the generated SVGs and manifest to the browser
project, and point its thumbnail helper to those files. They remain static until
exported again. Packaging the helper on PyPI would make local installation more
convenient but would not enable execution inside the web editor.

The starter includes a short README pointing to this workflow. The theme itself
keeps working without Python or generated thumbnails.

The example includes two small SVG snapshots under `assets/slide-previews`.
It shows real thumbnails immediately in both CLI compilation and IDE preview;
no command-line inputs or initial export are needed. Set `show-previews = false`
to see the explicit placeholders. These snapshots are static, so editing their
target slides does not update the miniature images until you export again.

To refresh the bundled example snapshots, run from the project root:

```sh
python scripts/render-slide-previews.py examples/slide-previews.typ --root . --output-dir assets/slide-previews
```

For your own deck, copy the small `thumbnail`/`preview` helpers and the
`slide-previews` input switch. Start with `show-previews = false`. Export to the
ignored build directory:

```sh
python scripts/render-slide-previews.py examples/slide-previews.typ --root .
```

The script exports the selected physical pages as SVG and writes
`target/slide-previews/manifest.json`. Then set `preview-directory` to
`"../target/slide-previews"` (relative to your source file) and `show-previews` to
`true`. Refresh the IDE preview. For the shipped example, the equivalent CLI is:

```sh
typst compile --root . --input slide-previews=true --input slide-preview-directory=../target/slide-previews examples/slide-previews.typ target/slide-previews.pdf
```

The helper uses the existing Typst CLI and Python standard library. Multiple
requests for the same target/frame share one generated image. It deliberately
sets `--input slide-previews=false` while capturing, so that pass never reads
thumbnail assets or recursively captures earlier thumbnails. `--input key=value`
forwards other source settings; `--package-path` supports isolated development
installs, and `--output-dir` changes the generated folder within the document
root. Keep the source's manifest/image paths in agreement with that folder.

Regenerate after changing target content, frame counts, layout, palette, or
output mode. This is a build artifact workflow rather than automatic live
capture in the IDE. You can also export a selected slide as SVG yourself and
pass `image("result.svg", width: 100%, height: 100%, fit: "contain")` directly;
the component does not require the script.

## Appearance

`width` defaults to `35%`. In a grid cell, use `width: 100%`. The default aspect ratio follows the host theme; set `aspect-ratio: 4 / 3` for a target with different dimensions. `radius` and `stroke` style the clipped frame, and `caption` adds a smaller linked label below it. Appearance follows the current palette. The thumbnail retains the target slide's own captured colors.
