---
title: Page Layout
created: 2026-08-30
updated: 2026-08-30
tags: [design, management, ui]
status: active
---

# Page Layout

## Information hierarchy

Top to bottom, in priority order. This order is the design.

1. **Current phase** — name, goal, progress, exit criteria.
2. **Blockers** — only if any exist. Loud when present, absent when not.
3. **The board** — task cards by status.
4. **All phases** — the roadmap at a glance.
5. **Recently shipped** — the last handful of changelog entries.
6. **Footer** — `generatedAt`, so a stale snapshot is obvious.

The task drawer sits above all of this when open. Everything a single task needs lives there, which
is what keeps the board itself scannable — see [[Task Card And Drawer]].

## Shell

A fixed 240px sidebar on the left, content to its right with a max width around 1100px. The sidebar
carries the four sections and is specified in [[Navigation]].

The wireframe below is the Board section, which is the default route. Specs, Team, and Status have
their own notes.

```
+----------------------------------------------------------+
|  Project Name                          Phase 1 of 4       |  header
|  One-line description                                     |
+----------------------------------------------------------+
|  PHASE 1 - Core loop                       in progress    |  current phase
|  Goal: Users can save and reopen a document               |
|  [###############.........]  12/19 tasks                  |
|                                                           |
|  Exit criteria                                            |
|   [x] A document survives a restart                       |
|   [x] Round trip covered by a test                        |
|   [ ] Load time under 200ms on the sample set             |
+----------------------------------------------------------+
|  (!) 1 BLOCKER                                            |  only when non-empty
|  Storage adapter undecided - blocked 3 days               |
|  Next: spike both options, decide Friday                  |
+----------------------------------------------------------+
|  BOARD                                                    |
|  +--------------+--------------+--------------+           |
|  | Blocked   1  | In prog   3  | Next up   4  |           |
|  +--------------+--------------+--------------+           |
|  | Persist docs | Restore on   | Load under   |           |
|  | across resta.| open         | 200ms        |           |
|  | Write on sav.| Read the las.| Index the sa.|           |
|  |              |              |              |           |
|  | (JD)(AM) 3p  | (JD)     2p  | ( - )        |           |
|  |     2h/3.5h  |     1h/0.5h  |              |           |
|  +--------------+--------------+--------------+           |
|  > Done (12)                            collapsed         |
+----------------------------------------------------------+
|  ROADMAP                                                  |
|  (*) 0  Walking skeleton            7/7    done           |
|  (o) 1  Core loop                  12/19   in progress    |
|  ( ) 2  Accounts                    0/8    planned        |
|  ( ) 3  Sharing                     0/6    planned        |
+----------------------------------------------------------+
|  RECENTLY SHIPPED                                         |
|  2026-08-28  Document persistence - Editor Core           |
|  2026-08-26  Deploy pipeline - Skeleton                   |
+----------------------------------------------------------+
|  Generated 2026-08-30 14:02 - from .idea                  |  footer
+----------------------------------------------------------+
```

## Responsive

- **Under 768px:** board columns stack vertically, each keeping its heading and count. The phase card
  and roadmap are already single-column. Task cards keep every field — a phone shows the same
  information, just taller. The drawer becomes a bottom sheet.
- **768px and up:** the three-column board, drawer from the right.
- Progress bars and the roadmap list stay fluid at every width.
- Nothing is hidden at small sizes. Truncation is fine; omission is not.
