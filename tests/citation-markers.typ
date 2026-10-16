#import "../src/lib.typ": *
#let mode = sys.inputs.at("marker", default: "author-year")
#show: ambrosia-theme.with(
  flavor: "minimal", palette: "ocean", footcite-marker: mode,
  config-info(title: [Stable citations], author: [Tester]),
)

== Revealed source
#uncover("2-")[Revealed source #footcite(<knuth84>, label: <knuth-note>).]
Ordinary note #footnote[Ordinary first slide note.]
#pause
Second frame.
#pause
Duplicate #footcite(<knuth84>). Note alias @knuth-note.

== A different work from the same year
Second work #footcite(<knuth1984programming>).
First work again #footcite(<knuth84>).
Ordinary note #footnote[Ordinary second slide note.]
#hidden-bibliography("fixtures/markers.bib")

== Independent first scope
#footcite(<shared>, scope: "first")
#hidden-bibliography("fixtures/first.bib", scope: "first", group: none)

== Independent second scope
#footcite(<shared>, scope: "second")
#hidden-bibliography("fixtures/second.bib", scope: "second", group: none)

== Overrides and anonymous sources
#ambrosia-block(style: "poster", title: [Markers inside blocks])[
  First author #footcite(<multi>).
  Anonymous #footcite(<anonymous>).
  Custom #footcite(<multi>, marker: [ManualKey], label: <manual-note>).
  Custom reference @manual-note.
  Explicit key #footcite(<knuth84>, marker: "key").
]

== Native YAML sources
#footcite(<yaml-entry>, scope: "yaml")
#hidden-bibliography("fixtures/markers.yml", scope: "yaml", group: none)
