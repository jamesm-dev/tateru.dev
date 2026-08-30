---
name: ship
description: Take a completed phase to production - verify the readiness gates, then release. Use when the user wants to deploy, ship, release, cut a version, go live, or asks whether the project is ready to ship. Also use to check readiness without releasing.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Ship

The production step. Everything before this builds; this is what puts it in front of people.

**Nothing here is irreversible without an explicit yes.** Deploying, tagging, and publishing are
outward-facing acts, and approval for one is not approval for the next.

## Phase 1 — Establish where things stand

Read `.idea/ROADMAP.md` for the current phase and its exit criteria, `.management/PROGRESS.md` and
`BLOCKERS.md`, and the repo's deploy configuration — CI workflow, Dockerfile, host config, whatever
`SPECS.md` named as the target.

Say which phase is being shipped and what the release contains, before checking anything.

## Phase 2 — Walk the readiness gates

The seven gates in `.claude/skills/setup/references/git-hooks.md`. Check each **by running
something**, not by reading a status file — a file can be stale, a command cannot.

| Gate | How to actually check |
|---|---|
| Exit criteria | Each one, against evidence. Unverifiable means unmet. |
| Tasks | Nothing blocked or in flight in this phase |
| Tests | Run the suite now. Show the output. |
| Checks | Run lint, typecheck, build now |
| Pull requests | None open against this phase's epics, or all approved |
| Risks | No `critical` rule firing |
| Deploy path | Exercised — the skeleton reached the real target at least once |

Report `N of 7 gates met`, then each unmet gate with what is blocking it.

> [!warning] Do not ship on an unmet gate without saying so
> If the user wants to ship anyway, that is their call — but state which gate is unmet, what could
> go wrong, and record it in the release notes. Never let an unmet gate pass silently because the
> user seemed keen.

## Phase 3 — Pre-flight

Things that are cheap now and expensive at 2am:

- **Secrets** — every key the app needs exists in the target environment. `.env.example` lists them;
  check each is set there. Never print a value.
- **Migrations** — pending ones identified, reversible or explicitly not, and a note on ordering if
  the deploy is not atomic.
- **Rollback** — say concretely how to undo this. If the answer is "redeploy the previous tag",
  confirm the previous tag exists.
- **Data** — anything destructive, called out by name.
- **Config drift** — the target's runtime version matches local and CI.

If there is no rollback path, say so before deploying, not after.

## Phase 4 — Release

Ask before each outward-facing step. Do not chain them.

1. **Version** — bump per the project's scheme. Ask if the scheme is unclear rather than guessing at
   semver intent.
2. **Changelog** — write the entry from `.management/CHANGELOG.md` and the epics in this phase.
   Real changes, in the user's language, not commit subjects.
3. **Tag** — annotated, matching the version.
4. **Deploy** — the project's own command or pipeline. Never a hand-rolled deploy invented here.
5. **Verify live** — hit the deployed thing and confirm it responds. A deploy that reported success
   is not a deploy that works.

## Phase 5 — Record

- Append the release to `.management/CHANGELOG.md`: version, date, what shipped, and any gate that
  was waived.
- Mark the phase `done` in `ROADMAP.md`, with its exit criteria ticked against evidence.
- Set its epics to `done`.
- Write an ADR for anything decided under pressure during the release — those are the decisions
  most likely to be forgotten and most expensive to rediscover.
- Regenerate `.management/`.

Close with: what shipped, where it is live, what was waived, how to roll back, and the next phase.

## If it goes wrong

Say so immediately and plainly, with the error. Roll back first, diagnose second — a broken
production is not the place to be curious. Then record what happened in the changelog, because the
next release will want to know.
