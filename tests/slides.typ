#import "../src/lib.typ": *
#import "../src/lib.typ": extensions as ambrosia-utils

#let flavor = sys.inputs.at("flavor", default: "minimal")
#let slide-level = if flavor == "cambridge" { 3 } else { 2 }
#let mode = sys.inputs.at("mode", default: "slides")
#set text(lang: sys.inputs.at("lang", default: "en"))
#set heading(numbering: "1.1")
#show: ambrosia-theme.with(
  flavor: flavor,
  palette: sys.inputs.at("palette", default: "light"),
  aspect-ratio: sys.inputs.at("aspect-ratio", default: "16-9"),
  config-common(
    handout: mode == "handout",
    show-only-notes: mode == "notes",
    show-notes-on-second-screen: if mode == "second-screen" { right } else { none },
  ),
  config-info(
    title: [Ambrosia regression deck],
    subtitle: [Flavor: #flavor],
    author: [Test author],
    institution: [Kyklo],
    date: datetime(year: 2026, month: 10, day: 13),
  ),
)

// Queryable semantic observations complement rendered-slide comparisons.
#let record(id) = context {
  [#metadata((
    id: id,
    slide: utils.slide-counter.get().first(),
    total: utils.last-slide-counter.final().first(),
    page: here().page(),
    heading: counter(heading).get(),
    main-outline: query(ambrosia-utils.before-appendix-filter(heading.where(outlined: true))).map(it => repr(it.body)),
    current-outline: query(ambrosia-utils.appendix-filter(heading.where(outlined: true))).map(it => repr(it.body)),
  )) <ambrosia-test>]
}

#title-slide()
#outline-slide()

= Main section

Section introduction stays on its section slide.

#heading(depth: slide-level)[Main slide]

#record("main")
A main slide with #alert[important information].
#speaker-note[Presenter note for the main slide.]

#[
  - First list item.
  - Second list item.
]

#pause
Revealed on the second animation frame.

#heading(depth: slide-level)[Blocks and citations]

#record("main-next")
#grid(columns: (1fr, 1fr), gutter: 1em,
  ambrosia-block(title: [Plain block], shadowed: false)[Block content.],
  ambrosia-block(style: "framed", title: [Framed block])[Block content.],
)

#footcite(<knuth84>)
#hidden-bibliography("../examples/bibliography.bib", style: "ieee")

#ending-slide(title: [The end])[
  #record("ending")
  Thank you.
]

#show: appendix.with(numbering: sys.inputs.at("appendix-numbering", default: none))

= Backup section

#heading(depth: slide-level)[Backup slide]

#record("appendix")
Appendix body must remain visible after the show rule.

#heading(depth: slide-level)[Second backup slide]

#record("appendix-next")
Another appendix body with a normal #footnote[Backup footnote.].

#backup-slide(title: [Explicit backup])[
  #record("explicit-backup")
  The explicit backup helper remains available.
]
