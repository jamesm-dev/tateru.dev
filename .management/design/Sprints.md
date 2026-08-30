---
title: Sprints
created: 2026-08-30
updated: 2026-08-30
tags: [design, management]
status: active
---

# Sprints

A sprint is a dated window that work is assigned to. It is **entirely authored** — `.idea/` has
phases, not sprints, and the two are deliberately different things.

| | Phase | Sprint |
|---|---|---|
| Comes from | `.idea/ROADMAP.md` | Created here |
| Defined by | An outcome and its exit criteria | Dates |
| Ends when | The exit criteria are met | The end date arrives |
| Can overlap | No | May span parts of several phases |

A phase finishes when the work is done; a sprint finishes when time runs out. Conflating them is how
a roadmap turns into a wish with a deadline attached, so the dashboard keeps them separate and shows
both.

## The model

```
sprint: name, starts_on, ends_on, goal, status
```

Status is derived from the dates, never typed: `planned` before the start, `active` between,
`closed` after. Exactly one sprint can be active — the one containing today. If none does, the
dashboard shows `no active sprint` rather than guessing at the nearest.

Things are assigned to a sprint at two levels:

- **A task** belongs to at most one sprint.
- **An epic** may be assigned to a sprint as a whole, which is a statement of intent. It does not
  cascade: assigning an epic to Sprint 4 does not move its tasks. The Specs drawer shows when an
  epic's tasks are scattered across sprints, since that is usually a mistake worth seeing.

## Creating a sprint

From [[Status]]. The form asks for a name, a start date, an end date, and an optional goal sentence.

Rules enforced on save:

- The end date must follow the start date.
- Dates may not overlap an existing sprint. Two active sprints make every "this sprint" number
  ambiguous.
- A name is required and must be unique. Default it to `Sprint N`, but let it be renamed — a sprint
  named `Beta prep` is more useful than `Sprint 7`.

## Closing a sprint

A sprint closes on its end date. Nothing happens automatically to its tasks — **unfinished work is
not silently rolled forward**, because a sprint that quietly absorbs its own overflow can never be
learned from.

Instead, when a sprint has closed with unfinished tasks, Status shows them and offers to move them
to the active sprint, as one explicit action. What was carried over is recorded, so the next
retrospective can see it.

## Counting

- **Committed points** — the sum of points on every task in the sprint, at any status.
- **Completed points** — the sum on tasks that are done.
- A task with no points counts as zero points but still counts as a task. Both numbers are shown;
  points alone hide the unestimated work.
- Points are credited to the sprint the task was **in when it was completed**, not the one it was
  created in.

> [!warning] Do not compute velocity
> Committed and completed points, per sprint, are facts. An average of them presented as capacity is
> a forecast, and two or three sprints cannot support one. [[Status]] shows the history; it does not
> extrapolate a line through it.
