---
title: README
created: 2026-08-30
updated: 2026-08-30
tags: [meta, management]
status: active
---

# Project Management

This folder tracks **how the work is actually going**. It is the execution layer sitting under the
idea vault in `.idea/`.

## The split — the one thing to understand

| Folder | Holds | Changes when |
|---|---|---|
| `.idea/` | **Intent.** What we are building and why. Ideas, spec, roadmap, epics, decisions. | The plan changes |
| `.management/` | **State.** Progress, blockers, dates, what shipped. | Work happens |

`.idea/` is upstream. Everything here is **derived** from it, and adds only what `.idea/` does not
track: status, dates, blockers, and a record of what actually shipped.

> [!warning] This folder is not a second source of truth for the plan
> If reality contradicts the roadmap, that is a signal to amend the plan with `/shape` — not to
> quietly edit the roadmap from here. Never write back into `.idea/` from this folder.

There is one exception, and it is deliberate. **Assignees, estimates, actuals, sprint points, links,
and test runs are authored here**, because `.idea/` has no opinion about who does a task or how long
it took. They live in `board.db`, keyed on each task's reference id, and are never derived from
anything. Structure stays derived; that data does not.

## What lives here

| File | Holds | Written by |
|---|---|---|
| `README.md` | This file | By hand |
| `DESIGN.md` | Index of the dashboard design | By hand |
| `design/` | The design spec, one concern per note | By hand |
| `board.db` | Assignees, effort, PR links, test runs — the dashboard's own store | People, via the dashboard |
| `BOARD.md` | Every task by status, each linked to its epic | Generated |
| `PROGRESS.md` | Per-phase rollup with exit criteria | Generated |
| `BLOCKERS.md` | What is stuck, since when, and the next action | Generated + hand notes |
| `CHANGELOG.md` | Dated log of what actually shipped | Appended |
| `state.json` | Machine-readable snapshot — the dashboard's data source | Generated |

Only `README.md`, `DESIGN.md`, and `design/` exist yet. The rest are created by `/setup` once there
are real epics to derive them from — writing them now would mean inventing progress that has not
happened.

## How it stays accurate

- Regenerated from `.idea/` on every `/setup` run.
- A task exists only if an epic's acceptance criteria created it. Nothing is invented.
- An epic with no acceptance criteria is reported as a gap, not filled in.
- A task is ticked only against evidence — a verified check, not an assumption.
- Hand-written notes in `BLOCKERS.md` and `CHANGELOG.md` survive regeneration; derived sections
  are rewritten.
- `state.json` is generated wholesale. Never hand-edit it.

## Obsidian

Same conventions as `.idea/` — see
[the vault contract](../.claude/skills/shared/vault-contract.md).

**Open this folder itself as a vault**, not the project root. Obsidian ignores any folder whose name
starts with a dot, so `.management/` is invisible if it sits inside a vault — but it works fine as a
vault *root*, because the rule applies to a vault's contents, not to the root itself.

That makes `.idea/` and `.management/` two separate vaults.

> [!warning] Wikilinks cannot cross between them
> `[[Some Epic]]` written here will not reach `.idea/epics/`. Use a relative Markdown link for
> anything pointing at the idea vault — it resolves in VS Code and on GitHub, and degrades to plain
> text in Obsidian rather than showing as a broken link. Wikilinks are for links *within* this
> folder, such as [[DESIGN]].

## The dashboard

`/setup` offers to serve this at a `/management` route in the app. It reads `state.json` and is
built to [[DESIGN]]. It is opt-in and gated — by default it returns a 404 outside development,
because the page exposes the roadmap, blockers, and unshipped plans to anyone who can reach it.
