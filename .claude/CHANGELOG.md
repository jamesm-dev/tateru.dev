# Changelog

Changes to the tateru workflow itself — not to a project built with it. A project's own changelog is
`.management/CHANGELOG.md`.

`/upgrade` reads this file to tell a cloned project what changed. Mark anything that needs action
after upgrading as **Breaking**, and say what to do.

## Unreleased

- **Fixed:** `/upgrade` on a project cloned before versioning now finds the starting point from the
  git history it shares with tateru, so it only asks about files you actually edited. Before, it
  would have asked about every file tateru had changed.
- **Fixed:** `selftest.sh` tests the working tree, not the last commit, so it verifies an upgrade
  `/upgrade` has applied but not committed. It no longer checks the root `README.md`, which is the
  project's own file in a clone, or fails because of the project's own notes.

## 0.1.0 — 2026-10-30

The first versioned release. Projects cloned earlier have no `.claude/TATERU_VERSION`; `/upgrade` handles
them by asking about every workflow file that differs.

- **Fixed:** the git hooks were committed without the executable bit, so git skipped them on macOS
  and Linux — no commit tracking, no task links, no pre-push checks. **Breaking for earlier clones:**
  run `/upgrade`, or `git update-index --chmod=+x .githooks/*` and commit.
- **Fixed:** shell scripts are pinned to LF line endings, so a Windows checkout cannot break them.
- **Fixed:** `commit-msg` and `post-commit` accept ad-hoc `ADH-` task ids, and a tab in a commit
  subject no longer breaks `commits.jsonl`.
- **Added:** `/work-on` and its agent team — `task-router`, `repo-scout`, `work-planner`,
  `implementer`, `reviewer` — which become specialists in the project's stack via
  `.claude/team/stack.md`, written by `/setup`.
- **Changed:** `pre-push` runs the commands in `.claude/team/checks.env` instead of assuming pnpm.
  It skips its checks until `/setup` writes that file.
- **Added:** `/upgrade`, `.claude/TATERU_VERSION`, and this changelog.
- **Added:** `selftest.sh` and a CI workflow that run it, and a session-start warning when the hooks
  are unwired or not executable.
- **Added:** `AGENTS.md`, for tools other than Claude Code.
