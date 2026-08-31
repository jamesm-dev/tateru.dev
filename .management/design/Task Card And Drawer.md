---
title: Task Card And Drawer
created: 2026-08-30
updated: 2026-08-30
tags: [design, management, ui]
status: active
---

# Task Card And Drawer

The board's main unit, and the one place on the page where people type things in. Structure comes
from `state.json`; everything editable comes from `board.db` — see [[Data Sources]].

## Task card

Compact enough that a column of eight is readable, dense enough to answer "who, and how big" without
opening anything.

```
+------------------------------------------+
|  Persist documents across restart        |  title, max 2 lines
|  Write on save, restore on load, no      |  description, 1 line
|  prompt.                                 |  muted, truncated
|                                          |
|  (JD)(AM)         3 pts   2h / 3.5h      |  assignees | points | est / actual
+------------------------------------------+
```

| Field | Behaviour |
|---|---|
| **Title** | The task text. Two lines maximum, then ellipsis. Never reflow to three. |
| **Description** | One muted line, truncated. The full text lives in the drawer. Omit the line entirely when there is no description — do not leave a blank row. |
| **Assignees** | Overlapping avatars, at most three, then `+2`. Initials when there is no image. Unassigned shows a dashed placeholder that is itself the assign control, so assigning costs one click. |
| **Points** | Sprint points as a small badge. Omitted entirely when there is no value — a badge reading `no pts` is noise on a card that already has enough of it. The gap is surfaced where it matters instead: on [[Team]], where an unpointed task makes a load figure wrong. `0` is a real value and displays as `0 pts`; `1` reads `1 pt`. |
| **Estimate / actual** | `2h / 3.5h`. Actual is emphasised when it exceeds the estimate — that contrast is the whole reason to show both. `2h / —` when no time is logged. Omit the pair when neither is set. |
| **PR badge** | Small, only when a PR is linked, coloured by its state. |
| **Test glyph** | Only when the latest run failed. A passing run needs no badge; silence means fine. |
| **Origin** | An ad-hoc task is identified by its `ADH-` reference, which is already on the card. Do **not** add a separate "ad-hoc" pill beside it — the id carries the meaning, and a second marker for the same fact is clutter. |
| **Unconfirmed marker** | On a task the `project-manager` agent marked done from commits: `done · unconfirmed` in muted text with a small agent glyph. It stays until a person confirms. |

The whole card is the click target and opens the drawer. It must be a `<button>` or a link — never a
`div` with a click handler — so it is keyboard-reachable.

Durations are always human units: `30m`, `2h`, `3.5h`, `2d`. Never raw minutes in the UI.

## Task drawer

Opens from the right on desktop at full height; a bottom sheet under 768px. **Use the project's
existing drawer, sheet, or dialog component.** Do not build one.

Contents, in order:

1. **Title** — full, wrapped, never truncated.
2. **Reference id** — `TSK-7F3A21`, monospace, click-to-copy. Muted `no id` when absent.
3. **Parent epic** — epic name and its phase. A relative Markdown link to the note in
   `.idea/epics/`, never a wikilink: that is a separate vault and a wikilink cannot reach it.
4. **Description** — the full text, rendered as Markdown.
5. **Assignees** — editable. Add and remove inline against the `assignee` table; saves immediately.
6. **Effort** — points, estimate, and actual. Points and estimate are typed directly. Actual is the
   **sum of logged time entries**, shown as a total with the entries listed beneath, each with its
   note and who logged it. Never a typed-in total that can disagree with its parts.
7. **Test trail** — runs linked to this task, newest first: name, pass/fail, when it ran, duration,
   and a link to full output where one was synced. Epic-level runs appear labelled as such. Empty
   state is a visible `No test runs linked`, not a hidden section.
8. **Pull request** — number, title, author, and **state as its own badge**: draft, open, changes
   requested, approved, merged, closed. Plus the checks line where synced. The row links out. The
   `synced_at` time shows beneath it, and `status unknown` when it has never synced.
9. **Status provenance** — when the status was set by the agent: the note explaining why, the
   commits it relied on as short SHAs linking to the diff, the pull request if there is one, and a
   **Confirm** button. Confirming records who and when, and drops the `unconfirmed` marker. A
   **Reject** action reverts the status and keeps the note, so the reasoning is not lost.
10. **Timestamps** — created, last updated.

### Editing

Every editable field:

- saves on blur, or on explicit confirm for anything destructive,
- shows a brief saved state,
- **rolls back visibly with an inline error** if the write fails — never a silent failure, never a
  lost keystroke,
- never triggers a full page reload.

Only fields backed by `board.db` are editable. Task text, epic, phase, and completion are derived and
read-only here; the drawer offers no control that would edit `.idea/`.

### URL and focus

The drawer sets `?task=TSK-7F3A21` so a task is linkable and the back button closes it. It is a modal
dialog: focus moves in on open, is trapped while open, returns to the originating card on close, and
Escape closes it.
