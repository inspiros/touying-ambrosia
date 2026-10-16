#import "../src/lib.typ": *

// Edit these defaults in an IDE. CLI inputs are optional overrides.
#let flavor = "minimal"
#let palette = "ocean" // try midnight, evergreen, or rose
#let time-unit = "week" // month, day, year, hour, or your own label
#let elapsed-time = 3.5 // now: none hides the current-time marker
#show: ambrosia-theme.with(
  flavor: sys.inputs.at("flavor", default: flavor),
  palette: sys.inputs.at("palette", default: palette),
  config-common(new-section-slide-fn: none),
  config-info(title: [A Project Roadmap], author: [Presenter]),
)

= Project Roadmap
== From Idea To Launch
// All times are elapsed positions starting at zero, in the selected unit.
// start: 0, end: 2.5 means a duration of 2.5 weeks, with the default unit.
// Adjacent tasks can share an endpoint. A tuple puts them on the same track.
#ambrosia-roadmap(
  total: 12, unit: time-unit, tick-every: 2,
  now: elapsed-time,
  milestones: ((at: 5, label: [Design Review]), (at: 10, label: [Pilot])),
  phases: (
    (name: [Discover], end: 3, kind: "info"),
    (name: [Build], end: 8, kind: "success"),
    (name: [Deliver], end: 12, kind: "warning"),
  ),
  tasks: (
    (
      (content: [Discovery], start: 0, end: 2.5, kind: "info"),
      (content: [Review], start: 3.5, end: 5, kind: "success"),
    ),
    (content: [Implementation], start: 2.5, end: 8, kind: "success"),
    (content: [Documentation], start: 4, end: 10.5),
    (content: [Testing And Feedback], start: 7, end: 11, kind: "warning",
      // Details follow the whole parent track. A wider span keeps them readable.
      details: (start: 4, end: 12, content: [
        - Check the main workflows with a small pilot group.
        - Resolve issues and prepare a short handover guide.
      ])),
    (content: [Launch], start: 10.5, end: 12, kind: "danger"),
  ),
)

== Planning An Event
// Another unit and a partial final interval. tick-every can be fractional too.
// tick-label receives the elapsed start/end positions; it can return content.
// For an ordinal label such as Day 1, use a custom function starting from zero.
#ambrosia.roadmap(
  total: 5.5, unit: "day", tick-every: 1,
  tick-label: (start, end) => [Day #(start + 1)],
  milestones: ((at: 4.5, label: [Doors Open], kind: "success"),),
  tasks: (
    (content: [Prepare Materials], start: 0, end: 2.5),
    (content: [Venue Setup], start: 1.5, end: 4, kind: "success"),
    (content: [Rehearse And Host], start: 3, end: 5.5, kind: "warning",
      details: [Test equipment, brief the hosts, and welcome participants.]),
  ),
)

// Dense plans can be split across slides. fit defaults to true; its minimum
// 75% scale limits automatic shrinking. Use a native block(height: ...) to set
// a smaller height budget. Task, phase, detail, and marker positions accept floats.
