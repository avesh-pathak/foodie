# One horizontal treatment for the connector labels

Written against: unavailable — `web/showcase/` is untracked in this repository (HEAD `f6fcd88`).

## Evidence chain

- Surface: `http://localhost:3000/` → `#architecture` → `.diagram__link`, the two dashed connectors between the Clients, API and Neon columns. Rendered at 1440×900 and 390×844.
- Problem: the same annotation has two incompatible treatments. Above 861 px each label is rotated -90° and overlaid on its rule. At or below 860 px the rotation is dropped, but the label stays centred in a 36 px row while the rule is pinned at `left: 24px` — measured at 390 px the label starts at x=188 and the rule sits at x=60, 128 px apart (355 px apart at 860). The connector then reads as a dashed stub at the far left with the word `HTTPS` floating in the middle of the row.
- Design evidence: `web/showcase/app/globals.css:1348–1360` (absolute, `translate(-50%, -50%) rotate(-90deg)`, `background: #1b1416` knockout) and `web/showcase/app/globals.css:2712–2727` (`height: 36px`, span `position: static; transform: none; margin-left: 40px`, rule at `left: 24px`).
- Owner: `web/showcase/app/globals.css`, `.diagram__link` and its ≤860 px override.
- Scope and affected surfaces: both connectors, every width.
- Uncertainty: the horizontal label measures 51–52 px inside the 64 px connector track, leaving about 6 px either side. Confirm this reads as a label in a gap rather than a label filling the track at 861–980 px, where the track is narrowest relative to the text.

## Design decision

Make both transport labels horizontal at every width, and keep each label anchored to the rule it names. The rule's orientation changes between the two layouts, so the anchoring changes with it: centred on the vertical rule in the wide layout, beside the rule in the stacked layout. The orientation must not change, because the stacked override already declares the horizontal treatment — the rotation is the outlier, not the mobile state.

## Reuse

- The ≤860 px block itself (`:2721–2727`) is the exemplar: it already sets `position: static; transform: none; padding: 0; background: none`, which is the intended horizontal label.
- `background: #1b1416` (`:1354`) stays as the knockout that interrupts the dashed rule behind the label; it is the existing mechanism, not a new one.
- No new token or primitive.

## Changes

1. `web/showcase/app/globals.css:1352`
   - Change: `transform: translate(-50%, -50%) rotate(-90deg);` → `transform: translate(-50%, -50%);`
   - Preserve: `position: absolute`, `top: 50%`, `left: 50%`, `padding: 0 6px`, `background: #1b1416`, `color: #8f7c7b`, `font-size: 12px`, `font-weight: 700`, `letter-spacing: 0.02em`, `white-space: nowrap`.
   - Verify: at 1440 and 861, `HTTPS` and `Drizzle` render horizontally, centred on their rules at 51 px and 52 px wide inside the 64 px tracks, with the rule interrupted behind the label and continuing above and below it.

2. `web/showcase/app/globals.css:2712`
   - Change: add `justify-content: flex-start;` to the `.diagram__link` rule inside `@media (max-width: 860px)`.
   - Preserve: `height: 36px`; the rule at `left: 24px` (`:2715–2720`); the span's `position: static`, `transform: none`, `padding: 0`, `background: none`, `margin-left: 40px` (`:2721–2727`); and `.diagram__packet { display: none }` (`:2728–2730`).
   - Verify: at 390 and 860 the label starts 16 px right of the rule (x=76 against a rule at x=60 at 390 px) and stays vertically centred in the 36 px row. It must not sit at the row's horizontal centre.

## Scope

- Inherit: both connectors and their packet dots (`.diagram__packet`, `:1369–1383`), which are unchanged.
- Verify: 861–980 px, where the 64 px track is tightest against a 52 px label; and 390 / 768 px stacked, where the label must sit beside the stub rather than in the middle of the row.
- Exclude: the packet dot, the rule colour `#5a4446`, the label copy, and the diagram's column alignment (covered by `architecture-header-baseline.md`).

## Validation

- Product: a reader can tell which link each label names without tilting their head, at any width.
- Interface: 1440, 1200, 980, 861, 860, 768, 390; no label overlapping a node card; no horizontal overflow.
- System: no new tokens or components; the knockout and the packet animation are untouched.
- Repository: `cd web/showcase && npm run typecheck` → no errors; `npm run build` → successful export.

## Stop conditions

- Stop if a horizontal label collides with a node card or the knockout gap reads wider than the connector track at 861–980 px. In that case widen the connector track from 64 px to 72 px in `.diagram { grid-template-columns }` rather than shrinking the 12 px label.

## Design documentation

- After acceptance and validation: none — `web/showcase/` has no design documentation to update.
