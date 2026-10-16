#import "../src/lib.typ": *
#show: ambrosia-theme.with(
  palette: sys.inputs.at("palette", default: "light"),
  text-size: float(sys.inputs.at("size", default: "18")) * 1pt,
  config-info(title: [Working Together], institutions: (group: [An Example Research Group])),
)
#for count in (4, 5, 8, 12) {
  title-slide(authors: range(1, count + 1).map(n => (
    name: [Researcher #n], affiliations: ("group",), email: "person" + str(n) + "@example.org")))
}
