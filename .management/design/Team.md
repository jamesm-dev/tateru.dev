---
title: Team
created: 2026-08-30
updated: 2026-08-30
tags: [design, management, ui]
status: active
---

# Team

> [!important] Capacity is the reason points are mandatory
> A member's **load** is the sum of points on their open tasks, and their **completed** figure is the
> sum on tasks they finished in the current sprint. Both are only meaningful because every task
> carries points — one unpointed task makes every load figure wrong by an unknown amount, which is
> worse than showing none.
>
> Show load as a number with its task count beside it (`13 pts across 5 tasks`), never as a
> percentage of some assumed capacity. Nobody has told this dashboard how many points a person can
> take in a sprint, and inventing that denominator would turn a fact into a fiction.

Who is working on the project, what they are on now, and what they have contributed. Entirely
authored data — `.idea/` has no opinion about people. It all lives in `board.db`.

## List

One card per member, in a responsive grid. Inactive members drop to a collapsed section at the
bottom rather than disappearing, because their past contribution still counts.

```
+--------------------------------------------------+
|  (JD)  Jamie Doe                        active   |
|        @jamiedoe                                 |
|                                                  |
|  Now:  Persist documents across restart          |
|        Restore on open                     +1    |
|                                                  |
|  Sprint 4     8 pts     3 tasks                  |
|  Overall     47 pts    22 tasks                  |
+--------------------------------------------------+
```

- **Avatar and name.** GitHub handle beneath, when set — it is what matches them to PR authors.
- **Now** — their in-progress tasks, at most two, then `+N`. Blocked tasks show first, with the
  blocked glyph, because a blocked person is the thing a lead most needs to see.
- **This sprint** — points and task count from the active sprint.
- **Overall** — points and task count across every sprint.

Points count when a task is **done**, never when it is assigned. A member's contribution is what
shipped, not what was hoped for. On a task with several assignees, points are **not** divided —
each assignee is credited with the full task, and the section says so in a line beneath the grid.
Splitting points invents precision nobody entered.

## Member drawer

Clicking a card opens a drawer:

1. **Name, handle, avatar** — all editable.
2. **Status** — active or inactive.
3. **Current tasks** — every in-progress and blocked task, with epic and sprint.
4. **Contribution by sprint** — a small horizontal bar per sprint, points completed. Measured
   history only; see [[Status]] for what may and may not be charted.
5. **Totals** — points, tasks completed, and total time logged.
6. **Recent time entries** — the last ten, with task and note.

## Adding a member

An `Add member` button opens a form: **name** (required), GitHub handle, avatar URL. Nothing else —
no email, no role, no phone. This is a build tool, not an HR system, and every extra field is
personal data with no job to do here.

Names may be imported from the repository's contributors on request, as a suggested list a person
confirms. Never auto-populate the team from git history: commit authors are not the team.

## Removing a member

Members are **deactivated**, never deleted. Their name stays on the tasks they did and the time they
logged; deleting the row would corrupt every historical total.

Deactivating hides them from assignee pickers, moves their card to the collapsed section, and leaves
every past record intact. A member with no tasks and no time entries may be deleted outright, with a
confirm — that is the one case where nothing is lost.

## Privacy

This section holds real people's names. It is why the dashboard defaults to dev-only, and why
`board.db` is gitignored by default — see [[Requirements]]. If the team wants shared assignment,
committing the database is a deliberate decision, and one worth recording as an ADR.
