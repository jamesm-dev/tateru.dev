---
title: DESIGN
created: 2026-08-30
updated: 2026-08-30
tags: [design, management, moc]
status: active
---

# Dashboard Design

How the `/management` dashboard looks and behaves when `/setup` builds it. Four sections behind a
sidebar — Board, Specs, Team, Status. This is the index; the detail lives in [design/](design/), one
concern per note.

**Read [[Requirements]] and [[Data Sources]] before writing any code.** They carry the two decisions
everything else depends on: where the data lives, and what the page may edit.

## What this page is for

One person, glancing for ten seconds, answering four questions:

1. **What phase are we in, and how far through?**
2. **Is anything stuck?**
3. **What is next?**
4. **Who is on what, and how much is left?**

Everything else is secondary. If a section does not serve one of those four, it goes below the fold,
into the task drawer, or does not ship.

It is also the one place where assignment and effort are **recorded** — the only data here a person
types in rather than derives.

> [!warning] Record and measure, but never forecast
> Sprint points, estimates, and actuals are shown because someone entered them. [[Status]] charts
> that history and flags risks from rules that fire on observable facts. It does not draw a
> burndown line, compute a velocity, or project a completion date — a handful of sprints cannot
> support one, and a projection dressed in the same UI as a measurement is not honest.

## The notes 

**Foundations**

| Note | Covers |
|---|---|
| [[Requirements]] | What must exist first: the standalone database, the GitHub MCP, and what degrades when each is missing |
| [[Data Sources]] | The three stores, the task reference id that joins them, and why sync beats live fetch |
| [[Database Schema]] | Tables, rules, and migrations for `board.db` |
| [[Sprints]] | What a sprint is, how it differs from a phase, and how points are counted |

**The four sections**

| Note | Covers |
|---|---|
| [[Navigation]] | The sidebar, the four routes, and the page shell |
| [[Board]] | The task board, filters, and creating tasks against an epic |
| [[Specs]] | The epics, the epic drawer, and what may be edited there |
| [[Team]] | Members, current work, contribution, and adding people |
| [[Status]] | Insights, the risk rules, sprint progress, and every chart |

**Craft**

| Note | Covers |
|---|---|
| [[Design System]] | Using the project's own theme and components, and the visual language |
| [[Page Layout]] | Information hierarchy, the shell, the wireframe, responsive behaviour |
| [[Components]] | Header, phase card, blockers, board, roadmap, shipped, footer |
| [[Task Card And Drawer]] | The card, the drawer, and every editable field |
| [[Interaction And States]] | What is editable, the write endpoints, and every state to handle |
| [[Accessibility And Anti-Patterns]] | Keyboard, screen reader, contrast, and what not to do |

## The shape of it, in three sentences

Structure is **derived** from `.idea/` and is never editable here. Assignment and effort are
**authored** in a standalone database that the dashboard owns alone. Anything from outside — pull
request status, test results, commits — is **synced in** and always displayed with the time it was
synced. A commit is evidence that work happened; only a verified exit criterion makes it done.
