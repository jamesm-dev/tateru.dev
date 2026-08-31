# CLAUDE.md

Project-wide instructions for Claude Code in this repository.

## Always read `.idea/` first

`.idea/` is this project's thinking layer — the recorded intent behind the code. Before acting on
any prompt about this project, read the `.idea/` files relevant to it. A `UserPromptSubmit` hook
([.claude/hooks/idea-context.sh](.claude/hooks/idea-context.sh)) injects a snapshot of what exists
on every prompt; that snapshot is a pointer, not a substitute for reading the files.

Priority order when the prompt concerns what to build or how:
`.idea/SPECS.md` → `.idea/ROADMAP.md` → the relevant `.idea/epics/` and `.idea/notes/` → this file.
For "where does the work stand", read `.management/BOARD.md` and `.management/PROGRESS.md` instead.

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

Three hooks in [.claude/settings.json](.claude/settings.json) enforce the above rather than trusting
it to be remembered:

| Event | Script | Does |
|---|---|---|
| `SessionStart` | [vault-preflight.sh](.claude/hooks/vault-preflight.sh) | Audits every existing note against the vault contract and names any that drifted |
| `UserPromptSubmit` | [idea-context.sh](.claude/hooks/idea-context.sh) | Injects a snapshot of `.idea/` and whether `CLAUDE.md` exists |
| `PostToolUse` | [validate-vault-note.sh](.claude/hooks/validate-vault-note.sh) | Checks any vault note — from Write, Edit, or an optional Obsidian MCP — against the vault contract, blocking with the specific violations |

Together they cover the two ways a note can go wrong: written badly by a tool (`PostToolUse`
validation) or edited by hand outside Claude (`SessionStart` audit).

`.idea/` and `.management/` are **always writable** with plain `Write` and `Edit`. No hook gates the
write itself. What is enforced is that the Markdown stays Obsidian-compatible — valid frontmatter,
one H1, real wikilinks, no illegal filename characters.

The validator doubles as a CLI:

```bash
bash .claude/hooks/validate-vault-note.sh --check ".idea/notes/Some Idea.md"
```

All four fail open and never block on their own error. Everything outside those two folders passes
through untouched. If you change the vault contract, change the validator in the same edit — a rule
that only exists in prose is not a rule.

## Keep `/explain` current

**Whenever a command or skill is added, removed, or changed, update `/explain` in the same change.**

[.claude/commands/explain.md](.claude/commands/explain.md) discovers commands by reading
`.claude/commands/`, `.claude/skills/`, and the user-level equivalents at run time, so a new command
is usually picked up with no edit. That is exactly why this rule is easy to forget — and why the
check is not optional. Confirm all of the following:

- [ ] The new or changed file lives somewhere `/explain`'s **Stage 1** discovery list actually covers.
      A new location (a plugin, a nested directory, a different config root) means adding that path.
- [ ] `/explain`'s **Scope** section still describes the real set of commands.
- [ ] A command that delegates to a skill is explained as what it *does*, not as its two-line body —
      if a new command breaks that pattern, the guidance needs adjusting.
- [ ] The one-line chain note in **Stage 1** still reflects how the commands actually chain.
- [ ] Run `/explain` once and read the output. A rule that is never exercised silently rots.

The same applies to removal: delete the command or skill, then confirm `/explain` no longer mentions
it and that nothing else links to it.

## Commands

| Command | Delegates to | Purpose | Stage |
|---|---|---|---|
| [/brainstorm](.claude/commands/brainstorm.md) | [brainstorm](.claude/skills/brainstorm/SKILL.md) | Diverge on ideas, capture them as grouped Obsidian notes | Idea |
| [/shape](.claude/commands/shape.md) | [shape](.claude/skills/shape/SKILL.md) | Turn ideas into `SPECS.md`, a phased `ROADMAP.md`, and epics | Idea |
| [/epic](.claude/commands/epic.md) | [epic](.claude/skills/epic/SKILL.md) | One epic and its tasks, mid-project. Also triages suggested epics | Development |
| [/setup](.claude/commands/setup.md) | [setup](.claude/skills/setup/SKILL.md) | Build the dev environment and the current roadmap phase | Development |
| [/ship](.claude/commands/ship.md) | [ship](.claude/skills/ship/SKILL.md) | Verify the readiness gates, then release | Production |
| [/maintain](.claude/commands/maintain.md) | [maintain](.claude/skills/maintain/SKILL.md) | Health-check a shipped project and fix the rot | Maintenance |
| [/decide](.claude/commands/decide.md) | — | Record an ADR | Any |
| [/explain](.claude/commands/explain.md) | — | List the commands, then explain one in depth (ELI5) | Any |

The [project-manager](.claude/agents/project-manager.md) agent oversees all four stages. It is an
auditor with exactly two write powers: it proposes epics at `status: suggested`, and it marks tasks
done in `board.db` from commit evidence — always with a note saying why, and never confirmed until
a person confirms it. It may not touch the plan, tick a criterion, or deploy.

Commands stay thin — they name the skill, pass `$ARGUMENTS`, and handle invocation-specific cases.
Method and detail live in the skill and its `references/`, which load only when that phase is
active. Preserve that split: depth added to a command file rather than its skill is a regression.

## The app in this repository

This clone is building **Gastos** — a phone-first, offline, single-user budget tracker. It lives in
[app/](app/) and is documented in [app/README.md](app/README.md); the plan behind it is in
[.idea/](.idea/).

Run every project command from `app/`, never the root:

```bash
cd app && pnpm verify     # lint, typecheck, test, build, bundle ceiling
```

Git hooks live in [.githooks/](.githooks/) and are wired by `pnpm install` in `app/` setting
`core.hooksPath`. Husky is deliberately not used: it installs beside the manifest in `app/`, cannot
find `.git` at the root, and would be a dependency that does nothing.

## Conventions

- Windows host. Prefer cross-platform scripts; watch path separators and CRLF.
- Application code lives in `app/`. The root belongs to the workflow — `.idea/`, `.management/`,
  `.claude/`, and this project's own `README.md`. Any command in a doc names the directory it runs
  in.
- `.idea/` is intent; `.management/` is execution state, derived from it. Never let `.management/`
  become a second source of truth, and never edit `.idea/` from it silently.
- Never delete or overwrite a note in `.idea/`. Supersede it and link the replacement.
- Never fabricate a version number, a CLI flag, or a command's output. Verify it.
- Never invent or commit a secret. `.env.example` documents keys with empty values.
- When convenience and quality conflict in a stack or structure decision, resolve toward quality and
  state what it cost. This is a tiebreaker, not a licence to over-build — see `quality-bar.md`.
