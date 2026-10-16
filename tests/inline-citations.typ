#import "../src/lib.typ": *
#show: ambrosia-theme.with(cite-marker: sys.inputs.at("marker", default: "author-year"),
  bibliography-marker: "native", config-common(new-section-slide-fn: none))
#set heading(numbering: "1.1")
= References
== Native Citations <result>
Normal #cite(<knuth84>). Shorthand @knuth84. Footnote #footcite(<knuth84>).
Explicit IEEE #cite(<knuth84>, style: "ieee").
Full APA #cite(<knuth84>, style: "apa", form: "full").
Native heading #ref(<result>, supplement: [Result]).
#uncover("2-")[Revealed @knuth1984programming.]
#pause
Second frame.
#bibliography-slide("fixtures/markers.bib", style: "ieee")
