#import "../src/lib.typ": *
#show: ambrosia-theme.with(flavor: "simple", footcite-marker: "local", config-info(title: [Citation visibility], author: [Tester]))

== Citation modifiers

#only(2)[Only on frame two #footcite(<einstein1905>).]
#uncover("2-")[From frame two #footcite(<vaswani2017attention>, label: <revealed-note>, numbering: "a").]
#pause
Second frame.
#pause
Third frame. Revealed footnote reference @revealed-note.

// Register once, even though this logical slide has three animation frames.
#hidden-bibliography("../examples/bibliography.bib")
