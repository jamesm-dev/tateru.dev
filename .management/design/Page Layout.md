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

## Spacing

The dashboard is read at a glance, not filled in like a form. It should feel unhurried.

- **A spacing scale, used everywhere**: 4, 8, 12, 16, 24, 32, 48px. No arbitrary values between
  steps; if a gap needs 14px, the layout is wrong rather than the scale.
- **Cards breathe**: at least 16px of internal padding, and 12px between cards in a column. A card
  whose text touches its border reads as cramped however good the type is.
- **Columns are separated by at least 24px**, so the eye groups by column without needing a rule
  between them.
- **Sections are separated by 32px or more**, with the heading closer to its own content than to the
  section above it. Proximity is what says which heading owns which block.
- **Content has a maximum width** and does not stretch to a wide monitor. Long lines are unreadable
  regardless of spacing.

  > [!note] The board is the exception
  > A column of cards is scanned, not read as prose, so the max-width rule does not apply to it. A
  > card squeezed to fit five columns on screen is harder to read than one you scroll sideways to
  > reach.
  >
  > The board **fills the available width** and shares it evenly between columns, with a
  > **comfortable floor of roughly 15% of the viewport** per column. It scrolls horizontally only
  > once that floor no longer fits.
  >
  > Fixed-width columns are the trap: they leave the last column sliced by the viewport edge, which
  > reads as broken rather than as scrollable. Flexible columns with a minimum fill the screen and
  > degrade to a scroll honestly.
- **The drawer is roomier than the board**, not denser: it is where someone stops to read and type.

> [!warning] Density is not information
> Fitting more on screen does not communicate more. If a board needs to be compressed to fit, the
> answer is a filter, not smaller gaps.
