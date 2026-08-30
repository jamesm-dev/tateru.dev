---
title: Navigation
created: 2026-08-30
updated: 2026-08-30
tags: [design, management, ui]
status: active
---

# Navigation

The dashboard is four sections behind a persistent sidebar. One route each, one job each.

| Menu | Route | Job | Note |
|---|---|---|---|
| **Board** | `/management` | The task board. Work in flight, and where tasks are created. | [[Board]] |
| **Specs** | `/management/specs` | The epics. What each contains and which sprint it sits in. | [[Specs]] |
| **Team** | `/management/team` | Who is working on what, and their contribution. | [[Team]] |
| **Status** | `/management/status` | Insights, risks, and sprint progress. | [[Status]] |

Board is the default and the index route. Someone opening the dashboard wants today's work, not a
chart.

## Sidebar

```
+---------------+------------------------------------------+
|  Project Name |                                          |
|  Sprint 4     |                                          |
|               |                                          |
|  > Board   12 |            section content               |
|    Specs    6 |                                          |
|    Team     4 |                                          |
|    Status     |                                          |
|               |                                          |
|               |                                          |
|  Phase 1 of 4 |                                          |
|  [######...]  |                                          |
+---------------+------------------------------------------+
```

- **Fixed 240px** on the left, full height, its own scroll. Content area scrolls independently.
- **Header** — project name, and the active sprint beneath it. The sprint is here because it scopes
  three of the four sections; see [[Sprints]].
- **Items** — icon and label. A count badge where one is meaningful: open tasks on Board, epics in
  the current phase on Specs, active members on Team. Status carries no count; a number there would
  imply a problem count that changes meaning as rules change.
- **Footer** — current phase and a compact progress bar, always visible. It is the one piece of
  context that matters in every section.
- Built from the project's existing nav or list components. If it ships a `Sidebar`, use it.

## Behaviour

- The active item is marked by **background, weight, and a leading indicator** — never colour alone.
- Navigation is real links (`<a href>`), so middle-click, right-click, and browser history all work.
- Server-rendered per route. Do not turn this into a client-side router for four pages.
- Section state lives in the URL: `?sprint=`, `?assignee=`, `?epic=`, `?task=`. Any view someone is
  looking at can be pasted to a colleague.
- The sidebar does not collapse on desktop. There is not enough here to be worth hiding.

## Responsive

- **Under 1024px:** the sidebar becomes a top bar of four items, horizontally scrollable if needed.
  Project name and phase move into the page header.
- **Under 768px:** the same top bar, icons with labels beneath, and the phase bar under it.
- The sidebar is never a hamburger. Four items do not justify hiding navigation behind a tap.

## Accessibility

- `<nav>` with an accessible name, containing a list of links.
- The active link carries `aria-current="page"`.
- Count badges are inside the link's accessible name — `Board, 12 open tasks` — not floating text a
  screen reader reads separately.
- Focus order is sidebar, then main content. A skip link jumps straight to main.
