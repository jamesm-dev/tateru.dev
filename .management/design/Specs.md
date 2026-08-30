---
title: Specs
created: 2026-08-30
updated: 2026-08-30
tags: [design, management, ui]
status: active
---

# Specs

The epics, as agreed in `.idea/`. This section is the plan's face on the dashboard: almost entirely
derived, and almost entirely read-only.

## List

Epics grouped by phase, current phase first and expanded, later phases collapsed. Cut phases are
last, dimmed.

Each row:

```
+----------------------------------------------------------+
|  Editor Core                        Sprint 4    8/12      |
|  Save, restore, and reopen a document                     |
|  [############........]   in progress   (JD)(AM)(+1)      |
+----------------------------------------------------------+
```

- **Title**, and the outcome sentence beneath it.
- **Sprint** the epic is assigned to, or `unscheduled`. See [[Sprints]].
- **Task count** done over total, with a progress bar. Counts include authored tasks associated
  with the epic, since they are real work — the mix is shown in the drawer.
- **Status** from the epic note: planned, in progress, done, cut.
- **Assignees** — the distinct people across its tasks, not a separately assigned owner. An epic has
  no owner field; it inherits from its work.

Filters: phase, sprint, status. Sorting is by phase then roadmap order — never by completion, which
would make the list jump around as work lands.

## Epic drawer

Clicking a row opens a drawer. Same component as the task drawer; see [[Task Card And Drawer]].

1. **Title** and status.
2. **Outcome** — what is observably true when this is done, in full.
3. **Phase** and **sprint**. The sprint is editable; the phase is not — phases come from the
   roadmap.
4. **Approach** and **risks** from the epic note, rendered as Markdown.
5. **Source ideas** — the ideas this epic came from, as relative Markdown links into `.idea/notes/`.
   Never wikilinks: that is a separate vault.
6. **Tasks** — every task in this epic, grouped by status, each showing assignees, points, and
   estimate against actual. Derived and authored tasks are listed together, with authored ones
   marked. Clicking one switches to its task drawer.
7. **Effort roll-up** — total points, total estimate, total actual, and the gap. This is the number
   people actually want from an epic view.
8. **Dependencies** — blocked by, and blocking, from the epic note.
9. **Link to the note** — a relative Markdown link to `.idea/epics/<Epic>.md`, for the full text.

## What is editable here

Only two things:

- **The sprint** an epic is assigned to.
- **Notes** — a free-text field stored in `board.db`, for things that are not part of the spec.

Everything else — title, outcome, acceptance criteria, phase, approach, risks — is the plan. Editing
it here would make the dashboard a second source of truth. To change an epic, run `/shape`; the
drawer says so, with the command, rather than leaving the reader to guess.

## Empty and edge states

| State | What to show |
|---|---|
| No epics yet | One line: the project has not been shaped. Offer the `/shape` command. |
| Epic with no tasks | The row renders with `0/0` and no bar. The drawer says the epic has no acceptance criteria, which is a gap worth fixing in `/shape`. |
| Epic not in any sprint | `unscheduled`, in muted text. Not an error — plenty of work is unscheduled. |
| Cut epic | Struck through, excluded from counts, with the reason if the note carries one. |
