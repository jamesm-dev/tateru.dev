# Git hooks — commit tracking and progress

Set these up on every project, in Phase 4. They are what keeps `.management/` honest between
`/setup` runs: the plan says what should happen, the commits say what did.

## Which runner

**Husky when the project is Node** — it has a `package.json` and installs dependencies. Otherwise use
the ecosystem's equivalent, with the same three hooks and the same scripts:

| Project | Runner | Install |
|---|---|---|
| Node | **Husky** | `npm i -D husky && npx husky init` |
| Python | pre-commit | `pipx install pre-commit && pre-commit install` |
| Go, Rust, mixed | Lefthook | `lefthook install` |
| Anything else | Native `.git/hooks`, committed to `scripts/hooks/` and installed by a `make hooks` target | — |

Do not install Husky into a non-Node project just to satisfy the word "Husky". It would drag in Node
purely to run a shell script. Use the ecosystem's runner and say which you chose and why.

## The hard rule

> [!warning] Hooks never write Markdown in `.idea/` or `.management/`
> A git hook is a shell script running outside Claude, so anything it wrote to the vault would skip
> the `PostToolUse` validator and could silently break the contract that keeps those notes valid.
>
> Hooks write to **`.management/board.db`** and **`.management/commits.jsonl`** only. Both are data,
> not notes. `/setup` reads them and regenerates the Markdown properly.

They must also be fast and never block on network. A hook that takes ten seconds gets disabled by
the third developer who hits it.

## The three hooks

### `commit-msg` — link the commit to work

Parse the message for task references: `TSK-7F3A21`, `ADH-3C81`, case-insensitive, anywhere in the
message. Also accept a trailer:

```
Task: TSK-7F3A21, TSK-9C04E8
```

Behaviour:

- **Warn, do not block, when no task is referenced.** Plenty of legitimate commits — a typo fix, a
  dependency bump — belong to no task. Blocking those teaches people to pass `--no-verify`, which
  disables every other hook too.
- **Block only on a reference that does not exist.** `TSK-` followed by an id absent from
  `state.json` is a typo, and silently losing the link is worse than one rejected commit.
- Keep the message itself unmodified. Do not rewrite what someone wrote.

### `post-commit` — record it

Append one line to `.management/commits.jsonl`:

```json
{"sha":"a1b2c3d","at":"2026-08-30T14:02:11Z","author":"jamie","subject":"Persist docs on save","tasks":["TSK-7F3A21"],"files":7,"insertions":184,"deletions":22}
```

Append-only, one JSON object per line, never rewritten. It survives rebases badly on purpose: it is
a log of what happened locally, not a mirror of history.

Also upsert the rows into `board.db` — the `commit` and `task_commit` tables in
`.management/design/Database Schema.md` — when a database driver is available. If it is not, the
JSONL alone is enough; `/setup` backfills.

### `pre-push` — verify, then take stock

1. Run the project's real checks: lint, typecheck, test. **Block the push if they fail.** This is the
   one hook that should stop you, because a red push is what turns into a broken deploy.
2. Recompute readiness (below) and write it to `board.db`.
3. Print a two-line summary so the developer sees where the phase stands as they push:

```
Phase 1 - Core loop:  12/19 tasks, 3 of 4 exit criteria met
Not deployable yet:   1 criterion unmet, 2 tasks blocked
```

Never push, tag, or deploy from a hook.

## Readiness

The answer to "how much more before this can ship". Computed from `.idea/` and `.management/`, never
guessed, and expressed as a checklist rather than a percentage.

| Gate | Met when |
|---|---|
| Phase exit criteria | Every criterion of the current phase is met, with evidence |
| Tasks | No task in the phase is blocked or in progress |
| Tests | The latest run passed, and every epic in the phase has at least one linked run |
| Checks | Lint, typecheck, build all pass |
| Pull requests | None open against the phase's epics, or all approved |
| Risks | No `critical` rule firing on the Status page |
| Deploy path | Exercised at least once — the Phase 0 skeleton reached the real target |

Deployable means **every gate met**. Report it as `5 of 7 gates met` plus the two that are not,
never as `71% ready` — a percentage of a checklist invites rounding up.

## What `/setup` does with all this

On each run, before regenerating `.management/`:

1. Read `commits.jsonl` and any `board.db` commit rows since the last run.
2. Map commits to tasks by reference id. **A commit never marks a task done** — it is evidence, not
   completion. Completion comes from a verified exit criterion in Phase 5.
3. Surface commits that referenced no task as untracked work, so they appear in the delivery log
   rather than vanishing.
4. Recompute readiness and write it into `PROGRESS.md`.
5. Report: commits since last run, tasks they touched, and the readiness gates still open.
