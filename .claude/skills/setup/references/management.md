# `.management/` — the execution tracker

## The split — do not blur it

| Folder | Holds | Changes when |
|---|---|---|
| `.idea/` | **Intent.** What we are building and why. Ideas, spec, roadmap, epics, decisions. | The plan changes |
| `.management/` | **State.** How it is actually going. Progress, blockers, dates, shipped log. | Work happens |

`.idea/` is upstream. `.management/` is derived from it and adds what `.idea/` does not track:
status, dates, blockers, and what actually shipped.

**Sync rules**
- Regenerate `.management/` from `.idea/` on every `setup` run.
- Never edit `.idea/` from `.management/` silently. If reality contradicts the roadmap, say so and
  let `/shape` amend the plan.
- Never invent a task with no epic behind it. An epic with no acceptance criteria is a gap — report
  it rather than filling it in.
- Mark done only what was actually verified. Progress you cannot evidence is fiction.
- Hand-written notes in `BLOCKERS.md` and `CHANGELOG.md` are preserved across regeneration; the
  derived sections are rewritten.

## Layout

```
.management/
  README.md        what this folder is and how it syncs
  BOARD.md         every task by status, each linked to its epic
  PROGRESS.md      per-phase rollup with exit criteria
  BLOCKERS.md      what is stuck, since when, and the next action
  CHANGELOG.md     dated log of what actually shipped
  state.json       generated snapshot - the dashboard's data source
  DESIGN.md        index of the dashboard design
  design/          the design spec, one concern per note
  board.db         the dashboard's own store: assignees, effort, links, test runs
```

`board.db` is not Markdown and is never opened as a note. It holds the data people author on the
dashboard, keyed on each task's reference id. Schema: `.management/design/Database Schema.md`.

Markdown files use the same conventions as `.idea/` (see `shared/vault-contract.md`), but the two
folders each open as their **own** Obsidian vault. Wikilinks do **not** cross between them: use a
relative Markdown link to reach `.idea/`.

## `state.json`

The single machine-readable snapshot. Regenerate wholesale; never hand-edit.

```json
{
  "generatedAt": "2026-08-30T12:00:00Z",
  "project": { "name": "", "description": "", "currentPhase": 0 },
  "phases": [
    {
      "n": 0,
      "name": "Walking skeleton",
      "goal": "",
      "demo": "",
      "status": "planned | in-progress | done | cut",
      "exitCriteria": [{ "text": "", "done": false }],
      "nonGoals": [""]
    }
  ],
  "epics": [
    {
      "title": "",
      "phase": 0,
      "status": "planned | in-progress | done | cut",
      "theme": "",
      "sources": ["Idea A"],
      "tasks": [{ "id": "TSK-7F3A21", "text": "", "description": "", "done": false }]
    }
  ],
  "blockers": [{ "title": "", "since": "2026-08-30", "epic": "", "nextAction": "" }],
  "metrics": {
    "tasksTotal": 0, "tasksDone": 0,
    "epicsTotal": 0, "epicsDone": 0,
    "phasesTotal": 0, "phasesDone": 0
  }
}
```

`status` values match the vault contract exactly. Do not invent new ones.

Each task's `id` is the `^tsk-` block reference from its epic's acceptance criterion, uppercased.
It is the key every piece of authored data hangs off, so carry it through faithfully. A task with no
block reference gets `"id": null` — never a generated one, and never a fallback to matching on text.

## File templates

**`README.md`** — frontmatter `tags: [meta, management]`. Explains the `.idea/` vs `.management/`
split, the sync rules above, that `state.json` is generated, and how to view the dashboard if one
was built.

**`BOARD.md`** — frontmatter `tags: [board, management]`. Four `##` sections: Blocked, In progress,
Next up, Done. Each task as `- [ ] Task text — [Epic Title](../.idea/epics/Epic%20Title.md) (Phase N)`
— a relative link, never a wikilink, since the epic lives in the other vault. Done tasks keep their
completion date. Sorted by phase, then epic.

**`PROGRESS.md`** — frontmatter `tags: [progress, management]`. A summary table:

```markdown
| Phase | Goal | Tasks | Status |
|---|---|---|---|
| 0 | Walking skeleton | 5/7 | in-progress |
```

Then one `##` per phase with its exit criteria as `- [ ]` items, each marked only with evidence, and
a one-line note on what remains.

**`BLOCKERS.md`** — frontmatter `tags: [blockers, management]`. One `###` per blocker: what is
stuck, since when, which epic it holds up, and the next concrete action. A `> [!warning]` callout
for anything blocking the current phase. Empty is fine — say "None." rather than deleting the file.

**`CHANGELOG.md`** — frontmatter `tags: [changelog, management]`. Reverse-chronological `## YYYY-MM-DD`
entries listing what shipped, with the epic as a relative link to `../.idea/epics/`, never a
wikilink. Append only; never rewrite history.

## The `/management` dashboard

Build only if the user opts in.

**Read `.management/DESIGN.md` and the notes in `.management/design/` first — they are the spec.**
Start with `design/Requirements.md` and `design/Data Sources.md`: they carry the decisions everything
else depends on. Do not design the page from scratch here.

Then read the four reference notes before writing markup. They exist because the same build has been
got wrong in the same ways more than once:

- `design/Reference Implementation.md` — measurements, breakpoints, board geometry, epic palette
- `design/Derivations.md` — every derived number, as pseudocode
- `design/API Surface.md` — the operation set and the meaning of `null`
- `design/Copy Deck.md` — the exact strings

Appearance comes from the app — its theme, tokens, components and dark mode. These notes fix layout,
behaviour and wording. Where the project has a component, use it; where it has none, build it once
in `ui/` from the project's tokens. Never add a UI kit for this page.

Finish by walking the compliance checklist in `.management/DESIGN.md` and reporting it as met over
total, naming what is not.

The dashboard is four sections behind a sidebar: **Board** (task cards, task creation), **Specs**
(epics and their drawer), **Team** (members and contribution), and **Status** (insights, risk rules,
sprints). It needs a standalone database; pull request status needs the **GitHub MCP**. If either is
missing, say so and build the part that works — never fake a status.

Charts on Status are inline SVG, no chart library, and follow the `dataviz` skill's procedure.

**Rules**
- Read `state.json`. Do not re-parse Markdown at runtime.
- **Build it from the project's own theme and existing components.** Read the theme tokens and the
  component library that already exist, and use them: the project's `Card`, `Badge`, `Progress`,
  `Table`, `Collapsible`. Compose from existing pieces before writing anything new, and never
  hardcode a colour the project has a token for.
- Add no new dependencies — no chart library, no icon pack, no UI kit. The one exception is a single
  database driver for `board.db`.
- The page never calls an MCP server; it cannot. Claude syncs PR and test data into the database, and
  the page shows the sync time alongside it.
- Server-render it. This is an internal page; it needs no client-side data fetching.
- Show: phase progress, the board by status, open blockers, and `generatedAt` so a stale snapshot is
  obvious.
- If the project has no theme or components yet, keep the page plain rather than inventing a design
  system, and say so.

**Gating** — pick per the user's answer.

| Choice | How |
|---|---|
| Dev-only *(recommended)* | Return a 404 when the environment is production. One guard at the top of the route. |
| Auth-gated | Reuse the project's existing auth. If there is none yet, say so and fall back to dev-only rather than inventing one. |
| Public | Build it, and state once that the roadmap and unshipped plans become publicly readable. |

**Route location by framework** — verify against the project's actual structure before writing:

| Framework | Route |
|---|---|
| Next.js (app router) | `app/management/page.tsx` |
| Next.js (pages router) | `pages/management.tsx` |
| Nuxt | `pages/management.vue` |
| SvelteKit | `app/src/routes/management/+page.svelte` |
| Remix / React Router | `app/routes/management.tsx` |
| Astro | `app/src/pages/management.astro` |
| Vite SPA | A route in the existing router, importing `state.json` |
| Express / Fastify / Hono | A `GET /management` handler rendering server-side |
| Django / Rails / Laravel | A route plus template, following the project's own conventions |

Import `state.json` directly where the bundler allows it; read it from disk at request time in a
server framework.

**No web surface?** For a CLI, a library, or anything without routes, do not invent a server.
Offer instead: a single self-contained `.management/dashboard.html` that inlines the data, plus a
`board` script in the project's task runner that prints progress to the terminal.
