---
name: setup
description: Set up the development environment and build the current roadmap phase, driven by .idea/SPECS.md and .idea/ROADMAP.md. Use when the user wants to start the project, scaffold the codebase, set up the dev environment, initialise the stack, or build the next phase. Checks .idea/ for context first and routes to shape or brainstorm if the spec is missing.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, WebSearch, WebFetch
---

# Setup

Turn `.idea/SPECS.md` into a working repository, one roadmap phase at a time.

> [!important] Application code lives in `app/`
> The repository root belongs to the workflow — `.idea/`, `.management/`, `.claude/`, and the
> project's own `README.md`. Everything you scaffold goes in **`app/`**: the manifest, the source
> tree, the lockfile, the test config, the build output.
>
> This keeps the product and the workflow from colliding. A clone can be built in without
> overwriting the boilerplate's own documentation, `.idea/` stays at the root where every skill
> expects it, and "what is the project" never becomes ambiguous. A monorepo later adds
> `app/`-siblings; it does not move `app/`.
Read `.claude/skills/shared/vault-contract.md` before writing anything to `.idea/`, and
`.claude/skills/shared/quality-bar.md` before any structural or technology decision — including the
ones `SPECS.md` left open and the ones a scaffolder makes on your behalf.

**Write no project code before Phase 3 of this skill is confirmed.**

## Phase 1 — Read `.idea/` first. Always. Before anything else.

1. `ls -R .idea/ 2>/dev/null`.
2. Route on what is there:

| State | Action |
|---|---|
| `SPECS.md` **and** `ROADMAP.md` exist | Read both in full, plus every epic in the target phase and the idea notes those epics cite. → Phase 2. |
| `SPECS.md` but no `ROADMAP.md` | Read it, build from the v1 scope, and offer `/shape` to phase the rest properly. |
| `.idea/` with notes but no `SPECS.md` | **Run the `shape` skill's flow** — that is where the spec-writing interview lives. Do not duplicate it here. Return when SPECS.md is signed off. |
| No `.idea/` at all, or nearly empty | Say so and offer `/brainstorm`. If the user wants to skip straight to code, run the shape interview to produce a minimal SPECS.md first — never scaffold from an unrecorded stack decision. |

3. Read the repo for signals that **override** the spec: existing lockfile, `package.json`,
   `pyproject.toml`, `go.mod`, `Cargo.toml`, `Dockerfile`, CI config, `.env.example`. Look in
   **`app/`** first, then the root — a project set up by an earlier run keeps all of these in
   `app/`. A lockfile on disk beats a spec table. On genuine conflict, ask — never silently pick
   one.

## Phase 2 — Pick the phase

Report where the roadmap stands and name the target phase — the lowest-numbered one not `done`.
State its Goal, Exit criteria and Non-goals back to the user, and confirm that is the target.

First run always includes the Phase 0 walking skeleton, even if the user asks to jump ahead:
the skeleton is what makes later phases safe. Say why if you have to override an ask.

## Phase 3 — Plan, then confirm

Produce a concrete ordered list of exactly what you will create and run: scaffolder invocation,
dependencies, directory tree, config files, env files, database setup, scripts, CI, git hooks, docs,
and the `.management/` tracker. Every path in that list is under `app/`, except `.management/`,
`.claude/`, and the root `README.md`.

Structure is a decision, not a default. Per `quality-bar.md`, state your reasoning for the module
boundaries, the data-access approach, and the rendering or data-fetching strategy — including where
you are keeping what the scaffolder generated and where you are overriding it. Where a choice
resolves toward quality at a visible cost in setup effort or added concepts, say so in this list so
the user can disagree before you execute rather than after.

Flag anything that touches the network, installs globally, or creates cloud resources.
**Get explicit confirmation before executing.**

## Phase 4 — Execute

Load `references/execution.md` and follow its order. In short: scaffold with the ecosystem's own
tool → dependencies → config → env → database → scripts → tests → CI → **git hooks** → docs →
verify → git.

The commit-tracking hooks are not optional: they are what keeps `.management/` honest between runs.
See `references/git-hooks.md`.

Non-negotiables:
- Never fabricate a version number or CLI flag. Verify, or let the official scaffolder decide.
- Never invent or commit a secret. `.env.example` documents keys with empty values.
- Never overwrite a file without reading it first and telling the user.
- Build only the target phase. An epic from Phase 3 is out of scope in Phase 1, however tempting.

## Phase 5 — Verify honestly

Actually run install, lint, typecheck, test, and build, and show the real output. Then walk the
target phase's **Exit criteria** one at a time and mark each met or not met with the evidence.

**Measure the `SPECS.md` performance budget and report the real numbers**, against the target device
and network it names. On Phase 0 this is what converts the stack from a belief into a fact; on later
phases it catches the drift that makes a project slow one commit at a time. A missed budget is
reported as missed — fix it, or record it as an accepted regression with a reason. Never round it,
and never omit it because the phase was otherwise green.

If something fails: fix it. If you cannot, say so plainly and leave the criterion unmet. A phase
reported as complete with a failing check is worse than an honest partial.

## Phase 6 — Project management

Once the phase is built and verified, stand up `.management/` — the execution tracker.
Load `references/management.md` for the layout, templates, and the `state.json` schema.

It is **derived from `.idea/`**, never a second source of truth. `.idea/` holds intent (what and
why); `.management/` holds state (progress, blockers, dates, what shipped). Create it on the first
run; refresh it on every later run.

1. **Ingest commits first.** Read `.management/commits.jsonl` and any `board.db` commit rows written
   since the last run. Map them to tasks by reference id; a commit is evidence, never completion.
   Commits referencing no task become untracked delivery-log rows, so unplanned work is still
   counted.
2. Read `.idea/ROADMAP.md` and every `.idea/epics/*.md`.
3. Derive tasks from epic acceptance criteria. Never invent a task with no epic behind it, and never
   quietly drop one — an epic with no criteria is a gap, so report it.
4. Write `README.md`, `BOARD.md`, `PROGRESS.md`, `BLOCKERS.md`, `CHANGELOG.md`, and `state.json`.
   Carry each task's reference id (`^tsk-`) through into `state.json`; a task without one cannot
   hold assignees or effort.
5. Mark done only what Phase 5 actually verified. Progress you cannot evidence is fiction.
6. Preserve hand-written notes in `BLOCKERS.md` and `CHANGELOG.md`; rewrite only derived sections.
7. If the dashboard exists, create or migrate `board.db` per `.management/design/Database Schema.md`,
   then sync pull request and test data into it. **Never** clear a row a person authored: a task id
   that has left `.idea/` is marked orphaned, not deleted.
8. **Recompute deployment readiness** — the seven gates in `references/git-hooks.md` — and write it
   into `PROGRESS.md` as a checklist. Report gates met over gates total, never a percentage.

### Install the project management agent

Create or refresh `.claude/agents/project-manager.md` — the agent that judges whether the project is
succeeding across idea, development, production, and maintenance, and keeps it moving toward
deployment, using `.idea/` and `.management/` as its evidence.

**If a `create-agent` skill is available, use it.** Otherwise write the definition directly:
frontmatter with `name`, a trigger-rich `description`, `tools`, and `model`.

Its write scope is deliberately narrow, and the definition must say so:

- **May** create epics at `status: suggested` in `.idea/epics/`, and set task status in
  `board.db` from commit evidence — the latter always carrying a note, the commit SHAs, and the PR
  where one exists, with `confirmed_by` left null for a person to confirm.
- **May not** edit `SPECS.md`, `ROADMAP.md`, an accepted epic, an idea note, any `.management/`
  Markdown, or tick an acceptance criterion. It may not deploy, tag, or push.

Give it no Write or Edit tool: those two paths are the whole of its write access. Changing the plan
is `/shape` or `/epic`, regenerating state is `/setup`, shipping is `/ship`.

On a later run, update its description if the project's shape changed; never overwrite a definition
the user has edited without saying so first.

### Then ask about the dashboard

Use `AskUserQuestion`: does the user want a `/management` route in the app serving this as a
dashboard? Lead with the recommended option, and state the trade-off in one line — such a route
exposes the roadmap, blockers, unshipped plans, and team names to anyone who can reach it.

It is four sections behind a sidebar — Board, Specs, Team, Status — backed by a standalone
database. Say that up front: it is more than a status page, and it is a real build.

Offer: **dev-only (recommended)** · auth-gated in production · public · none.

Build it only on a yes. **Read `.management/DESIGN.md` and the notes in `.management/design/`
first** - they are the spec. Check `design/Requirements.md` before starting: it needs a standalone
database, and pull request status needs the GitHub MCP. If either is missing, say so and build the
part that works rather than faking the rest.

Use the framework in `SPECS.md`, build from the project's own theme and components, add no new
dependencies beyond the one database driver, and apply the gate they picked.

If the project has no web surface — a CLI, a library — say so and offer the reference's fallback
instead: a self-contained `.management/dashboard.html` plus a `board` script that prints progress.

## Phase 7 — Record and hand off

- Append a dated entry to `## Setup log` in `SPECS.md`; set `status: active` and bump `updated`.
- In `ROADMAP.md`, tick met exit criteria and set the phase `status`.
- Set the built epics to `done` or `in-progress`; bump their `updated`.
- Write an ADR for any decision you had to make that SPECS.md did not cover.
- Regenerate `INDEX.md`.
- Write or update `CLAUDE.md` with the stack, conventions, and the real commands to run.
- Refresh `.management/` so `BOARD.md`, `PROGRESS.md` and `state.json` match what Phase 5 verified.

Close with: what was created and why · commands verified with their actual results · exit criteria
met vs. outstanding · anything deferred and why · where the `.management/` board now stands ·
commits ingested since the last run and the readiness gates still open · the exact next command to
run.
