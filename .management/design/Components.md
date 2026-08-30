---
title: Components
created: 2026-08-30
updated: 2026-08-30
tags: [design, management, ui]
status: active
---

# Components

What each piece must *communicate*, not what to build from scratch. Each maps to an existing project
component wherever one exists — [[Design System]] governs that mapping. Where none exists, compose
from what does.

Task cards and the drawer have their own page: [[Task Card And Drawer]].

## Header

Project name, one-line description, and current phase as `Phase N of M`. Nothing else — no logo, no
nav.

## Phase card

The largest element on the page. Phase number and name, status pill, the goal sentence in full, a
progress bar with the raw count beside it (`12/19 tasks`, never a bare `63%`), then exit criteria as
a checklist.

Criteria are the real finish line, so they are text, not icons alone. They are **derived and not
editable here** — a criterion is met by doing the work and re-running `/setup`.

## Progress bar

A filled track, roughly 8px tall, fully rounded. One colour — do not gradient it by status. Always
paired with the count; a bar alone is decoration.

## Blocker banner

Rendered only when there are blockers. Distinct background, a warning icon, and per blocker: title,
how long it has been stuck (`blocked 3 days`, computed from `since`), the epic it holds up, and the
next concrete action prefixed `Next:`. A blocker with no next action shows `Next: undecided` rather
than being hidden — the gap is the point.

## Board

Three columns — Blocked, In progress, Next up — each with a count in its header. Done is a fourth
section, collapsed by default, showing its count.

Columns hold task cards. Order within a column: blocked longest first, then by phase, then by epic,
so the column reads as a queue rather than an arbitrary list.

## Roadmap list

One row per phase: status glyph, number, name, task count, status. The current phase is emphasised.
Cut phases are struck through and dimmed, never removed.

## Recently shipped

The five most recent changelog entries. Date, what shipped, epic. Nothing more.

## Footer

`Generated <timestamp> - from .idea`. If `generatedAt` is more than seven days old, show it in the
warning colour with `- may be stale`.

Where the page shows synced PR or test data, that data carries its own `synced_at` — the footer
timestamp covers the derived structure only, and the two can legitimately differ.
