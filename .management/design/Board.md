---
title: Board
created: 2026-08-30
updated: 2026-08-30
tags: [design, management, ui]
status: active
---

# Board

The default section. Work in flight, as cards, plus the one place tasks are created.

Card and drawer anatomy live in [[Task Card And Drawer]]. This note covers the section around them:
columns, filters, and creation.

## Layout

A filter row, then five columns: **Parked**, **Blocked**, **In progress**, **Next up**, and **Done**
collapsed at the end. Each header carries its count.

Parked comes first because it is the column you want out of the way — work set aside sits to the
left of work in flight, not between it and Done.

Order within a column: blocked longest first, then by sprint, then by epic. A column should read as
a queue, not an arbitrary list.

## Creating a task

The board carries **one** control for this: a **Create task** button. The form itself lives in a
drawer, the same component the task drawer uses.

A form sitting permanently in a toolbar is three controls of visual noise on every visit, paid for
by the rare moment someone adds an ad-hoc task. Put it behind a button and the board stays a board.

The drawer asks for a title, the epic it attaches to, **points**, a priority, and an optional
description.

Epic is required — a task belonging to nothing cannot be placed, counted, or coloured. **Points are
required too**, for the same reason they are mandatory on a derived task: a member's load is the sum
of points on their open tasks, and one unpointed task makes that figure wrong by an unknown amount.
An ad-hoc task is still a task.

### Removing an ad-hoc task

An ad-hoc task can be deleted from its drawer — it was authored here and belongs to nobody else. A
**derived** task cannot: it comes from an acceptance criterion, and removing it would mean editing
`.idea/`. Offer the control only on ad-hoc cards rather than showing a disabled one everywhere.

## Priority

**Every task carries a priority**, assigned when it is generated rather than left blank for someone
to fill in later. A field that starts empty on 34 tasks stays empty.

| Priority | Assigned to |
|---|---|
| `high` | Tasks in the **current phase** — the work actually in front of you |
| `normal` | Tasks in the **next** phase |
| `low` | Everything further out |

`/setup` writes this into `state.json` alongside each task, derived from the phase it sits in. It is
a starting position, not a judgement: the drawer can override it, and an override is authored data
in `board.db` like any other.

Within a column, cards sort by priority first, then phase, then epic. A board that ignores priority
in its ordering is a board that displays priority for decoration.

Render it as a small marker with **its word**, never colour alone — `high` reads as a word for
anyone who cannot separate the hues.

## Epic colour

**Every epic is colour-coded, always**, and its colour is carried on every card belonging to it, so
a column can be read for "which epic is this" without reading a line of text.

### Deriving the colour

The anti-pattern list forbids a generated ninth categorical hue, and a real project has more epics
than that. So the colour is **not** one hue per epic:

- **Hue comes from the phase.** Four phases, four hue families, well inside the categorical limit.
- **Shade varies per epic within its phase**, by the epic's position in that phase.

Epics in the same phase therefore look related, which they are, and epics in different phases never
collide. The scheme stays legible at forty epics because it never needs a fifth hue.

> [!warning] Colour is an aid, never the identifier
> The epic **name** appears on the card regardless. The colour makes a column scannable; it does not
> carry meaning on its own. Anyone who cannot distinguish the hues loses nothing.

Contrast at least 3:1 against the card background in both themes. A colour is applied as a left
edge marker and a tinted epic chip — never as a full card background, which would fight the status
palette and make text unreadable.

## Dragging

**Every task card is draggable, always.** A board whose cards cannot be moved is a report, not a
board.

The obvious objection is that a derived task's status comes from `state.json`, so dropping it in
another column would either snap back or require editing `.idea/`. Neither happens, because a drop
does not touch the plan — it writes an **explicit status** to `board.db`:

```
task_status: task_id, status, source = human, set_at
```

A task's status is then: its explicit status if one exists, otherwise the derived one. That is
authored data about execution, which is exactly what this page is allowed to own. Dragging records
what a person says is happening; it never claims the plan changed.

### Parking

**Parked** means *deliberately not doing this, for now*. It is the honest alternative to leaving a
task sitting in Next up forever, or quietly ticking it to make a column look finished.

A parked task:

- **does not count toward its phase's task requirement**, so a phase can advance without it,
- keeps its points, its assignee and its history — parking is not deletion,
- is counted and shown wherever progress is reported, never subtracted silently.

> [!danger] Parking a task does not park an exit criterion
> Exit criteria are the definition of a phase; tasks are the means. Parking every task in a phase
> does **not** make its criteria met, and the advance gate still refuses while any is outstanding.
>
> A criterion that should no longer be required is a change to the plan, and the plan is amended
> with `/shape`. If the dashboard could wave criteria away, "done" would mean nothing.

Because parking removes work from a requirement, it must never be quiet:

- The phase advance panel names the parked count before it names anything else.
- `PROGRESS.md` reports tasks as `done / total (N parked)` rather than shrinking the denominator.
- The card keeps a `parked` marker in every column view and in search results.

### Dropping into Done

Completion is the one status that carries a claim about evidence, so it is treated differently.

- Dropping a **derived** task into Done records the human status and renders the card as
  `done · unverified`, in muted text, until `/setup` verifies the underlying exit criterion.
- Dropping an **ad-hoc** task into Done is simply done: it has no exit criterion behind it and
  nothing to verify against.
- The unverified marker is never hidden and never counted as done in readiness. Progress you cannot
  evidence stays fiction, whichever column the card sits in.

### Reverting

Dragging a derived task back to its derived column clears the explicit status rather than writing
the opposite one, so the card returns to following the plan. The drawer shows whether a status is
derived or human-set, and offers the same clear action.

### Keyboard and screen reader

Drag is a pointer convenience, never the only path.

- Each card carries a **Move** control in its drawer that sets the same status from a select, so
  every drag is achievable by keyboard.
- Cards remain `<button>`s inside list items; the drag handler is added to the card, not substituted
  for its activation behaviour. Space and Enter still open the drawer.
- A drop announces the result through the live region: `Persist documents moved to In progress`.
- `aria-grabbed` is not used — it is deprecated and unsupported. The live region carries the meaning.

## Filters

One row above the columns, each writing to the URL so a filtered view is shareable:

| Control | Default | URL |
|---|---|---|
| **Search** | Empty | `?q=` |
| Sprint | The active sprint | `?sprint=` |
| Assignee | Everyone | `?assignee=` |
| Epic | All | `?epic=` |
| Origin | All — see below | `?origin=` |

**Search matches across title, description, epic, assignee name, and task reference.** One box, not
five: someone looking for a task knows *something* about it and should not have to say which field
that something is. Matching is case-insensitive and matches substrings, so `815d` finds
`TSK-815D3E` and `peso` finds anything mentioning it.

Search narrows the same way the filters do — it never reorders, and it never hides a column. A
search with no matches shows the four columns, all empty, so it is obvious the board is filtered
rather than broken. Show the active filter count and a **Clear** control whenever anything is
narrowing the view; a board silently filtered from a stale URL is the most confusing state it has.

Filters narrow; they never reorder. A filtered board keeps the same column structure, so what
disappeared is obvious.

## Two kinds of task

This is the part to get right. Tasks reach the board two ways, and they are **not** the same thing.

| | **Derived** | **Authored** |
|---|---|---|
| Comes from | An epic's acceptance criterion in `.idea/` | Created here, on the board |
| Id | `TSK-7F3A21` — the block reference | `ADH-3C81` |
| Text | Read-only. Editing it would edit the plan. | Editable here |
| Visible to `/shape` and `/setup` | Yes | **No, until promoted** |
| Lives in | `state.json`, derived from Markdown | `board.db` only |

Both render as the same card and carry the same assignees, points, and time. An authored task shows
a small `ad-hoc` marker and its `ADH-` id, so nobody mistakes it for part of the agreed plan.

> [!warning] Why the distinction is not cosmetic
> `.idea/` is the plan of record. A task invented on the board has not been through shaping — it has
> no acceptance criteria, no phase, and no place in the roadmap. Showing it identically to a derived
> task would quietly turn the board into a second plan that nobody reviewed.

## Creating a task

A `New task` button at the top of the board, and a quieter one in each column header that
pre-selects that status.

The form asks for:

| Field | Required | Notes |
|---|---|---|
| Title | Yes | One line |
| Description | No | Markdown |
| **Epic** | **Yes** | The spec it belongs to. A task with no epic is orphan work. |
| Sprint | No | Defaults to the active sprint |
| Assignees | No | |
| Points | No | |
| Estimate | No | |
| Status | Yes | Defaults to `Next up` |

The epic selector lists epics from `state.json`, grouped by phase, with the current phase first. It
does not offer a free-text epic — associating a task with an epic that does not exist would break
the link back to the plan.

On save the task is written to `board.db` with `origin = 'authored'`, a generated `ADH-` id, and
`promote_requested = 0`.

## Promotion

An authored task can be promoted into its epic, becoming a real acceptance criterion.

The board offers `Request promotion`, which sets a flag. **The page cannot do the promotion itself**
— writing to `.idea/` goes through the Obsidian MCP on Claude's side, as [[Data Sources]] explains.

On the next `/setup`, Claude reports the requested tasks and **asks before promoting**. Adding
acceptance criteria changes the plan, and that is a decision, not a side effect. On approval it
appends the criterion to the epic note with a fresh `^tsk-` id, and the row keeps `promoted_from`
pointing at the old `ADH-` id so its assignees and logged time follow it across.

Until then, a promotion-requested task shows `awaiting promotion` on its card. Nothing is lost if it
never happens; it simply stays a board-only task.

## What the board does not do

- **No drag-and-drop between columns.** Status for a derived task comes from `.idea/` and completion
  is earned by doing the work — a drag would either lie or silently edit the plan. Status is changed
  in the drawer, for authored tasks only, and derived task completion comes from `/setup`.
- **No inline editing of task text** on the card. The drawer is the editor.
- **No delete for derived tasks.** They disappear when their criterion does. Authored tasks can be
  deleted by a person, with a confirm.
