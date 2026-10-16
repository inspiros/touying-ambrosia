#import "@preview/touying-ambrosia:0.1.0" as core
#import "@preview/touying-ambrosia:0.1.0": *
#import "../../template/project-brand.typ": project-theme
#import "snippets.typ"

// Each choice is a real presentation, compiled independently of the manual.
// Change view in your IDE; the manual ships with its PNG snapshots already built.
#let view = sys.inputs.at("view", default: "blocks")
#let scope = dictionary(core)
#if view == "start" {
  eval(snippets.start.text, mode: "markup", scope: scope)
} else {
  show: project-theme.with(
    flavor: if view == "navigation" { "cambridge" } else { "minimal" },
    palette: "ocean", navigation: if view == "navigation" { "tree" } else { none },
    config-common(new-section-slide-fn: none),
    config-info(title: [From Idea To Evidence],
      subtitle: [Small Choices, Clear Presentations], author: [Alex Researcher],
      short-title: [Idea To Evidence]),
  )

  if view == "cover" {
    title-slide(layout: "header")
  } else if view == "blocks" {
    slide(title: [A Useful Container])[
      #eval(snippets.block-example.text, mode: "markup", scope: scope)
    ]
  } else if view == "image" {
    eval(snippets.image-example.text, mode: "markup", scope: scope)
  } else if view == "roadmap" {
    slide(title: [A Six-Week Project])[
      #eval(snippets.roadmap-example.text, mode: "markup", scope: scope)
    ]
  } else if view == "navigation" [
    = Motivation
    == A Shared Question
    === The Starting Point
    Begin with the question that connects the talk.
    = Methods
    == An Explicit Model
    === Analysis
    #ambrosia-block(style: "stripe", title: [One Step At A Time])[
      The thin strips retain the talk, section, and subsection context.
    ]
    = Results
    == Evidence
    === A Clear Finding
    End with the evidence and its limits.
  ] else {
    panic("Unknown manual example: " + view)
  }

}
