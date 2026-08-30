---
title: Database Schema
created: 2026-08-30
updated: 2026-08-30
tags: [design, management, data]
status: active
---

# Database Schema

The standalone store behind the dashboard. SQLite by default — see [[Requirements]] for the choice
and its fallbacks.

**It holds authored data only.** No text, titles, or structure for anything that came from the
plan: those live in `.idea/` and reach the page through `state.json`. The one exception is
`task_authored`, which holds tasks created on the board — work that has no home in `.idea/` yet.
Every table joins on `task_id`, the reference id described in [[Data Sources]].

## Tables

```sql
-- Everything a person records about one task.
CREATE TABLE task_meta (
  task_id      TEXT PRIMARY KEY,          -- TSK-7F3A21 (derived) or ADH-3C81 (authored)
  origin       TEXT NOT NULL,             -- derived|authored
  points       INTEGER,                   -- sprint points; NULL means unset, never 0
  estimate_min INTEGER,                   -- estimate in minutes
  sprint_id    INTEGER REFERENCES sprint(id),
  notes        TEXT,                      -- free text, dashboard-only
  orphaned_at  TEXT,                      -- set when the task leaves .idea/; never deleted
  created_at   TEXT NOT NULL,
  updated_at   TEXT NOT NULL
);

-- Authored tasks only. Derived tasks carry their text in .idea/, never here.
CREATE TABLE task_authored (
  task_id      TEXT PRIMARY KEY REFERENCES task_meta(task_id),
  title        TEXT NOT NULL,
  description  TEXT,
  epic         TEXT NOT NULL,             -- epic title from state.json; required
  status       TEXT NOT NULL,             -- blocked|in-progress|next-up|done
  promote_requested INTEGER NOT NULL DEFAULT 0,
  promoted_to  TEXT,                      -- the TSK- id it became, once promoted
  created_by   INTEGER REFERENCES assignee(id),
  created_at   TEXT NOT NULL
);

CREATE TABLE sprint (
  id           INTEGER PRIMARY KEY,
  name         TEXT NOT NULL UNIQUE,
  starts_on    TEXT NOT NULL,             -- date only
  ends_on      TEXT NOT NULL,
  goal         TEXT,
  created_at   TEXT NOT NULL
  -- status is derived from the dates, never stored
);

-- An epic assigned to a sprint as a statement of intent. Does not cascade to tasks.
CREATE TABLE epic_sprint (
  epic         TEXT PRIMARY KEY,
  sprint_id    INTEGER NOT NULL REFERENCES sprint(id),
  notes        TEXT,
  assigned_at  TEXT NOT NULL
);

-- Recorded when a task moves between sprints, so carry-over is visible.
CREATE TABLE sprint_carry (
  id           INTEGER PRIMARY KEY,
  task_id      TEXT NOT NULL,
  from_sprint  INTEGER NOT NULL REFERENCES sprint(id),
  to_sprint    INTEGER NOT NULL REFERENCES sprint(id),
  moved_at     TEXT NOT NULL
);

CREATE TABLE assignee (
  id           INTEGER PRIMARY KEY,
  name         TEXT NOT NULL,
  handle       TEXT,                      -- github login, for matching PR authors
  avatar_url   TEXT,
  active       INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE task_assignee (
  task_id      TEXT NOT NULL,
  assignee_id  INTEGER NOT NULL REFERENCES assignee(id),
  assigned_at  TEXT NOT NULL,
  PRIMARY KEY (task_id, assignee_id)
);

-- Actual time is the sum of its entries, never a typed-in total.
CREATE TABLE time_entry (
  id           INTEGER PRIMARY KEY,
  task_id      TEXT NOT NULL,
  minutes      INTEGER NOT NULL,
  note         TEXT,
  assignee_id  INTEGER REFERENCES assignee(id),
  logged_at    TEXT NOT NULL
);

-- Pull requests. Rows are synced by Claude, or added by hand as a bare link.
CREATE TABLE task_pr (
  id           INTEGER PRIMARY KEY,
  task_id      TEXT NOT NULL,
  url          TEXT NOT NULL,
  number       INTEGER,
  title        TEXT,
  author       TEXT,
  state        TEXT,                      -- draft|open|changes_requested|approved|merged|closed
  checks       TEXT,                      -- passing|failing|pending|none
  synced_at    TEXT,                      -- NULL means never synced: show status unknown
  added_at     TEXT NOT NULL,
  UNIQUE (task_id, url)
);

-- The test trail.
CREATE TABLE test_run (
  id           INTEGER PRIMARY KEY,
  task_id      TEXT,                      -- NULL when only the epic is known
  epic         TEXT,                      -- epic title, for epic-level runs
  name         TEXT NOT NULL,
  status       TEXT NOT NULL,             -- passed|failed|skipped|error
  duration_ms  INTEGER,
  url          TEXT,                      -- link to full output, if any
  detail       TEXT,                      -- failure message, truncated
  ran_at       TEXT NOT NULL,
  synced_at    TEXT NOT NULL,
  source       TEXT NOT NULL              -- github|ci-file|manual
);

-- Task status when someone or something has set it explicitly.
-- Derived tasks otherwise take their status from state.json.
CREATE TABLE task_status (
  task_id       TEXT PRIMARY KEY,
  status        TEXT NOT NULL,            -- blocked|in-progress|next-up|done
  source        TEXT NOT NULL,            -- human|agent
  note          TEXT,                     -- REQUIRED when source = agent: why
  evidence_shas TEXT,                     -- comma-separated commit shas
  pr_url        TEXT,
  confirmed_by  INTEGER REFERENCES assignee(id),  -- NULL until a person confirms
  confirmed_at  TEXT,
  set_at        TEXT NOT NULL
);

-- Written by the post-commit hook, not by Claude. Append-only.
CREATE TABLE commit_log (
  sha          TEXT PRIMARY KEY,
  author       TEXT,
  subject      TEXT NOT NULL,
  committed_at TEXT NOT NULL,
  files        INTEGER,
  insertions   INTEGER,
  deletions    INTEGER,
  untracked    INTEGER NOT NULL DEFAULT 0  -- 1 when it referenced no task
);

CREATE TABLE task_commit (
  task_id      TEXT NOT NULL,
  sha          TEXT NOT NULL REFERENCES commit_log(sha),
  PRIMARY KEY (task_id, sha)
);

-- Readiness, recomputed by the pre-push hook and by /setup.
CREATE TABLE readiness (
  phase        INTEGER NOT NULL,
  gate         TEXT NOT NULL,             -- exit-criteria|tasks|tests|checks|prs|risks|deploy-path
  met          INTEGER NOT NULL,
  detail       TEXT,                      -- what is blocking it, when not met
  computed_at  TEXT NOT NULL,
  PRIMARY KEY (phase, gate)
);

CREATE INDEX idx_commit_at   ON commit_log(committed_at DESC);
CREATE INDEX idx_meta_sprint ON task_meta(sprint_id);
CREATE INDEX idx_auth_epic   ON task_authored(epic);
CREATE INDEX idx_carry_task  ON sprint_carry(task_id);
CREATE INDEX idx_time_task ON time_entry(task_id);
CREATE INDEX idx_pr_task   ON task_pr(task_id);
CREATE INDEX idx_test_task ON test_run(task_id, ran_at DESC);
CREATE INDEX idx_test_epic ON test_run(epic, ran_at DESC);
```

Timestamps are ISO-8601 UTC strings. SQLite has no date type, and a string sorts correctly.

## Rules

- **`task_id` is not a foreign key to anything.** The tasks live in Markdown. A row may exist for a
  task that has not been seen yet, and must survive one that disappears.
- **Actual time is derived** — `SUM(time_entry.minutes)`. Never store a total that can disagree with
  its parts.
- **`points`, `estimate_min` NULL means unset.** Zero is a real value meaning zero. The UI must show
  them differently.
- **Nothing is hard-deleted by automation.** Removing an assignee is a person's action. Regeneration
  only ever sets `orphaned_at`.
- **`synced_at` NULL means never synced.** The UI shows `status unknown`, not a guess.
- **Two task origins.** `origin = 'derived'` means the text lives in `.idea/`; `origin = 'authored'`
  means it lives in `task_authored`. Never store text for a derived task. See [[Board]].
- **Sprint status is never stored.** It is computed from today against `starts_on` and `ends_on`,
  so it can never drift from the calendar.
- **Sprints must not overlap.** Enforce on write: two active sprints make every "this sprint" number
  ambiguous.
- **Points credit the sprint the task was in when completed**, not the one it was created in.
- **Members are deactivated, never deleted**, once they hold tasks or time. See [[Team]].
- **`commit_log` and `task_commit` are written by git hooks**, which run as plain shell scripts and
  never touch the vault Markdown. A commit links a task; it never marks it done.
- **An agent status update must carry a note.** `source = 'agent'` with a NULL `note` is invalid;
  reject the write. The note is what makes an automated completion auditable.
- **Only a person sets `confirmed_by`.** Until then the UI shows `done (unconfirmed)`, and the
  status never satisfies a phase exit criterion — only verified criteria do, via `/setup`.
- **`readiness` is a checklist, not a score.** Every gate is met or not met — no partial values, no
  weighting, no computed percentage.
- Schema changes ship as numbered migration files under `.management/migrations/`, applied on
  startup. Even a one-file tooling database gets migrations — otherwise the first change loses
  everyone's data.

## Seeding

On creation, insert nothing but the schema. Assignees are added by people through the drawer, or
imported from the repository's contributors on request. Never invent a name.
