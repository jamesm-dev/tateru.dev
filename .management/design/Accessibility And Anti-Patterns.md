---
title: Accessibility And Anti-Patterns
created: 2026-08-30
updated: 2026-08-30
tags: [design, management, ui, accessibility]
status: active
---

# Accessibility And Anti-Patterns

## Accessibility

- One `<h1>`, then an `<h2>` per section, in document order matching the visual order.
- Board columns are lists, not divs. Task cards are list items containing a `<button>`, so they are
  reachable and activatable by keyboard.
- The drawer is a modal dialog: focus moves into it on open, is trapped while open, returns to the
  originating card on close, and Escape closes it.
- Avatars carry the assignee's name as accessible text, not just an image. A group is announced as
  `Assigned to A and B`, never as unlabelled images.
- The progress bar carries its count as text. If it uses `role="progressbar"`, it also carries
  `aria-valuenow`, `aria-valuemin`, and `aria-valuemax`.
- PR state and test state are never colour alone — each carries its word (`approved`, `failing`).
- Every editable field has a real `<label>`. Saving announces itself politely through a live region,
  and an error is announced assertively.
- Navigation is a `<nav>` of links; the active one carries `aria-current="page"`, and count badges
  sit inside the link's accessible name.
- Every chart has a table view with the same numbers, and identity is never colour-alone: two or
  more series always carry a legend, four or fewer are direct-labelled too.
- Severity uses the reserved status palette with an icon and its word — never colour alone.
- Contrast at least 4.5:1 for body text and 3:1 for glyphs and bars.
- Status glyphs are decorative and marked `aria-hidden`, since the adjacent text label already
  carries the meaning.

## Anti-patterns

**Data and truth**

- A percentage without the underlying count.
- Counting unverified work as done to make the bar look better.
- Burndown, velocity, or forecast dates derived from a handful of points.
- A dual-axis chart. Two measures of different scale get two charts, never two y-scales.
- A rainbow sequential ramp, a hue at a diverging midpoint, or a generated ninth categorical hue.
- A pie chart of two slices where a meter belongs, or a one-bar bar chart where a stat tile belongs.
- A trend line through three sprints.
- Ranking people by points. The Team section shows contribution; it is not a leaderboard.
- Drag-and-drop between board columns, which would either lie about derived status or silently edit
  the plan.
- Showing a synced PR or test status without the time it was synced.
- Presenting stale data as current.

**Boundaries**

- Editing anything derived from `.idea/` — task text, epics, phases, completion.
- Storing text or structure for a *derived* task in `board.db`. Only authored tasks carry their own
  text, in `task_authored`.
- Matching authored data to a task by its text instead of its reference id.
- Adding the dashboard's tables to the application's own migrations.
- Having the page call an MCP server. It cannot; sync writes to the database instead.
- Deleting a person's data during an automated regeneration.

**Design**

- A second colour palette, type scale, or spacing system invented for this page.
- A hardcoded hex value where the project has a token for it.
- A hand-rolled card, badge, progress bar, or drawer when the project already ships one.
- A new dependency — chart library, icon pack, UI kit — added just for this page. One database
  driver is the only exception.
- A page that looks like a different product from the rest of the app.

**Behaviour**

- A `div` with a click handler where a `<button>` belongs.
- A silent write failure, or one that discards what was typed.
- A blocker or test section that renders empty instead of showing its empty state.
- Client-side fetching of data that could have been read at render time.
- Writable endpoints exposed in an environment where the page itself is gated off.
