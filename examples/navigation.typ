#import "@preview/touying-ambrosia:0.1.0": *
#import "../template/project-brand.typ": project-theme

// Edit these defaults in your IDE. Structural navigation and small buttons are
// independent. Segments use a footer row; sidebar uses a reserved body column.
#let flavor = "cambridge" // try minimal, dewdrop, stargazer, or cambridge
#let navigation = "tree" // auto, none, "tabs", "dots", "context", "panes", "segments", "breadcrumbs", "sidebar"
// tree: linked talk title + enclosing headings in two/three slim strips.
// segments: linked footer segments with progress inside each section. To use a
// header rail instead, pass ambrosia-navigation(base: "segments", placement: "header").
#let side = "right" // sidebar only: "left" also works
#let palette = "ocean" // try midnight for a dark background
#let buttons = true
#let section-progress = false // the segmented rail already shows local progress
#let flavor = sys.inputs.at("flavor", default: flavor)
#let navigation = sys.inputs.at("navigation", default: navigation)
#let navigation = if navigation == "auto" { auto } else if navigation == "none" { none } else { navigation }
#let level = if flavor == "cambridge" { 3 } else { 2 }
#show: project-theme.with(
  flavor: flavor, navigation: navigation,
  navigation-side: sys.inputs.at("side", default: side),
  navigation-width: 9em, // reserves this width plus a 0.8em gap
  navigation-depth: 2, // tree: up to two ancestors; sidebar: include headings through level two
  // sidebar-background: auto, // enable flavor paint; none is the default; a color overrides it
  palette: sys.inputs.at("palette", default: palette),
  navigation-buttons: buttons,
  navigation-buttons-opacity: 40%,
  navigation-buttons-actions: ("first", "previous", "section", "outline", "next", "last"),
  section-progress: section-progress,
  config-info(title: [Finding Your Way], author: [Presenter]),
)
#title-slide() // covers release a sidebar column; a segmented rail can remain
#outline-slide()
= Discover
// Cambridge uses level-two groups and level-three slides. Other flavors use
// level-two headings directly as slides.
#if level == 3 { heading(depth: 2)[Questions And Evidence] }
#heading(depth: level)[A Logical Slide]
The navigator shows the current context. Buttons jump between logical slides.
#speaker-note[Animation frames share the same local progress count.]
#pause
This frame advances the animation without adding another progress step.
#if level == 3 { heading(depth: 2)[Alternative Views] }
#heading(depth: level)[A Local Override]
#slide(title: [Room For A Wide Figure], config: config-store(navigation: none))[
  This slide hides structural navigation and recovers its space.
  The button controls and section progress are still enabled.
  #v(1em)
  #ambrosia.navigation-buttons(actions: ("first", "outline", "last"), opacity: 70%)
]
= Build
#if level == 3 { heading(depth: 2)[Results And Discussion] }
#heading(depth: level)[A Clear Result]
#ambrosia-block(style: "stripe", kind: "success", title: [Observation])[
  Geometry, navigation, palette, and branding can be chosen independently.
]
#slide(title: [Linked Breadcrumbs], config: config-store(navigation: "breadcrumbs"))[
  This slide uses linked ancestor headings in the title slot. Long paths collapse
  the middle, and long labels leave room for the current heading.
]
#ending-slide(title: [Questions?])[]
#show: appendix
= Backup Material
#if level == 3 { heading(depth: 2)[Further Details] }
#heading(depth: level)[Supporting Evidence]
Segmented rails, sidebars, header navigation, and section progress switch to appendix scope.
// Local opt-in on an immersive slide can use config-store(navigation: "sidebar").
