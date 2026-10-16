#import "../src/lib.typ": *
#show: ambrosia-theme.with(
  bibliography-marker: sys.inputs.at("marker", default: "author-year"),
  config-info(title: [Consistent reference labels]),
)
#slide(title: [Two works, one author and year])[
  #footcite(<knuth84>) and #footcite(<knuth1984programming>).
  An ordinary citation #cite(<multi>).
]
#bibliography-slide("fixtures/markers.bib", full: true)
#slide(title: [Another bibliography])[
  #footcite(<shared>, scope: "first") and #footcite(<shared>, scope: "second").
]
#bibliography-slide("fixtures/first.bib", scope: "first", group: none)
#bibliography-slide("fixtures/second.bib", scope: "second", group: none)
#bibliography-slide("fixtures/markers.bib", title: [Explicit native style], style: "ieee", target: <unused>, group: none, full: true)
#bibliography-slide("fixtures/markers.yml", title: [Native YAML], scope: "yaml", group: none, full: true)
