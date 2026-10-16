#import "../src/lib.typ": *
#let flavor = sys.inputs.at("flavor", default: "cambridge")
#let level = if flavor == "cambridge" { 3 } else { 2 }
#let navigation = sys.inputs.at("navigation", default: "dots")
#let navigation = if navigation == "none" { none } else { navigation }
#show: ambrosia-theme.with(flavor: flavor, navigation: navigation,
  palette: sys.inputs.at("palette", default: "ocean"),
  config-common(new-section-slide-fn: none),
  config-info(title: [Combinations], author: [Presenter], logo: self => image("fixtures/image.svg")))
#let probe() = layout(size => context [#metadata((width: size.width.pt(), height: size.height.pt()))<navigation-body>])
= ChapterOne With A Deliberately Long Name For The Header
#if level == 3 { heading(depth: 2)[TopicOne] }
#heading(depth: level)[CurrentSlideOne]
#probe()
BODYMARKER
#pause
Another animation frame.
#for index in range(2, 11) {
  heading(depth: 1)[Chapter#str(index) With A Deliberately Long Name For The Header]
  if level == 3 { heading(depth: 2)[Topic#index] }
  heading(depth: level)[CurrentSlide#index]
  probe()
  [BODYMARKER]
}
#show: appendix
= AppendixChapter
#if level == 3 { heading(depth: 2)[Supporting Topic] }
#heading(depth: level)[BackupSlide]
#probe()
BODYMARKER
