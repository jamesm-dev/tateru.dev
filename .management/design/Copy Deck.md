---
title: Copy Deck
created: 2026-08-31
updated: 2026-08-31
tags: [design, management, ui, reference]
status: active
---

# Copy Deck

The exact words. Copy is where an honest dashboard is won or lost — `done` and `done · unverified`
are the same six pixels apart and mean entirely different things.

A rebuild may translate these, but may not soften them. If a phrase here sounds blunter than a
product would normally ship, that is the point: it is the phrase that stops someone reading a
guess as a fact.

## Empty states

Every empty state is **visible text**, never a hidden section. A section that disappears when empty
teaches the reader it does not exist.

| Where | Exactly |
|---|---|
| Board column with no cards | `Nothing here` (muted; the column keeps its heading and does not collapse) |
| Task drawer, no test runs | `No test runs linked` |
| Task drawer, no PR state | `status unknown` |
| Phase with no epics | `No epics in this phase.` |
| Sprint select, no sprint chosen | `No sprint` |
| Task drawer, none exist yet | `No sprints yet — create one on Status.` |
| Status, none exist yet | `No sprints yet. A project without them is perfectly normal — create one below…` |
| A figure with no evidence | `not enough data` |

> [!danger] Never the words "No sprint defined"
> The sidebar shows the **current phase** instead, and the sprint line is absent entirely until a
> sprint exists. "No sprint defined" reads as a misconfiguration when it is a legitimate state —
> and it wastes the one line that could have said something useful.
>
> `No sprint` as a *select option* is fine and unrelated. It is a choice, not a diagnosis.

## Status and provenance

| Meaning | Exactly |
|---|---|
| A person dropped a derived task into Done, unverified by an exit criterion | `done · unverified` |
| The agent marked a task done from commit evidence | `done · unconfirmed` |
| An advance was made here, not yet written to the roadmap by `/setup` | `roadmap pending` |
| A phase the project has moved beyond | `advanced past` |
| A phase moved beyond with an advance still pending | `advanced past, roadmap pending` |

The separator is a middle dot with spaces — ` · `. It reads as a qualifier rather than a new
sentence, which is what keeps the qualification attached to the word it weakens.

## The gate

Counts, never percentages, and parked work always visible beside the denominator it was excluded
from:

```
{met} of {total} met                        # nothing parked
{met} of {total} met, {parked} parked       # something parked
```

Outstanding work, assembled from the non-empty parts and joined with `, `:

```
{n} exit criterion unmet   /  {n} exit criteria unmet
{n} task not done          /  {n} tasks not done
{n} blocked or in progress
none blocked or in progress, {n} parked
```

Singular and plural are both written out. `1 tasks not done` undermines every other number on the
page.

> [!warning] Parked is never rendered as met
> The gate reads `4 of 7 met, 3 parked` — not `7 of 7`. Parking is a decision to proceed without
> something, recorded as such. The moment parked work counts as met, the number stops meaning
> anything and the dashboard is decoration.

## Controls

| Control | Label | Notes |
|---|---|---|
| Advance past outstanding work | `Advance anyway` | Behind a confirmation naming what will be left |
| Undo a pending advance | `Step back` | Available until `/setup` consumes it |
| Set a criterion aside | `Park` | On every outstanding criterion |
| Restore one | `Unpark` | Parked criteria stay listed, never hidden |
| Clear a filter or search | `Clear · showing {n} of {m} {noun}` | The count is part of the control |

A disabled button with no explanation is forbidden. When the gate fails, the specific unmet criteria
and the outstanding task count are listed. When phases are read-only, one line says they come from
the roadmap via `/shape`.

## Announcements

Changes that happen without a click are announced through a live region:

```
{task title} moved to {column label}
```

An automatic phase advance names which phases were crossed and what it moved past. A cascade across
several finished phases is announced **once**, from the earliest phase it started at — not once per
phase.

## Sync and honesty

Nothing synced is shown without the time it was synced. Anything the page cannot verify says so
rather than assuming green.

- Gates the browser cannot compute are shown with their sync time and named as stale. Only
  **Exit criteria** and **Tasks** are live — see [[Derivations]].
- A commit is **evidence that work happened**; only a verified exit criterion makes it done. That
  sentence, or one carrying the same distinction, appears at the top of the Board.
- No burndown, no velocity, no forecast date, and no wording that implies one. `Committed` and
  `completed` points are both shown because someone entered them.

## Tone

Short sentences. The strongest word first. No exclamation marks, no encouragement, no congratulation
on progress — a dashboard that cheers is a dashboard that will eventually cheer at the wrong moment.

Where something is uncertain, say what is missing rather than hedging. `No test runs linked` beats
`No data available`, because the first tells you what to go and do.

## Related

[[Reference Implementation]] · [[Derivations]] · [[Status]] · [[Board]] ·
[[Accessibility And Anti-Patterns]]
