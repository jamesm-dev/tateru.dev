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

**Neither is the test setup.** A runner, at least one test that asserts something real, and the
checks wired into CI and the `pre-push` hook go in on the *first* run, before any feature exists —
not when the project is big enough to feel like it needs them. A project that reaches its second
phase untested never retrofits them, and every later phase's exit criteria then rest on nothing.

Set up, in this order and always:

- **A unit runner** for the ecosystem, with one test that asserts real behaviour.
- **A browser or integration runner** wherever the product has behaviour a unit test cannot reach —
  offline, persistence, a migration, a real request. Say so plainly if the product genuinely has
  none.
- **CI** running install → lint → typecheck → test → build on every push.
- **`pre-push`** running the same checks locally, blocking a red push.
- **Test results recorded against tasks**, per Phase 6 below.

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

1. **Ingest commits first.** Read `.management/commits.jsonl` — written by the `post-commit` hook,
   and the whole commit record; there is no table. Map commits to tasks by reference id; a commit is
   evidence, never completion. Commits referencing no task are recorded as untracked work, so
   unplanned effort is not lost.
2. Read `.idea/ROADMAP.md` and every `.idea/epics/*.md`.
3. Derive tasks from epic acceptance criteria. Never invent a task with no epic behind it, and never
   quietly drop one — an epic with no criteria is a gap, so report it.

   **Carry each criterion's `(N pts)` into `state.json` as the task's points.** A task must never
   reach the board unpointed: assignee capacity is the sum of points on their open tasks, and one
   missing value makes every capacity figure a lie of unknown size. An epic whose criteria lack
   points is a gap in `.idea/` — report it and offer `/shape` to fix it, rather than defaulting the
   number here and hiding the omission.
4. Write `README.md`, `BOARD.md`, `PROGRESS.md`, `BLOCKERS.md`, `CHANGELOG.md`, and `state.json`.
   Carry each task's reference id (`^tsk-`) through into `state.json`; a task without one cannot
   hold assignees or effort.
5. Mark done only what Phase 5 actually verified. Progress you cannot evidence is fiction.
6. Preserve hand-written notes in `BLOCKERS.md` and `CHANGELOG.md`; rewrite only derived sections.
7. If the dashboard exists, create or migrate `board.db` per `.management/design/Database Schema.md`,
   then sync pull request and test data into it. **Never** clear a row a person authored: a task id
   that has left `.idea/` is marked orphaned, not deleted.
8. **Apply any phase advance recorded on the dashboard.** Read `phase_advance` in `board.db`. For
   each row not yet consumed, set that phase `done` in `ROADMAP.md`, open the next one, and stamp
   `consumed_at` so it is applied once.

   Carry the **parked** items into the record rather than dropping them: a criterion in
   `criterion_park` is written into `ROADMAP.md` as `- [~] <text> — parked <date>`, not ticked, and
   a phase that advanced with parked work says so in its section. A phase reported as complete when
   three of its criteria were skipped is exactly the lie this workflow exists to prevent — the aim
   is that skipping is *allowed and visible*, not that it is hidden.

   If the roadmap and the dashboard disagree because someone edited `ROADMAP.md` by hand, say so and
   ask. Never silently overwrite a phase status a person set.

9. **Record the test trail.** Read whatever the test run produced — a JUnit or JSON reporter file,
   the runner's own output — and write each run into `board.db`'s `test_run` table, linked to a task
   by its reference id where the test names one, and to the epic otherwise.

   This is what makes a task's claim to be done inspectable: the drawer shows which runs covered it,
   when they ran, and whether they passed. A task marked done with no linked run is not a
   contradiction to hide — it is exactly the thing the Tests readiness gate is asking about, and it
   should read as unmet until a run exists.

   Never write a passing run that did not happen. If the reporter produced nothing, record nothing
   and say so.

10. **Recompute deployment readiness** — the seven gates in `references/git-hooks.md` — and write it
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

### Then, last of all, the dashboard

> [!important] The dashboard is built **after** the app, never alongside it
> It is the final thing `/setup` builds: after Phase 4 has executed and **Phase 5 has verified
> green**. That order is not tidiness, it is the whole reason the page looks like it belongs.
>
> The dashboard introduces no design of its own. It is assembled from the app's tokens, its
> components, its dark-mode mechanism, its router, its test runner and its build config. Build it
> before those exist and there is nothing to reuse, so it invents them — a second design system
> inside one repository, which the app then contradicts for every phase afterwards. That is the
> single most expensive mistake available here, because by the time anyone notices, both are load
> bearing.

**Do not start it while any of these is true.** Fix the app first and come back:

- install, lint, typecheck, test or build is failing;
- the target phase's exit criteria are unmet;
- `app/` is mid-scaffold, or the framework choice is still open;
- the performance budget was missed and not yet accepted.

A dashboard reporting on a project that does not build is furniture.

#### Audit the app before offering to build anything

Read what the app actually has, and **report the findings to the user in the question itself**. This
takes one pass and decides everything downstream — `references/management.md` has the full checklist
of what to look for and where.

At minimum, establish and name: the **theme tokens** and where they live · the **component library**,
if any, and whether it is shadcn · the **dark-mode mechanism** · the **spacing and radius scale** ·
the **router** · the **test runner** · whether a **drawer, sheet or dialog** already exists.

Two outcomes matter:

| Audit found | What it means |
|---|---|
| Tokens and components | Build against them. Every substitution goes in `.management/contract/tokens.map`, so a reviewer can see what was swapped for what |
| Neither — a bare Phase 0 skeleton | There is nothing to inherit. **Say so and offer to defer** |

#### The question

Use `AskUserQuestion`. Lead with the recommended option, and state the trade-off in one line — such
a route exposes the roadmap, blockers, unshipped plans, and team names to anyone who can reach it.

Say up front what it is: four sections behind a sidebar — Board, Specs, Team, Status — backed by a
standalone database. It is more than a status page, and it is a real build.

Offer: **dev-only (recommended)** · auth-gated in production · public · **defer to a later phase** ·
none.

> [!warning] When the app has no design system yet, lead with *defer*
> On a first run the app is a walking skeleton: a token file with four colours, no component
> library, maybe no dark mode. A dashboard built then has to invent a card, a badge, a drawer and a
> scale — and a later phase that adds the real ones inherits a page that matches none of them.
>
> Deferring costs nothing. `.management/` still gets its Markdown and `state.json`, so progress is
> tracked from day one; only the page waits. Say which phase to revisit it in — the one that
> introduces the app's own components — and record the deferral in the run report so the next
> `/setup` picks it up rather than forgetting it.
>
> If the user wants it now anyway, that is their call: build it, keep it plain rather than inventing
> a design system, and **say in the report that it will need revisiting** once the app has a theme.

#### Building it

Build only on a yes. **Read `.management/DESIGN.md` and the notes in `.management/design/` first** —
they are the spec, and they describe the dashboard as it was refined in use, not as it was first
sketched. Five of them are what make a rebuild land in the same place:

| Note | Fixes |
|---|---|
| `design/Reference Implementation.md` | Every measurement, breakpoint, and the epic colour algorithm |
| `design/Derivations.md` | Every derived number as portable pseudocode |
| `design/API Surface.md` | The operation set, and what `null` means in each write |
| `design/Copy Deck.md` | The exact words, including the ones that must not be softened |
| `design/Conformance.md` | How the result is **checked**, and what the check cannot prove |

**Appearance comes from the app** — its theme, its tokens, its components, its dark mode. Those
notes fix layout, behaviour and wording, not palette. Reach for the project's own component first;
where it has none, build it once in a `ui/` directory from the project's tokens. Snap to the
project's nearest scale step where it has a scale; use the literal values where it has nothing.

Check `design/Requirements.md` before starting: it needs a standalone database, and pull request
status needs the GitHub MCP. If either is missing, say so and build the part that works rather than
faking the rest.

Add no new dependencies beyond the one database driver, and apply the gate the user picked.

#### Before reporting it built

Two checks, in this order, and **report both**:

1. **Conformance.** Write `.management/contract/sources.txt` (including the server side) and
   `tokens.map`, write the derivation goldens from `.management/contract/fixtures/` as tests in the
   project's own runner, then run them and:

   ```bash
   bash .claude/scripts/dashboard-conformance.sh
   ```

   These are mechanical. Do not report the dashboard built while either fails.

2. **The compliance checklist in `.management/DESIGN.md`**, walked item by item and reported as met
   over total, naming every item that is not. It is long because each line is something a build has
   actually got wrong. "It looks right" is not a check, and a rule that is never exercised is a rule
   the next build quietly drops.

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
