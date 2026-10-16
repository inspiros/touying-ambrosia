#import "../src/lib.typ": *
#set heading(numbering: "1.1")
#show: ambrosia-theme.with(flavor: "minimal", palette: "evergreen",
  config-common(new-section-slide-fn: section-slide),
  config-info(title: [Additional slide types], author: [Tester]))

= Main section
Section introduction.

== Status and sources
#ambrosia-badge(kind: "success")[Validated]
#ambrosia-source-note[Source: #link("https://typst.app")[Typst documentation].]
#pause
#ambrosia-badge(kind: "warning", shadowed: true)[Revealed badge]

#section-slide(title: [Manual divider], subtitle: [A counted transition])
#image-slide("fixtures/image.svg", caption: [Kyklo laboratory], credit: [Image credit], alt: "Kyklo laboratory cover")

#show: appendix.with(numbering: "A.1")
= Backup section
Backup introduction.
== Supporting result
Appendix content.
