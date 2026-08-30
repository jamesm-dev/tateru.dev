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

A filter row, then four columns: **Blocked**, **In progress**, **Next up**, and **Done** collapsed
at the end. Each header carries its count.

Order within a column: blocked longest first, then by sprint, then by epic. A column should read as
a queue, not an arbitrary list.

## Filters

One row above the columns, each writing to the URL so a filtered view is shareable:

| Filter | Default |
|---|---|
| Sprint | The active sprint |
| Assignee | Everyone |
| Epic | All |
| Origin | All — see below |

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
