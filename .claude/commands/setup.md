---
description: Set up the dev environment and build the current roadmap phase, driven by .idea/SPECS.md
argument-hint: [optional hints, e.g. "use pnpm" or "phase 2"]
allowed-tools: Skill, Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, WebSearch, WebFetch
---

Invoke the `setup` skill and follow it in full. Hints: **$ARGUMENTS**

- `.idea/` is read before anything else; the skill's Phase 1 table decides whether to build, to run
  the `shape` flow for a missing `SPECS.md`, or to send the user to `/brainstorm`.
- `$ARGUMENTS` naming a phase overrides the target phase, except that a first run always includes
  the Phase 0 walking skeleton.
- Hints are constraints on *how*, not permission to skip the plan-and-confirm step.
- Commit-tracking git hooks (Husky on Node, the equivalent elsewhere) are always installed, and
  Phase 6 ingests commits before regenerating progress.
- Once the phase is built and verified, Phase 6 stands up `.management/`, installs the
  `project-manager` agent, and asks whether to serve the dashboard at a `/management` route. Never
  build that route without an explicit yes.
