#import "../src/lib.typ": *
#let date = sys.inputs.at("date", default: "absent")
#show: ambrosia-theme.with(
  flavor: sys.inputs.at("flavor", default: "minimal"),
  palette: sys.inputs.at("palette", default: "light"),
  config-info(
    author: [Full author], title: [Full title],
    short-author: [SHORT AUTHOR with an intentionally extremely long label that cannot reasonably fit in its allotted footer field],
    short-title: [SHORT TITLE #for _ in range(4) {
      [with an intentionally extremely long label that includes extra detail and more words than a footer should ever have, so we need a readable ellipsis. ]
    }],
    date: if date == "present" { [FOOTERDATE] } else { none },
  ),
)

#slide(title: [Explicit short labels])[Short metadata must also fit.]
#title-slide(date: [TITLEDATE])
#slide(title: [After a title-only date])[A local date does not change the footer.]
