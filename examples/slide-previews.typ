#import "@preview/touying-ambrosia:0.1.0": *

// Bundled SVG snapshots make this example work immediately in CLI and IDE preview.
// They are static captures: regenerate them after changing a target slide with:
// python scripts/render-slide-previews.py examples/slide-previews.typ --root . --output-dir assets/slide-previews
// For your own deck, keep generated files under target instead (see the guide).
#let show-previews = true // false shows explicit, clickable placeholders
#let preview-directory = "../assets/slide-previews" // relative to this source file
#let show-previews = sys.inputs.at("slide-previews", default: if show-previews { "true" } else { "false" }) == "true"
#let preview-directory = sys.inputs.at("slide-preview-directory", default: preview-directory)
#let files = if show-previews { json(preview-directory + "/manifest.json").files } else { none }
#let thumbnail(target, frame) = if files == none { none } else {
  image(preview-directory + "/" + files.at(str(target) + ":" + str(frame)), width: 100%, height: 100%, fit: "contain")
}
#let preview(target, frame: "first", caption: none) = ambrosia-slide-preview(target,
  frame: frame, thumbnail: thumbnail(target, frame), width: 100%, caption: caption)
#show: ambrosia-theme.with(flavor: "minimal", palette: "ocean",
  navigation-buttons: true,
  config-common(new-section-slide-fn: none),
  config-info(title: [Linked Slide Previews], author: [Presenter]))

= A Connected Talk
== The Main Idea <main-idea>
#ambrosia-block(style: "poster", kind: "info", title: [One Useful Idea])[
  Explain the idea, then connect it to a later result.
]
#footcite(<knuth84>)
#pause
This is the final animation frame of the idea slide.

== Connections
// Links can point backwards or forwards. Only the target slide's static SVG
// enters this page: its headings, counters, footnotes, and links are not replayed.
#grid(columns: (1fr, 1fr), gutter: 1em,
  preview(<main-idea>, frame: "last", caption: [Return To The Main Idea]),
  preview(<result>, caption: [Jump Ahead To The Result]))

== The Result <result>
#ambrosia-block(style: "stripe", kind: "success", title: [Result])[
  Evidence supports the main idea.
]
#hidden-bibliography("bibliography.bib")
