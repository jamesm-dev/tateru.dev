---
title: DESIGN
created: 2026-08-30
updated: 2026-08-31
tags: [design, management, moc]
status: active
---

# Dashboard Design

How the `/management` dashboard looks and behaves when `/setup` builds it. Four sections behind a
sidebar — Board, Specs, Team, Status. This is the index; the detail lives in [design/](design/), one
concern per note.

**Read [[Requirements]] and [[Data Sources]] before writing any code.** They carry the two decisions
everything else depends on: where the data lives, and what the page may edit.

> [!important] Rebuilding this on another stack
> These notes describe the dashboard as it was built and refined, not as it was first sketched.
> Four of them carry the detail that makes a rebuild land in the same place rather than merely a
> defensible one:
>
> | Note | Fixes |
> |---|---|
> | [[Reference Implementation]] | Every measurement, breakpoint, and the epic colour algorithm |
> | [[Derivations]] | Every computed number, as portable pseudocode |
> | [[API Surface]] | The two reads and seventeen writes, and nothing else |
> | [[Copy Deck]] | The exact words, where a softened phrase becomes a dishonest one |
>
> **Appearance still comes from the app**, always: its theme, its tokens, its components, its dark
> mode. These notes fix layout, behaviour and wording — not palette. Where the project offers its own
> scale, snap to its nearest step; where it offers nothing, build the component and use these values
> as written. Either way, **say so in the build report**: a silent substitution is how two builds
> drift apart.

## What this page is for

One person, glancing for ten seconds, answering four questions:

1. **What phase are we in, and how far through?**
2. **Is anything stuck?**
3. **What is next?**
4. **Who is on what, and how much is left?**

Everything else is secondary. If a section does not serve one of those four, it goes below the fold,
into the task drawer, or does not ship.

It is also the one place where assignment and effort are **recorded** — the only data here a person
types in rather than derives.

> [!warning] Record and measure, but never forecast
> Sprint points, estimates, and actuals are shown because someone entered them. [[Status]] charts
> that history and flags risks from rules that fire on observable facts. It does not draw a
> burndown line, compute a velocity, or project a completion date — a handful of sprints cannot
> support one, and a projection dressed in the same UI as a measurement is not honest.

## The notes 

**Foundations**

| Note | Covers |
|---|---|
| [[Requirements]] | What must exist first: the standalone database, the GitHub MCP, and what degrades when each is missing |
| [[Data Sources]] | The three stores, the task reference id that joins them, and why sync beats live fetch |
| [[Database Schema]] | Tables, rules, and migrations for `board.db` |
| [[Sprints]] | What a sprint is, how it differs from a phase, and how points are counted |
| [[Derivations]] | Every derived number as portable pseudocode: task index, phase gate, advance cascade, colours, references |
| [[API Surface]] | The complete operation set, the meaning of `null`, and the error contract |

**The four sections**

| Note | Covers |
|---|---|
| [[Navigation]] | The sidebar, the four routes, and the page shell |
| [[Board]] | The task board, filters, and creating tasks against an epic |
| [[Specs]] | The epics, the epic drawer, and what may be edited there |
| [[Team]] | Members, current work, contribution, and adding people |
| [[Status]] | Insights, the risk rules, sprint progress, and every chart |

**Craft**

| Note | Covers |
|---|---|
| [[Design System]] | Using the project's own theme and components, and the visual language |
| [[Page Layout]] | Information hierarchy, the shell, the wireframe, responsive behaviour |
| [[Components]] | Header, phase card, blockers, board, roadmap, shipped, footer |
| [[Task Card And Drawer]] | The card, the drawer, and every editable field |
| [[Interaction And States]] | What is editable, the write endpoints, and every state to handle |
| [[Accessibility And Anti-Patterns]] | Keyboard, screen reader, contrast, and what not to do |
| [[Reference Implementation]] | The measured fixed point: constants, spacing scale, breakpoints, board geometry, epic palette |
| [[Copy Deck]] | Every user-facing string, and the ones that must never be softened |

## Compliance checklist

`/setup` must walk this before reporting the dashboard built. A rule that is never checked is a rule
the next build quietly drops, and "it looks right" is not a check.

**Theme fidelity** — see [[Design System]]
- [ ] Every colour, font, radius and shadow comes from the project's own tokens. No second palette,
      no hardcoded hex beyond the two semantic tokens [[Reference Implementation]] defines.
- [ ] Where the project has a component — Card, Badge, Dialog, Sheet, Avatar, Select — the dashboard
      uses **that** component. shadcn is preferred wherever the project already has it.
- [ ] Where the project has none, components are built once in `ui/`, from the project's tokens, and
      reused — never a second drawer beside an existing one, never a UI kit added for this page.
- [ ] Dark mode is the project's own mechanism. Never a second toggle.
- [ ] No new dependency for this page. The one sanctioned exception is a database driver.
- [ ] **The test:** someone opening the page cannot tell it was generated. A page that matches every
      measurement here but looks like a different product bolted on has failed.

**Shell and navigation**
- [ ] Sidebar shows the project name, then the current phase, then the active sprint — and never the
      words "No sprint defined". See [[Navigation]].
- [ ] The sprint line is absent entirely until at least one sprint exists.
- [ ] Nav is a `<nav>`; the active item carries `aria-current="page"`; counts sit inside the
      accessible name.
- [ ] Phase progress in the footer carries its count as text, not colour alone.

**Board and cards**
- [ ] Columns are lists. Each card is a `<li>` containing a `<button>` — never a `div` with a click
      handler. See [[Task Card And Drawer]].
- [ ] The whole card opens the drawer.
- [ ] An empty column keeps its heading and shows a muted `Nothing here`; the layout does not
      collapse.
- [ ] Unassigned renders a dashed placeholder that is itself the assign control.
- [ ] Points omitted when unset; `0 pts` and `1 pt` are real values and display.
- [ ] Estimate/actual pair omitted when neither is set; actual emphasised when it exceeds estimate.
- [ ] Ad-hoc tasks are identified by their `ADH-` reference alone — no second "ad-hoc" pill saying
      the same thing.
- [ ] Creating a task is **one button** opening a drawer — no form parked in the toolbar.
- [ ] **Every epic is colour-coded**, hue from its phase and shade from its position within it, and
      that colour appears on every card belonging to it. The epic name is always shown too: colour is
      an aid, never the identifier. See [[Board]].
- [ ] **Every task has a priority**, assigned when generated from the phase it sits in, overridable
      in the drawer, rendered with its word and not colour alone.
- [ ] **Every task has points** — carried from its acceptance criterion for a derived task, asked
      for when creating an ad-hoc one. The badge is omitted when there is no value rather than
      reading `no pts`; the gap surfaces on Team, where it actually distorts a number.
- [ ] Team shows each member's load as points across a task count, never as a percentage of an
      invented capacity. See [[Team]].
- [ ] The task drawer's test trail shows runs linked to that task, with when they ran; a task with
      none reads `No test runs linked` rather than hiding the section.
- [ ] Cards sort by priority, then phase, then epic — a board that displays priority without
      ordering by it is decorating.

**Spacing**
- [ ] One spacing scale (4/8/12/16/24/32/48), used throughout. See [[Page Layout]].
- [ ] Cards have 16px or more internal padding, 12px between them, 24px or more between columns.
- [ ] Board columns are 15–20% of the viewport wide and the board scrolls horizontally rather
      than squeezing cards to fit. See [[Page Layout]].
- [ ] Sections are 32px or more apart, each heading nearer its own content than the block above.
- [ ] Board carries search plus sprint, assignee, epic and origin filters, each written to the URL.
- [ ] An active filter is visible, with a Clear control — a silently filtered board is its most
      confusing state.
- [ ] Search matches title, description, epic, assignee and task reference in one box.
- [ ] Specs and Team carry a search box too, each with **its own URL key** (`sq`, `tq`), so a filter
      never leaks between tabs. See [[Navigation]].
- [ ] Phases on Status are **collapsed by default**, their summaries carrying status and counts.
- [ ] The board has five columns, **Parked** first, then Blocked, In progress, Next up, Done.
- [ ] A parked task is excluded from its phase's task requirement, keeps its points and assignee,
      and is reported as a count rather than silently removed. See [[Board]].
- [ ] Parking never satisfies an exit criterion; the advance gate still refuses while one is unmet.
- [ ] **Every card is draggable**, always. A drop writes an explicit status to `board.db` and never
      touches `.idea/`. See [[Board]].
- [ ] Dropping a derived task into Done renders `done · unverified` until `/setup` verifies the exit
      criterion, and it is not counted as done in readiness.
- [ ] Dragging a derived task back to its derived column clears the override rather than writing the
      opposite status.
- [ ] Every drag has a keyboard equivalent in the drawer, and drops announce through a live region.

**Drawer**
- [ ] Built from shadcn where the project has it; otherwise hand-built once in `ui/` and reused —
      never a second drawer beside an existing one. See [[Design System]].
- [ ] Opens on card click and is a modal dialog: focus moves in, is trapped, returns to the card on
      close, and Escape closes it.
- [ ] Sets `?task=` so a task is linkable, and the back button closes it.
- [ ] Shows, in order: title, reference id (monospace, click-to-copy), parent epic as a **relative**
      link into `.idea/epics/`, description, assignees, effort, test trail, pull request, timestamps.
- [ ] Empty states are visible text, not hidden sections — `No test runs linked`, `status unknown`.
- [ ] Only `board.db`-backed fields are editable. Task text, epic, phase and completion are
      read-only, with no control that would edit `.idea/`.
- [ ] A write failure rolls back visibly with an inline error. Never silent.

**Sprints and phases**
- [ ] A sprint can be created, with the end date after the start, no overlap, and a unique name.
- [ ] Sprint status is derived from dates, never typed.
- [ ] Phases are read-only, with one line saying they come from the roadmap via `/shape`. No
      disabled button without an explanation. See [[Sprints]].
- [ ] A phase whose tasks are all done or parked **advances on its own**, cascading across a run of
      finished phases and stopping at the first with work left — and never past the last phase.
- [ ] An automatic advance is announced: which phases were crossed, and anything it moved past.
- [ ] **Advance anyway** is available while work is outstanding, behind a confirmation that names
      what will be left, recorded as forced with that summary.
- [ ] Each outstanding exit criterion carries a **Park** control; parked ones are listed with
      **Unpark**. Parked is never rendered as met — the gate reads `4 of 7 met, 3 parked`.
- [ ] When the gate fails, the specific unmet criteria and outstanding task count are listed — never
      a bare disabled button.
- [ ] Advancing takes effect **immediately** — sidebar, priorities, tiles and gate all move — while
      writing only to `board.db`. The dashboard never edits `.idea/ROADMAP.md` itself.
- [ ] While the roadmap has not caught up, every view showing the phase shows `roadmap pending`, and
      Status names both the effective phase and the roadmap's.
- [ ] A pending advance can be stepped back until `/setup` consumes it.
- [ ] Committed and completed points both shown; no velocity, no burndown, no forecast.

**Agreement**
- [ ] Every section reads one shared effective-task derivation. No component reads `task.done`
      from `state.json` directly. See [[Data Sources]].
- [ ] Parking a task updates the board, Specs counts, the headline tiles, phase progress and the
      advance gate — without a reload.
- [ ] Wherever a denominator excludes parked work, the parked count is shown beside it.

**Measurements** — see [[Reference Implementation]]
- [ ] Sidebar 248px; radius 12px on cards and 7px on inputs; base font size 14px.
- [ ] The board's grid or flex ancestor uses `minmax(0, 1fr)` or `min-width: 0`. A plain `1fr`
      pushes the last column off screen and looks like a board bug.
- [ ] Board columns are `flex: 1 1 0` with a `220px` floor and scroll horizontally — never
      `repeat(5, 1fr)`, which has no floor and squeezes cards to unreadable.
- [ ] Breakpoints at 900px (columns swipe), 820px (shell collapses), 768px (drawer becomes a bottom
      sheet). They are deliberately not equal.
- [ ] Epic colour is four hue families `[152, 210, 32, 285]` by phase, shaded by position within the
      phase and capped at three steps — never one generated hue per epic.
- [ ] Epic index comes from one central sort by phase then title, so every section agrees.
- [ ] Counts, points, durations and dates render in tabular or monospace figures.

**Derivations** — see [[Derivations]]
- [ ] One task index, built once per load and passed down. No component derives `done` itself.
- [ ] `tasksSettled` advances a phase; `open` only describes it. Outstanding criteria are recorded
      on the advance, never treated as satisfied.
- [ ] The advance in-flight flag is reactive state — otherwise a run of finished phases advances
      once and stops instead of cascading.
- [ ] A cascade announces once, from the earliest phase it started at.
- [ ] Only `Exit criteria` and `Tasks` are computed live. Widening that set has produced a wrong
      gate twice.
- [ ] `null` clears a status override, a priority override, or an assignment — it never means
      "no change".

**Honesty**
- [ ] Nothing synced is shown without the time it was synced.
- [ ] A gate or figure with no evidence reads unmet or `not enough data`, never assumed green.

## The shape of it, in three sentences

Structure is **derived** from `.idea/` and is never editable here. Assignment and effort are
**authored** in a standalone database that the dashboard owns alone. Anything from outside — pull
request status, test results, commits — is **synced in** and always displayed with the time it was
synced. A commit is evidence that work happened; only a verified exit criterion makes it done.
