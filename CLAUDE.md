# CLAUDE.md

Project-wide instructions for Claude Code in this repository.

## Always read `.idea/` first

`.idea/` is this project's thinking layer — the recorded intent behind the code. Before acting on
any prompt about this project, read the `.idea/` files relevant to it. A `UserPromptSubmit` hook
([.claude/hooks/idea-context.sh](.claude/hooks/idea-context.sh)) injects a snapshot of what exists
on every prompt; that snapshot is a pointer, not a substitute for reading the files.

Priority order when the prompt concerns what to build or how:
`.idea/SPECS.md` → `.idea/ROADMAP.md` → the relevant `.idea/epics/` and `.idea/notes/` → this file.
For "where does the work stand", read `.management/BOARD.md` and `.management/PROGRESS.md` instead —
but only once `/setup` has generated them. Before that they do not exist, and the roadmap is the
only answer available.

The repo is the source of truth for what exists; `.idea/` is the source of truth for what was
intended. On conflict, ask — do not silently pick one.

The format contract for everything in `.idea/` is
[.claude/skills/shared/vault-contract.md](.claude/skills/shared/vault-contract.md). It is
authoritative; obey it when writing any note.

The decision contract for what gets built is
[.claude/skills/shared/quality-bar.md](.claude/skills/shared/quality-bar.md). It governs stack and
structure choices in `/shape` and `/setup`, and defines the performance budget that Phase 0 must
measure. Read it before choosing any technology.

## Hooks

Three hooks in [.claude/settings.json](.claude/settings.json) enforce the above, not memory:

| Event | Script | Does |
|---|---|---|
| `SessionStart` | [vault-preflight.sh](.claude/hooks/vault-preflight.sh) | Audits every existing note against the vault contract and names any that drifted |
| `UserPromptSubmit` | [idea-context.sh](.claude/hooks/idea-context.sh) | Injects a snapshot of `.idea/` and whether `CLAUDE.md` exists |
| `PostToolUse` | [validate-vault-note.sh](.claude/hooks/validate-vault-note.sh) | Checks any vault note — from Write, Edit, or an optional Obsidian MCP — against the vault contract, blocking with the specific violations |

They cover both ways a note goes wrong: written badly by a tool, or edited by hand outside Claude.
`.idea/` and `.management/` are **always writable** with plain `Write` and `Edit` — no hook gates the
write. What is enforced is Obsidian-compatible Markdown: valid frontmatter, one H1, real wikilinks,
no illegal filename characters.

The validator doubles as a CLI: `bash .claude/hooks/validate-vault-note.sh --check "<note>.md"`.

All three fail open and never block on their own error. Everything outside those two folders passes
through untouched. If you change the vault contract, change the validator in the same edit — a rule
that only exists in prose is not a rule.

## Scripts

[.claude/scripts/](.claude/scripts/) holds checks nothing triggers automatically; a skill or a person
runs them by name. [dashboard-conformance.sh](.claude/scripts/dashboard-conformance.sh) checks a
built `/management` dashboard against the data contract in `.management/contract/` — strings,
measurements, and order. It needs only `bash`, `find`, `sed`, `tr` and `awk`, so it runs in any
project before any package manager exists. Exit `2` means it could not run, including "nothing built
yet". [selftest.sh](.claude/scripts/selftest.sh) checks tateru's own machinery — every hook and
script — and runs in CI on each push. **Run it after changing any hook or script**; a hook that
silently stops firing looks exactly like a project where nobody commits.

## Keep `/explain` and `AGENTS.md` current

**When a command or skill is added, removed, or changed, update both in the same change.**
[/explain](.claude/commands/explain.md) discovers commands at run time, so it usually needs no edit —
which is exactly why the check gets forgotten. Confirm:

- [ ] The file sits where `/explain`'s **Stage 1** discovery list looks; a new location means a new path.
- [ ] `/explain`'s **Scope** and its one-line chain note still match the real commands.
- [ ] A command is explained as what its skill *does*, not as its two-line body.
- [ ] The command-to-skill table in [AGENTS.md](AGENTS.md) matches. tateru is Claude-first:
      `AGENTS.md` points non-Claude tools at this file and never duplicates it.
- [ ] Run `/explain` once and read the output. A rule that is never exercised silently rots.

On removal, also confirm nothing still mentions or links to it.

## Commands

| Command | Delegates to | Purpose | Stage |
|---|---|---|---|
| [/brainstorm](.claude/commands/brainstorm.md) | [brainstorm](.claude/skills/brainstorm/SKILL.md) | Diverge on ideas, capture them as grouped Obsidian notes | Idea |
| [/shape](.claude/commands/shape.md) | [shape](.claude/skills/shape/SKILL.md) | Turn ideas into `SPECS.md`, a phased `ROADMAP.md`, and epics | Idea |
| [/epic](.claude/commands/epic.md) | [epic](.claude/skills/epic/SKILL.md) | One epic and its tasks, mid-project. Also triages suggested epics | Development |
| [/setup](.claude/commands/setup.md) | [setup](.claude/skills/setup/SKILL.md) | Build the dev environment and the current roadmap phase | Development |
| [/work-on](.claude/commands/work-on.md) | [work-on](.claude/skills/work-on/SKILL.md) | One task with the smallest agent team: route, then build directly, solo, or in parallel slices | Development |
| [/ship](.claude/commands/ship.md) | [ship](.claude/skills/ship/SKILL.md) | Verify the readiness gates, then release | Production |
| [/maintain](.claude/commands/maintain.md) | [maintain](.claude/skills/maintain/SKILL.md) | Health-check a shipped project and fix the rot | Maintenance |
| [/upgrade](.claude/commands/upgrade.md) | [upgrade](.claude/skills/upgrade/SKILL.md) | Pull a newer tateru workflow into a cloned project, leaving its plan and code alone | Maintenance |
| [/decide](.claude/commands/decide.md) | — | Record an ADR | Any |
| [/explain](.claude/commands/explain.md) | — | List the commands, then explain one in depth (ELI5) | Any |

The [project-manager](.claude/agents/project-manager.md) agent oversees all four stages. It is an
auditor with exactly two write powers: it proposes epics at `status: suggested`, and it marks tasks
done in `board.db` from commit evidence — always with a note saying why, and never confirmed until
a person confirms it. It may not touch the plan, tick a criterion, or deploy.

`/work-on` drives a second team — `task-router`, `repo-scout`, `work-planner`, `implementer`,
`reviewer` — written stack-agnostic. They become specialists by reading `.claude/team/stack.md`,
which `/setup` generates from the verified stack
([format](.claude/skills/work-on/references/stack-profile.md)); its twin `checks.env` is what
`pre-push` runs. Never hand-write either from memory — no stack, no profile, generalist agents.

Commands stay thin — they name the skill, pass `$ARGUMENTS`, and handle invocation-specific cases.
Method and detail live in the skill and its `references/`, which load only when that phase is
active. Preserve that split: depth added to a command file rather than its skill is a regression.

## No app exists yet

**Assume nothing has been built.** There is no `app/` directory, `/setup` has not run, and no stack
has been installed. This repository currently holds the workflow (`.claude/`, `.githooks/`) and the
plan (`.idea/`, `.management/`) — nothing else. Never refer to a source file, package manifest,
script, or dependency as if it exists; check first, and if it is missing, say so.

`/setup` is what creates `app/`. Until it has run:

- Write plans into `.idea/`, not code into `app/`.
- `.management/` holds only `README.md`, `DESIGN.md`, and `design/`. `BOARD.md`, `PROGRESS.md`,
  `BLOCKERS.md`, `CHANGELOG.md`, `state.json`, and `board.db` are generated later.
- There is no chosen language, framework, or package manager. The stack is decided during `/shape`
  and `/setup` against [quality-bar.md](.claude/skills/shared/quality-bar.md) and recorded as an
  ADR — never assumed from this file, and never inferred from an example command.

Once `/setup` has created it, application code lives in `app/` and every project command runs from
there, never the root:

```bash
cd app && <the verify command /setup wired up>
```

Git hooks live in [.githooks/](.githooks/) and are wired by the install step `/setup` runs inside
`app/`, which sets `core.hooksPath`. Husky is deliberately not used: it installs beside the manifest
in `app/`, cannot find `.git` at the root, and would be a dependency that does nothing.

## Conventions

- Windows host. Prefer cross-platform scripts; watch path separators and CRLF.
- Application code will live in `app/`, once `/setup` creates it. The root belongs to the workflow
  — `.idea/`, `.management/`, `.claude/`, this project's own `README.md`, and `AGENTS.md`. Any command in a doc
  names the directory it runs in.
- `.idea/` is intent; `.management/` is execution state, derived from it. Never let `.management/`
  become a second source of truth, and never edit `.idea/` from it silently.
- Never delete or overwrite a note in `.idea/`. Supersede it and link the replacement.
- Never fabricate a version number, a CLI flag, or a command's output. Verify it.
- Never invent or commit a secret. `.env.example` documents keys with empty values.
- When convenience and quality conflict in a stack or structure decision, resolve toward quality and
  state what it cost. This is a tiebreaker, not a licence to over-build — see `quality-bar.md`.
