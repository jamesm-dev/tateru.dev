---
title: Reference Implementation
created: 2026-08-31
updated: 2026-08-31
tags: [design, management, ui, reference]
status: active
---

# Reference Implementation

The measured fixed point. [[Design System]] says *use the project's own theme*; this note says
**what the result must measure**, so a rebuild on a different stack lands in the same place instead
of somewhere defensible but different.

> [!important] The app's theme wins on appearance. This note wins on layout and behaviour.
> These are not in competition, because they govern different things.
>
> | Owned by the app's theme and components | Owned by this note |
> |---|---|
> | Colour, palette, dark mode | Spacing, size, ratio, breakpoint |
> | Font family and weight | Type **scale** — how many steps and their relationship |
> | Component identity — its Card *is* the card | Component **anatomy** — what is inside it and in what order |
> | Border, shadow, motion style | Layout mechanics, and every behaviour |
>
> So: **use the project's `Card`, in the project's colours, with this note's padding and this note's
> contents.** A dashboard that looks like a second product bolted onto the app has failed, however
> exactly it matches these numbers.
>
> **Where the project has its own scale**, take its nearest step rather than a literal pixel value —
> `p-4` in Tailwind, `space.4` in Chakra. The ratios survive; the values bend to the host.
>
> **Where the project has nothing** — a bare Phase 0 skeleton with no tokens and no components —
> build the components and use these values as written. That is the case these numbers were
> measured for.
>
> Record any substitution in the build report. A silent one is how two builds drift apart.

## Layout constants

| Constant | Value | Why it is this and not another |
|---|---|---|
| Sidebar width | `248px` | Fits the longest nav label plus its count without wrapping, at 14px base |
| Corner radius | `12px` | One radius everywhere except inputs |
| Input radius | `7px` | Deliberately tighter than cards, so controls read as controls |
| Base font size | `14px` | A dashboard is scanned, not read. 16px pushes the fifth column off screen |
| Pill radius | `99px` | Full round; never a rounded rectangle, which reads as a button |
| Shell grid | `248px minmax(0, 1fr)` | **`minmax(0, 1fr)`, never `1fr`** — see the warning below |
| Content padding | `32px 32px 48px` | Extra at the bottom so the last row clears the fold |
| Prose max width | `78ch` | Applies to ledes and notes only. The page itself has **no** max width |

> [!danger] `minmax(0, 1fr)` is load-bearing
> A plain `1fr` track takes an automatic minimum of its content. The board's horizontal scroller
> then grows the track instead of scrolling inside it, and the last column is pushed off screen —
> looking like a board bug when it is a grid bug two levels up. Any grid or flex parent of the
> board needs an explicit zero minimum (`minmax(0, 1fr)`, or `min-width: 0`).

## The spacing scale

**4 · 8 · 12 · 16 · 24 · 32 · 48.** Seven steps, nothing between them.

| Step | Value | Used for |
|---|---|---|
| 1 | `4px` | Icon-to-label, pill inner |
| 2 | `8px` | Inside a row of controls |
| 3 | `12px` | **Between cards in a column**; heading to its own content |
| 4 | `16px` | **Card inner padding**; gap between board columns |
| 5 | `24px` | Between grid cards; sidebar padding; default gap |
| 6 | `32px` | **Between sections**; content padding |
| 7 | `48px` | Bottom of page |

A gap that wants 14px means the layout is wrong, not the scale.

**The proximity rule:** a heading sits nearer its own content (12px) than the block above it (32px).
Proximity is what says which block a heading owns; without it a page is one wall.

## Breakpoints

Three, each for a different reason:

| Width | What changes |
|---|---|
| `≤ 900px` | Board columns become `82vw` each and the board is swiped, not squeezed |
| `≤ 820px` | Shell collapses to one column; sidebar becomes a horizontal top bar |
| `< 768px` | Drawer becomes a bottom sheet instead of a right-hand panel |

They are deliberately not equal. The board fails first because five columns need width before the
shell does.

## Board geometry

```
.board-columns   flex · gap 16px · overflow-x auto · scrollbar-gutter stable
  > .col         flex 1 1 0 · min-width 220px
```

`flex: 1 1 0` with a `220px` floor is what produces "15–20% of the viewport". Above the floor the
five columns share the width evenly; below it the board scrolls rather than compressing a card to
unreadable. **Do not** use `grid-template-columns: repeat(5, 1fr)` — it has no floor and squeezes.

Grid areas elsewhere use `repeat(auto-fit, minmax(N, 1fr))`: `230px` for column grids, `190px` for
the headline tiles.

## Epic colour

Four hue families, **not** one hue per epic. A real project outgrows eight categorical colours, and
a generated ninth is the anti-pattern [[Accessibility And Anti-Patterns]] forbids.

```
PHASE_HUES = [152, 210, 32, 285]          # green, blue, amber, violet

hue   = PHASE_HUES[phase mod 4]
shade = min(indexInPhase, 3) * 9          # capped: never washes out
colour = hsl(hue, 58%, L + shade)
  where L = 34% in light mode, 58% in dark
```

`indexInPhase` comes from epics sorted by **phase, then title** — computed once, centrally, so Board,
Specs, Team and Status colour the same epic identically. Deriving the index per section drifts the
moment one of them sorts differently. See `epicColours` in [[Derivations]].

Consequences worth keeping: epics in the same phase look related, because they are. Advancing a
phase never recolours anything. The colour is always accompanied by the epic's name — colour is an
aid, never the identifier.

## Semantic colours

Two are defined here because no app theme reliably has them; everything else comes from the project.

| Token | Light | Dark | Role |
|---|---|---|---|
| `surface-2` | `#f3f1ec` | `#242429` | Sidebar and raised control backgrounds |
| `warn` | `#a8620a` | `#d9a05b` | Parked, ad-hoc, pending, attention |

Both are contrast-checked against their own backgrounds in both schemes. `done` / `in-progress` /
`planned` / `blocked` map to the project's existing success, accent, muted and danger roles.

## Typography

Four steps, no more.

| Role | Size | Weight |
|---|---|---|
| Page title (`h2`) | `1.5rem`, tracking `-0.01em` | default |
| Tile value | `1.6rem`, tracking `-0.02em` | `600` |
| Body | `14px` base | default |
| Section label | `0.8rem`, uppercase, tracking `0.06em` | default, muted |
| Meta — ids, pills, counts | `0.72rem` | default, muted |

**Every number is tabular.** Counts, points, durations and dates use `font-variant-numeric:
tabular-nums`, and reference ids use the monospace stack. A column of figures that shifts as it
updates cannot be scanned.

## Component anatomy

**Sidebar** — sticky, full height, own scroll, `surface-2`, 1px right border. Project name, then
current phase, then the active sprint line (absent entirely when no sprint exists — never the words
"No sprint defined"). Nav items are buttons in a `<nav>`; the active one carries
`aria-current="page"`, weight `600`, and a `2px` inset accent bar on its leading edge. Counts sit
right-aligned and muted, inside the accessible name. Phase progress sits in the footer as a `6px`
bar **plus its count as text**.

**Task card** — a list item containing a button. Reference id in monospace above the title; title at
body size; a wrap-friendly meta row beneath. `16px` padding, `12px` between cards, and a leading
edge in its epic's colour. Never a plain container with a click handler.

**Drawer** — right-hand panel above 768px, bottom sheet below. Modal: focus moves in, is trapped,
returns to the originating card on close. Escape closes, backdrop closes, the page behind does not
scroll, `?task=` makes it linkable and the back button closes it. Animates from the edge and
respects `prefers-reduced-motion`. **Built once in `ui/` and reused** — a drawer serving one caller
is a modal in disguise.

The sticky drawer title keeps its top padding when it sticks. A heading that loses its spacing on
scroll looks like a rendering fault.

## Related

[[Design System]] · [[Page Layout]] · [[Derivations]] · [[API Surface]] · [[Copy Deck]] ·
[[Task Card And Drawer]] · [[Accessibility And Anti-Patterns]]
