# Project Roadmaps

`ambrosia-roadmap` displays concurrent tracks, phases, milestones, and details.
Time is elapsed from zero; fractional boundaries keep proportional spacing.

<!-- ambrosia-example: roadmap -->
[Editable source](site/examples/roadmap.typ).
<!-- /ambrosia-example -->

## Time And Labels

| Option | Default / Meaning |
| --- | --- |
| `total` | `12`; positive finite duration. |
| `unit` | `"week"`; changes labels, not the data. |
| `tick-every` | `2`; positive interval, including fractions. |
| `now` | Current elapsed position; `none` hides it. |
| `tick-label` | Optional `(start, end) => content` formatter. |

A task from `0` to `2.5` lasts 2.5 units. All ranges must remain within
`0` to `total`, with starts less than ends. Supported label prefixes include
month, week, day, year, hour, and minute; custom strings also work.

```typst
// Inside ambrosia-roadmap(...): quarters over a 36-month plan.
total: 36, unit: "month", tick-every: 3,
tick-label: (start, end) => [Q#(int(start / 3) + 1)],
```

## Tracks, Phases, And Details

Each task needs `content`, `start`, and `end`. A dictionary occupies its own
track; an array groups ordered, non-overlapping tasks on one track:

```typst
tasks: (
  ((content: [Explore], start: 0, end: 2.5),
   (content: [Review], start: 2.5, end: 4)),
  (content: [Build], start: 2, end: 6),
),
```

Phases need `name` and `end`; starts default to the previous end (initially zero).
An explicit `start` allows gaps. Phases must be ordered and disjoint.

A task's `details` accepts content or `(content: ..., start: ..., end: ...)`.
By default its drawer spans from the task's start to `total`, below the whole
parent track.

Milestones accept numbers or records such as `(at: 4.5, label: [Review])`.
`legend: false` hides their legend. Tasks, phases, and milestone records accept
`kind` or a solid `fill`.

## Fitting

`fit: true` scales typography and relative spacing to the available height,
down to `min-scale: 75%`. Beyond that limit it raises a diagnostic. A native
`block(height: ...)` supplies an explicit height budget; `fit: false` preserves
natural size.

Use separate tracks for overlapping work. Whole-component reveals work;
pauses inside task dictionaries are unsupported. The component does not compute
dependencies or calendar dates.

[Editable project and event plans](../examples/roadmap.typ)
