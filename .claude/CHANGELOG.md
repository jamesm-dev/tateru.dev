# Changelog

Changes to the tateru workflow itself — not to a project built with it. A project's own changelog is
`.management/CHANGELOG.md`.

`/upgrade` reads this file to tell a cloned project what changed. Mark anything that needs action
after upgrading as **Breaking**, and say what to do.

## Releasing tateru

1. Every change since the last release is listed under **Unreleased** below, in plain words.
2. Pick the version: patch for fixes only, minor for anything new, and before 1.0 a minor marked
   **Breaking** for anything a project must act on.
3. In one commit on `main`: rename **Unreleased** to `## <version> — <date>`, start a fresh empty
   **Unreleased** above it, and write the version into `.claude/TATERU_VERSION`. `selftest.sh`
   fails if the two disagree.
4. Tag that commit `v<version>` and publish a GitHub release from the entry. `/upgrade` diffs
   against the tag, so a version with no tag cannot be upgraded from.

## Unreleased

- **Fixed:** `/epic` and `/shape` show acceptance criteria with points, as the vault validator
  requires. Following the old example blocked every `/epic` run.
- **Fixed:** the vault validator no longer counts `# comments` inside code blocks as headings, and
  now checks that a note's heading matches its title.
- **Fixed:** a commit naming a task `/epic` added since the last `/setup` is accepted, instead of
  rejected as unknown.
- **Fixed:** `/setup` replaces `CLAUDE.md`'s "No app exists yet" section once the app exists.
- **Fixed:** `/upgrade` works when the tateru remote is called `origin`, as a plain clone names it.
- **Fixed:** `/setup` creates `board.db` even when the dashboard is deferred, writes `checks.env`
  before it tests the hooks, and skips epics that were only suggested.
- **Fixed:** `checks.env` with Windows line endings no longer breaks every push.
- **Changed:** hooks never write `board.db`; `.management/README.md` ships with tateru and `/setup`
  leaves it alone.
- **Added:** this release process, and CI that blocks on macOS and Windows as well as Linux.

## 0.1.0 — 2026-10-30

The first versioned release. Projects cloned earlier have no `.claude/TATERU_VERSION` and no
`/upgrade` yet. Fetch it once from the project root, then run `/upgrade`, which works out what was
edited locally from the git history the project shares with tateru:

```bash
git remote add tateru https://github.com/jamesm-dev/tateru.dev.git
git fetch tateru --tags
git checkout tateru/main -- .claude/commands/upgrade.md .claude/skills/upgrade
```

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
- **Fixed:** `/upgrade` on a project cloned before versioning now finds the starting point from the
  git history it shares with tateru, so it only asks about files you actually edited. Before, it
  would have asked about every file tateru had changed.
- **Fixed:** `selftest.sh` tests the working tree, not the last commit, so it verifies an upgrade
  `/upgrade` has applied but not committed. It no longer checks the root `README.md`, which is the
  project's own file in a clone, or fails because of the project's own notes.
