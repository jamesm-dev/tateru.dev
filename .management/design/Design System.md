---
title: Design System
created: 2026-08-30
updated: 2026-08-30
tags: [design, management, ui]
status: active
---

# Design System

**This page introduces no new design.** It is assembled from the project's existing theme and
component library. Before writing any markup, read what already exists and use it.

| Look for | Use it for |
|---|---|
| Theme tokens — CSS variables, a Tailwind config, a `theme.ts`, design tokens | Every colour, spacing step, radius, shadow, and font |
| An existing component library — the project's own `components/ui`, shadcn, Radix, Chakra, Vuetify, PrimeVue, Mantine | Card, Badge, Progress, Table, Collapsible, Alert, Separator, Avatar, Drawer |
| Existing layout primitives — a `Container`, `Stack`, `PageHeader`, `Section` | The page shell and its spacing |
| Existing form controls — Input, Select, Combobox | Every editable field in the task drawer |
| Existing dark-mode mechanism | Dark mode. Never a second one |

Rules, in order of precedence:

1. **Use the existing component.** If the project has a `Card`, the task card is that `Card`. If it
   has a `Badge`, the status pill is that `Badge`. If it has a `Drawer` or `Sheet`, the task drawer
   is that.
2. **Compose before creating.** If no exact component exists, build it from ones that do.
3. **Only then write something new** — with the project's tokens, matching the conventions of its
   neighbours, so it looks like it was always there.
4. **Never add a dependency** for this page. Not a chart library, not an icon pack, not a UI kit.
   If the project ships an icon set, use it; otherwise use text and Unicode glyphs. The single
   sanctioned exception is one database driver — see [[Requirements]].

> [!warning] The test
> Someone opening this page should not be able to tell it was generated. If it looks like a
> different product bolted onto the app, it is wrong — however good it looks on its own.

If the project genuinely has no theme or components yet (a bare Phase 0 skeleton), keep the page
plain and unstyled rather than inventing a design system. Say so, and revisit when one exists.

## Visual language

Everything maps onto the project's own theme. **Do not introduce a second palette, type scale, or
spacing system.**

Four semantic states, each mapped to a role the project's palette already defines. If it has
`success` / `primary` / `muted` / `warning` tokens, use those names; if it names them differently,
use its names. Never hardcode a hex value:

| State | Role | Glyph |
|---|---|---|
| `done` | Success / positive | filled circle, check for criteria |
| `in-progress` | Accent / primary | half-filled circle |
| `planned` | Muted / neutral | open circle |
| `blocked` | Warning / danger | warning triangle |

PR state and test state reuse the same four roles: merged and approved read as success, changes
requested and failing as warning, draft and pending as muted, open as accent.

**Never encode status by colour alone.** Every state carries a glyph *and* a text label, so the page
works in greyscale and for colour-blind readers.

Typography: the project's existing scale. Page title, section heading, body, and one muted secondary
size — four steps, no more. Counts, points, durations, and dates in tabular or monospace figures so
columns line up.

Spacing: generous vertical rhythm between sections, tight within a card. The page should read as five
or six distinct blocks, not one continuous wall.

Dark mode: inherit the project's, if it has one. Do not build a separate toggle for this page.
