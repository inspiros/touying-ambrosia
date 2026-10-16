#import "../src/lib.typ": *
#show: ambrosia-theme.with(
  flavor: "simple",
  footcite-marker: "local",
  footcite-once: sys.inputs.at("once", default: "true") == "true",
  config-info(title: [Citation regression], author: [Tester]),
)

== Animated citation
Before the citation.
#pause
First visible citation #footcite(<knuth84>).
#pause
Repeated citation #footcite(<knuth84>).
Ordinary note #footnote[Ordinary footnote after duplicate.]

== Later citation
Later citation #footcite(<knuth84>).
Standalone note #footnote[Standalone ordinary footnote.]
#hidden-bibliography("../examples/bibliography.bib")

== First bibliography
First source #footcite(<shared>, scope: "first", label: <first-note>, numbering: "a").
Explicit footnote reference @first-note.
#hidden-bibliography("fixtures/first.bib", scope: "first", group: none)

== Second bibliography
Second source #footcite(<shared>, scope: "second").
#bibliography-slide("fixtures/second.bib", scope: "second", group: none, title: [Second references])

== Repeated scopes
First again #footcite(<shared>, scope: "first").
Second again #footcite(<shared>, scope: "second").
