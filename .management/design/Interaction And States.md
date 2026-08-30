---
title: Interaction And States
created: 2026-08-30
updated: 2026-08-30
tags: [design, management, ui]
status: active
---

# Interaction And States

## Two categories, strictly separated

**Derived — never editable here.** Task text, descriptions, epics, phases, exit criteria, and
completion. A task is ticked by doing the work and re-running `/setup`. The page offers no control
that would edit `.idea/`, because that would make this a rival source of truth for the plan.

**Authored — editable here.** Assignees, points, estimates, time entries, PR links, and manual test
entries. This is what `board.db` exists to hold, and this page is its only editor.

If a control does not clearly belong to the second list, it does not ship.

## Mechanics

- Server-rendered on load. No polling, no client-side fetch of the board itself.
- Writes are small form posts or `fetch` calls to endpoints under the same route, each updating one
  field for one task id. Optimistic update, visible rollback on failure.
- The drawer is the project's existing drawer or sheet, and updates the URL so a task is linkable.
- The Done section stays a native `<details>`, working without JavaScript.
- With JavaScript unavailable, the board and drawer still render server-side and are readable; only
  editing is lost. Never a blank page.
- Refresh is a browser refresh. PR and test data refresh when Claude syncs, never on a timer.

## Write endpoints

One narrow endpoint per action, each taking a task id. Keep them boring:

```
POST  /management/api/task/:id/assignee     add or remove an assignee
POST  /management/api/task/:id/points       set or clear points
POST  /management/api/task/:id/estimate     set or clear the estimate
POST  /management/api/time                  log a time entry
POST  /management/api/task/:id/pr           attach a PR by URL
POST  /management/api/test-run              record a manual test result
```

They inherit the route's gate. A dev-only dashboard must not expose writable endpoints in
production — gate the whole route, not just the page that renders.

Validate on the server: a known task id, a sane duration, a URL that parses. Reject with a message
the drawer can display, never a bare 500.

## States to handle

Every one of these will happen. Design each rather than letting it render broken.

| State | What to show |
|---|---|
| No blockers | Omit the banner entirely. Do not render an empty box. |
| Empty board column | The column stays, with a muted `Nothing here`. Layout must not collapse. |
| All phases done | Replace the phase card with a completion summary and total elapsed time. |
| A phase is cut | Struck through in the roadmap, excluded from counts, with a note saying why. |
| `state.json` missing | A plain message: run `/setup` to generate it. Never a stack trace. |
| Snapshot over 7 days old | Footer in the warning colour with `- may be stale`. |
| Nothing built yet | Header, empty roadmap, one line saying the project has not started. |
| `board.db` missing | Board renders read-only from `state.json`. Editing hidden, with one line saying the database has not been created. |
| Task has no reference id | Card renders, id shows a muted `no id`, editing disabled for that card. Never guess an id. |
| Task unassigned | A dashed placeholder that is itself the assign control. |
| No estimate or actual | Omit the pair from the card. Empty inputs in the drawer, never `0`. |
| No test runs linked | A visible `No test runs linked`. Do not hide the section. |
| No PR linked | An `Add PR link` control in the drawer. |
| PR never synced | The link, a muted `status unknown`, and when it was added. |
| GitHub MCP unavailable | Links and last-known status still render. One line noting status cannot refresh until it is configured. |
| A write fails | Roll the field back visibly with an inline error. Never fail silently, never lose what was typed. |
| Orphaned task data | Data for a task no longer in `.idea/`: listed in a collapsed `Orphaned` section, never silently dropped. |
| No active sprint | `no active sprint` in the sidebar, and Status offers to create one. Never guess at the nearest. |
| Authored task | Card shows an `ad-hoc` marker and its `ADH-` id, so it is never mistaken for the agreed plan. |
| Promotion requested | Card shows `awaiting promotion` until `/setup` asks and the user approves. |
| Fewer than 3 closed sprints | Delivery shows a table, not a chart, and says why. |
| No epics | Specs offers the `/shape` command rather than an empty list. |
