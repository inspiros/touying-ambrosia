# Project Roadmaps

<!-- ambrosia-example: roadmap -->
[Editable source](site/examples/roadmap.typ).
<!-- /ambrosia-example -->

`ambrosia-roadmap` (or `ambrosia.roadmap`) shows phases, concurrent work, milestones, and optional task details. Use it for project launches, events, teaching plans, or research schedules. Open [the editable example](../examples/roadmap.typ) in your IDE to try a project launch and an event schedule with light/dark palettes.

```typst
#ambrosia-roadmap(
  total: 12, unit: "week", tick-every: 2, now: 3.5,
  milestones: ((at: 9, label: [Review]),),
  phases: ((name: [Discover], end: 3), (name: [Build], end: 12)),
  tasks: (
    (content: [Discovery], start: 0, end: 2.5, kind: "info"),
    (content: [Implementation], start: 2.5, end: 9, kind: "success"),
    (content: [Testing], start: 8, end: 12, kind: "warning",
      details: (start: 6, end: 12, content: [Check workflows and prepare the handover.])),
  ),
)
```

## One Time Axis

All values are **elapsed positions from zero**, measured in `unit`. A task from `0` to `2.5` lasts **2.5 units**. A task from `2.5` to `5` can follow it immediately on the same track. `now: 3.5` and milestone `(at: 3.5)` refer to that same position. There is no separate inclusive-month convention.

`total` (default `12`) and `tick-every` (default `2`) accept positive finite integers or floats. Task/phase/detail endpoints, `now`, and milestone positions also accept floats. Starts must be less than ends, and all positions must lie between zero and `total`. `none` hides the current-time marker. The faint past wash covers elapsed time in otherwise empty intervals.

`unit` defaults to `"week"`. Common units have compact prefixes: `"month"` → `M`, `"week"` → `W`, `"day"` → `D`, `"year"` → `Y`, `"hour"` → `h`, and `"minute"` → `min`. Any other string works, for example `"sprint"`; `""` gives dimensionless labels. Changing the unit changes labels, not data values or calendar conversions.

Ticks default to elapsed ranges such as `W0–2`. A final partial interval works. To display ordinal days, quarters, calendar labels, or another language, supply `tick-label: (start, end) => ...`:

```typst
// A 5.5-day plan, with labels Day 1 through Day 6.
total: 5.5, unit: "day", tick-every: 1,
tick-label: (start, end) => [Day #(start + 1)],

// A 36-month plan labeled Q1 through Q12.
total: 36, unit: "month", tick-every: 3,
tick-label: (start, end) => [Q#(int(start / 3) + 1)],
```

The renderer places proportional columns at actual task, phase, marker, and tick boundaries. It does not round durations to a fixed smallest unit or allocate one column per elapsed unit. Boundaries within `total × 10⁻¹⁴` are treated as the same position, so arithmetic such as `0.1 * 3` can meet a task starting at `0.3`. Durations smaller than that tolerance produce a diagnostic. Default labels suppress arithmetic tails such as `0.30000000000000004`; a custom callback controls its own formatting. At most 1000 tick intervals are allowed to catch accidental extreme tick density.

## Tracks, Phases, And Details

Phases require `name` and `end`. Their start defaults to zero for the first phase, then the previous phase's end; an explicit `start` allows a gap. Phases must be ordered and disjoint, and need not cover the whole plan. Omit phases to show only ticks and tasks.

Each task requires `content`, `start`, and `end`. A task dictionary occupies its own track. An array of task dictionaries shares one track, ordered by start time without overlap:

```typst
tasks: (
  ((content: [Explore], start: 0, end: 2.5),
   (content: [Review], start: 2.5, end: 4)),
  (content: [Build], start: 2, end: 9),
)
```

Overlapping work belongs on separate tracks. Invalid, zero-duration, reversed, out-of-range, or overlapping ranges produce a diagnostic.

A task's `details` can be content or `(content: ..., start: ..., end: ...)`. Its default span begins at the task's start and extends to `total`. Every drawer follows the complete parent track, so it does not displace another task from that same row. An explicit wider span can make a long explanation readable. Detail ranges receive the same validation as tasks.

## Appearance And Markers

Phases, tasks, and milestone records accept `kind` (`accent`, `info`, `success`, `warning`, `danger`, `neutral`) or an explicit solid `fill`. Colors and subtle surfaces adapt to the palette. Default phases cycle through info/success/warning, tasks use the accent, and milestones use warning. Current time uses danger. Labels convey meaning alongside colors.

Milestones accept numeric positions or records: `9.5` or `(at: 9.5, label: [Review], kind: "success")`. The optional label appears in the legend. `legend: false` hides the legend; the markers remain. Period/milestone lines sit behind task panels to keep text readable; a current-time line takes precedence at coincident boundaries.

## Size And Fitting

The roadmap takes the available width and its natural height. Typography, insets, gutters, and strokes use `em`, so changing the presentation text size scales them together. It uses native grids, independently of the theme's table text size.

`fit: true` measures the remaining height and scales typography and relative spacing down only when needed. `min-scale: 75%` sets the lower limit. If even that cannot fit, it raises a diagnostic instead of adding another page. Place the roadmap in a native `block(height: ...)` to give it an explicit height budget. `fit: false` preserves the chosen size and leaves space management to the caller.

Short labels and a few tracks work best on a projected slide. Split a dense plan into an overview and a detailed section rather than shrinking the whole plan indefinitely. The component does not calculate task dependencies or calendar dates. Whole-component reveals with Touying work; pauses nested inside task dictionaries are not a supported animation interface.

## API Change

The former `total-months` argument is now `total`; milestone `month` becomes `at`. All ranges now use elapsed positions starting at zero. To preserve an old inclusive range `start: 1, end: 6`, use `start: 0, end: 6`. The old automatic quarter labels are available through the callback above. There are no compatibility aliases.
