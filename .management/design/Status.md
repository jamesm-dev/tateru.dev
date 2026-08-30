---
title: Status
created: 2026-08-30
updated: 2026-08-30
tags: [design, management, ui, dataviz]
status: active
---

# Status

Insights across `.idea/` and `.management/`: how the work is going, what needs attention, and where
the sprint stands. The only section that charts anything.

> [!warning] Before writing a single chart
> Load the **dataviz** skill and follow its procedure — form first, colour last, then run its palette
> validator. The rules below are this page's application of it, not a replacement for it.

## Sections, in order

1. **Headline row** — a few stat tiles.
2. **Deployment readiness** — how much more before this can ship.
3. **Delivered** — the milestone log: everything done, with or without a task.
4. **Needs attention** — the risk list.
5. **Sprint progress** — the active sprint, and sprint management.
6. **Delivery history** — measured, per sprint.
7. **Effort accuracy** — estimate against actual.
8. **Team contribution** — who shipped what.

Readiness and Delivered sit above the risk list because they answer the two questions people open
this page for: *can we ship yet*, and *what have we actually got done*.

## 1. Headline row

Stat tiles, not charts. A single current number is a stat tile; a one-bar bar chart is a mistake.

| Tile | Value | Note |
|---|---|---|
| Sprint | `8 / 21 pts` | Completed over committed, plus days remaining |
| Blocked | `3 tasks` | Warning colour only when above zero |
| Phase | `Phase 1 of 4` | With its task count |
| Estimate accuracy | `+38%` | Median overrun across completed tasks. Omit under ten completed tasks — say `not enough data` |

Each tile is a number, a label, and at most a one-line delta. No sparkline unless there are at least
six real points behind it.

## 2. Deployment readiness

The answer to "how much more before this ships", as a **checklist, never a percentage**. Gates and
their rules live in `.claude/skills/setup/references/git-hooks.md`.

```
DEPLOYMENT READINESS - Phase 1                     5 of 7 gates met
[x] Exit criteria      4/4 met
[x] Tasks              no blocked or in-flight work
[x] Tests              latest run passed, every epic covered
[x] Checks             lint, typecheck, build pass
[ ] Pull requests      2 open against Editor Core
[x] Deploy path        exercised in Phase 0
[ ] Risks              1 critical rule firing
```

- Each gate is met or not met. No partial states, no weighting.
- Agent-completed tasks awaiting confirmation do **not** satisfy the Tasks gate on their own; they
  are listed under it so a person can confirm and clear it.
- An unmet gate names what is blocking it and links there.
- The heading reads `5 of 7 gates met`, never `71% ready` — a percentage of a checklist invites
  rounding up, and shipping is not a rounding decision.
- When every gate is met, the panel says so plainly and names the next phase.

## 3. Delivered

The milestone log: **everything completed, whether or not it had a task**. Reverse chronological, one
row each, with a badge saying where it came from.

| Source | Row is | Comes from |
|---|---|---|
| Task | A completed derived task | `.idea/` acceptance criterion, verified |
| Ad-hoc | A completed authored task | Created on the Board |
| Phase | A phase reaching all its exit criteria | `ROADMAP.md` |
| Sprint | A sprint closing, with its completed points | `board.db` |
| Release | A changelog entry | `CHANGELOG.md` |
| Untracked | A commit that referenced no task | `commits.jsonl` |
| Agent | A task the agent completed from commits, still unconfirmed | `task_status` |

```
2026-08-30  [phase]      Phase 0 complete - walking skeleton deployed
2026-08-29  [task]       Persist documents across restart      Editor Core   3 pts
2026-08-29  [untracked]  Bump dependencies, fix lint drift     4 commits
2026-08-28  [ad-hoc]     Add seed data for local dev           Editor Core
2026-08-26  [sprint]     Sprint 3 closed - 18 pts completed
```

The **untracked** row is the point of this section. Work that never had a task still happened, and a
progress view that only counts planned work will always overstate how much is left. Untracked
commits are grouped by day and summarised, not listed individually.

Filters: source, sprint, epic, person. Default is the current phase, with an option for all time.

> [!warning] A commit is evidence, not completion
> A commit referencing a task links them; it never marks the task done. Completion comes from a
> verified exit criterion. Otherwise "done" means "someone typed the id in a commit message".

## 4. Needs attention

**This is a rules list, not a prediction.** Every entry names the rule that fired, the evidence, and
a suggested action. Nothing here is statistical, and nothing carries a probability.

| Rule | Fires when | Severity |
|---|---|---|
| Long-blocked task | Blocked more than 3 days | serious |
| Stalled epic | In the active sprint, sprint over half elapsed, nothing done | serious |
| Sprint overcommitted | Committed points exceed the last closed sprint's completed, with under a third of time left | warning |
| Chronic underestimate | 3+ completed tasks in one epic where actual exceeded estimate by over 50% | warning |
| Untested epic | Epic has completed tasks and no linked test runs | serious |
| Failing tests on done work | Latest run failed on a task marked done | critical |
| Stale pull request | Open more than 5 days, or changes requested more than 2 days | warning |
| Unresolved spike | A spike epic is blocking a later phase and has no decision recorded | critical |
| Uncovered exit criterion | A phase criterion has no task that would satisfy it | serious |
| Unestimated sprint work | Active-sprint tasks with no points, over a quarter of the sprint | warning |
| Unassigned in-flight work | In-progress task with no assignee | warning |
| Carry-over accumulating | Tasks carried across 3+ sprints | warning |
| Orphaned board data | Authored data whose task has left `.idea/` | warning |
| Unconfirmed completions | Tasks the agent marked done that no person has confirmed, older than 2 days | warning |
| Suggested epics waiting | Suggested epics untriaged for more than a week | warning |

Each row shows: the rule's plain-English name, the specific items, since when, and one suggested
action. Rows link to the task, epic, or sprint concerned.

Severity uses the **reserved status palette** — good, warning, serious, critical — never the
categorical series colours, and each carries an icon and its word, never colour alone.

> [!warning] What this section must never do
> Forecast a completion date, project a burndown line, or state a percentage likelihood. The
> evidence is a handful of tasks. A rule that fires on observable facts is honest; a projection
> dressed in the same UI is not.

## 5. Sprint progress

The active sprint, plus sprint management.

- **Sprint meter** — completed against committed points, as a single ratio against a limit. A meter
  on the same ramp, not a two-slice pie.
- **Composition** — one stacked bar: done, in progress, blocked, not started. Part-to-whole is a
  stacked bar, horizontal so long status labels fit. Categorical colours in fixed order, 2px surface
  gap between segments.
- **Days elapsed** against points completed, as two plain numbers side by side. **Not** a dual-axis
  chart — never two y-scales on one plot.
- **Unfinished work from the last closed sprint**, if any, with the explicit carry-forward action
  from [[Sprints]].
- **Create sprint** — the form described in [[Sprints]].

## 6. Delivery history

Measured history only.

- **Completed points per sprint** — a column chart, one column per closed sprint plus the active one
  in a lighter step. Sequential, one hue. **No trend line, no average line, no projection.**
- **Tasks completed per sprint** — the same chart, second tab or small multiple. Two measures of
  different scale never share an axis.
- Under three closed sprints, show a table instead of a chart and say why. Three columns is not a
  trend, and drawing it like one invites reading it as one.

## 7. Effort accuracy

- **Estimate against actual, per epic** — a dumbbell chart: two dots joined by a line, one hue in
  two shades. Before-and-after per item is exactly what dumbbells are for.
- Sorted by the size of the gap, worst first. Direct-label the top few only.
- Epics with no estimates are excluded and counted in a line beneath: `6 epics have no estimates`.

## 8. Team contribution

- **Points completed per member, this sprint** — horizontal bars, sequential, one hue. Horizontal
  because names are long.
- **Overall** — the same, second view.
- Never a pie. Never a leaderboard framing — the section is titled contribution, and the ordering is
  by name unless the reader sorts it. A dashboard that ranks people by points will get people
  gaming points.

## Chart rules for this page

Drawn from the dataviz procedure, and non-negotiable here:

- **Inline SVG. No chart library.** These forms are bars, columns, lines, dots, and a meter — all
  are a handful of elements. This keeps the no-new-dependencies rule intact.
- **One axis, always.** No dual-scale plot anywhere on this page.
- **Categorical hues in fixed order, never cycled.** A ninth series folds into `Other`.
- **Sequential is the default** — one hue, more-is-darker — unless the job is genuinely identity.
- **Legend for two or more series**; four or fewer are also direct-labelled. One series needs no
  legend: the title names it.
- **Status colours are reserved** for severity and never reused as a series colour.
- **Every chart has a table view**, reachable from the chart, carrying the same numbers.
- **Hover layer by default** — crosshair and tooltip on line and column, per-mark tooltip on bars
  and dots.
- **Dark mode is chosen, not flipped** — its own steps from the same ramps, validated against the
  dark surface.
- Colours come from the project's palette. Run the dataviz validator against them before shipping;
  do not eyeball whether they are colourblind-safe.

## Empty states

| State | What to show |
|---|---|
| No sprints yet | The headline row without sprint tiles, and a `Create sprint` prompt |
| No closed sprints | Delivery shows the active sprint only, with a line saying history begins after the first close |
| Fewer than 10 completed tasks | Estimate accuracy shows `not enough data`, not a number |
| Nothing needs attention | A single positive line. Do not render an empty panel, and do not invent a low-severity item to fill it |
| No team members | Contribution is replaced by a link to [[Team]] |
| No commits yet | Delivered shows planned work only, with a line saying commit tracking starts at the first commit |
| Git hooks not installed | A one-line note that untracked work cannot be counted until they are, with the install command |
| Readiness gates all met | The panel says so plainly and names the next phase |
