# Design

<!-- impeccable:design-schema 1 -->

## Visual system

- **Mode:** Experience (showcase). The artifact leads; the interface recedes.
- **Surface:** warm paper `#FFF8F4` (`--paper`), with a single dark band `#171112`–`#1E1719` for the architecture diagram.
- **Accent:** Foodie red `#DC2B3B` (`--red`), deep `#A8121F`, soft `#FDEBEE`. Red carries action and emphasis only.
- **Type:** Plus Jakarta Sans 400–800 (`--sans`); mono `--mono` for routes and code. Supporting type floor 12 px.
- **Radius:** `--radius` 18 px; nodes 12–14 px; pills 999 px.
- **Spacing:** container 1180 px; section rhythm via `clamp()`.
- **Shadow:** `--shadow-lg` for the one elevated dark band; otherwise flat.
- **Motion:** one authored packet animation on the connectors; `prefers-reduced-motion` collapses it.

## Tokens

Defined in `web/showcase/app/globals.css` `:root` (lines 2–31): `--paper`, `--ink`, `--muted`, `--subtle`, `--line`, `--red*`, `--dark*`, `--shadow-*`, `--radius`, `--container`, `--sans`, `--mono`, `--ease`, `--focus`.

## Components

- `.diagram` — 5-track grid: Clients / link / API / link / Neon. Top-aligned columns; connector labels horizontal and centred on the rule.
- `.flow-tabs` / `.flow-panel` — tabbed stepper with keyboard navigation.
- `.fold` — `<details>` rows for tables, API surface, decisions.
- `.realness` — two-column "real vs. simulated" split.
- `.node`, `.api-node`, `.core` — diagram primitives.

## Constraints

- No network images; local assets only (`FoodieImage` / `/assets`).
- 44 px minimum tap targets on labelled controls.
- Reduced motion honoured in CSS and JS.