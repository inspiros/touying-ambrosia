#import "../src/lib.typ": *
#show: ambrosia-theme.with(flavor: "portico",
  navigation-side: sys.inputs.at("side", default: "right"),
  palette: sys.inputs.at("palette", default: "midnight"),
  navigation-buttons: true, section-progress: true,
  config-info(title: [A Longer Presentation], author: [Presenter]),
  config-common(new-section-slide-fn: none))
#for section in range(8) {
  heading(depth: 1)[Part #(section + 1): A Longer Section Name For The Sidebar]
  for step in range(8) {
    heading(depth: 2)[Step #(step + 1): A Deliberately Long Heading For A Bounded Label]
    [The main content stays clear of the navigation column.]
  }
}
