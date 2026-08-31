# Execution order

Verify as you go. Each step's output is evidence for the phase's exit criteria.

## 1. Scaffold

Prefer the ecosystem's official scaffolder over a hand-rolled tree: `create-*`, `cargo new`,
`uv init`, `dotnet new`, `rails new`. Check its *current* recommended invocation — flags churn, and
a remembered command line from an old version is the most common failure here.

**Scaffold into `app/`**, never the repository root — the root is the workflow's
(`.idea/`, `.management/`, `.claude/`). Most scaffolders take the target directory as an argument,
so pass `app`; where one insists on the current directory, scaffold into a temp dir and move the
result. Merge rather than overwrite if `app/` already has files worth keeping.

Watch the generated `.gitignore`. Several scaffolders ignore `.idea` for JetBrains, which in this
workflow is the **idea vault**. Inside `app/` that entry is merely wrong; at the root it would erase
the project's whole record from version control. Remove it and say why in a comment.

## 2. Dependencies

Install and pin what SPECS.md's stack table calls for, and nothing else. An unrequested dependency
is a decision the user did not make. If you believe one is missing, say so and ask.

## 3. Config

Typecheck config, linter, formatter, `.editorconfig`, and a `.gitignore` that actually matches the
stack. Prefer the tool's own `init` over a config block from memory.

## 4. Env

- `.env.example`: every key, documented, **empty values**.
- `.env`: only if the user asks. Confirm it is gitignored before it exists.
- Never invent a real credential, never commit one, never print one.

## 5. Database

Schema and migration scaffolding, plus a local dev story — Docker Compose or the managed provider's
local equivalent. Run the initial migration only against a local dev database, never a remote one.
Seed data if the phase needs something to look at.

## 6. Scripts

`dev`, `build`, `test`, `lint`, `format`, `typecheck` — named idiomatically for the ecosystem.
These are the commands `CLAUDE.md` and the README will promise, so they must actually work.

## 7. Tests

Configure the runner and write at least one test that asserts something real. A test that asserts
`true === true` proves the runner starts and nothing else — say so if that is all you wrote.

## 8. CI

Install → lint → typecheck → test → build, on the chosen provider. Pin the runner image and the
language version to match local.

## 9. Git hooks

**Always.** Install the commit-tracking hooks per `git-hooks.md`: Husky when the project is Node,
the ecosystem's equivalent otherwise. Three hooks — `commit-msg` links commits to task ids,
`post-commit` records them, `pre-push` runs the checks and recomputes deployment readiness.

Verify by making a throwaway commit and confirming a line appears in `.management/commits.jsonl`,
then confirm `pre-push` blocks on a deliberately failing check. A hook nobody proved fires is a hook
that does not fire.

Hooks write data only — `board.db` and `commits.jsonl` — never Markdown in `.idea/` or
`.management/`.

## 10. Docs

- `README.md`: what it is · prerequisites · setup · run · test · project structure.
- `CLAUDE.md`: stack, conventions, the real commands, and anything a future session would otherwise
  rediscover the hard way.

## 11. Verify

Run each in turn and show real output:

```
<install>  <lint>  <typecheck>  <test>  <build>  <dev — confirm it boots, then stop it>
```

Run these from `app/`. Any command promised in `CLAUDE.md` or a README must name the directory it
runs in, or the first person to try it from the root will conclude the project is broken.

Then check the phase's exit criteria one at a time, with evidence per criterion.

## 12. Git

Ensure the repo exists and `.gitignore` is right. Commit only if the user asks; if on the default
branch, branch first.

## Windows notes

This project runs on Windows. Prefer cross-platform scripts over shell-specific ones; avoid `&&`
chains inside npm scripts where a cross-platform runner is the idiom; watch for path separators and
CRLF settings in `.gitattributes`.
