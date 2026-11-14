# Put the three diagram headers on one baseline

Written against: unavailable — `web/showcase/` is untracked in this repository (HEAD `f6fcd88`).

## Evidence chain

- Surface: `http://localhost:3000/` → `#architecture` → `.diagram`, rendered at 1440×900, 1200×900, 900×900 and 861×900.
- Problem: `Clients`, `API` and `Neon` are the same element (`.diagram__label`) in peer columns, but they sit on three baselines. Measured header tops: 340 / 353 / 379 px at 1440 (39 px spread), 37 px at 900, 42 px at 861.
- Design evidence: `web/showcase/app/globals.css:1265–1275` — `.diagram` is a five-track grid with `align-items: center`. Each of the three columns is centred on its own height (316 / 289 / 238 px for API / Clients / Neon), so the shorter a column is, the lower its header lands.
- Owner: `web/showcase/app/globals.css`, `.diagram` block.
- Scope and affected surfaces: the `#architecture` diagram band at every width ≥861 px. The ≤860 px stacked layout stacks columns into one track and is not affected by the misalignment.
- Uncertainty: none for the alignment itself. Top-aligning moves the band's spare space to the bottom-right; that space is addressed by `architecture-core-package-note.md` if that plan is also taken.

## Design decision

Top-align the diagram's columns. `align-items: center` centres five independently sized tracks, so three headers with the same role land at three heights. The columns are peers in one topology; their headers must share a line, and the column bodies must start from that same line.

## Reuse

- `align-items` on the existing `.diagram` grid — no new token, component or primitive.
- Exemplar: `.flow-steps` (`web/showcase/app/globals.css:1499–1504`) is the same composition inside the same section — four peer steps aligned from a shared top edge rather than centred.

## Changes

1. `web/showcase/app/globals.css:1268`
   - Change: `align-items: center;` → `align-items: start;` inside `.diagram`.
   - Preserve: `grid-template-columns`, `padding: 32px 26px`, the `linear-gradient` background, and `.diagram__link { align-self: stretch }` (`:1341–1347`), which keeps both connector rules full height regardless of the container's `align-items`.
   - Verify: at 1440, 1200, 900 and 861 the three `.diagram__label` elements report identical `getBoundingClientRect().top`. A live override of this one property produced 4600 / 4600 / 4600.

## Scope

- Inherit: both `.diagram__link` columns (they keep stretching) and all three `.diagram__col` bodies (they now start from the header line).
- Verify: the ≤860 px stacked layout — `align-items` still applies to the single-track grid, so each stacked row must still start at the same edge and `.diagram__link` must keep `height: 36px`.
- Exclude: the API node's route table, which is what makes the middle column 316 px tall. Do not shorten it here; that is a separate decision.

## Validation

- Product: a reader scanning the band sees one header row and three columns that start together.
- Interface: 1440, 1200, 900 and 861 wide; the ≤860 px stacked layout at 390 and 768; no horizontal overflow.
- System: no new tokens, components or primitives; the connector rules still run the full height of the band.
- Repository: `cd web/showcase && npm run typecheck` → no errors; `npm run build` → successful export.

## Stop conditions

- Stop if the space under the Neon column at 1440 exceeds roughly a quarter of the band's height and reads as a hole rather than margin. That means the API node's route inventory, not the alignment, is driving the band's height, and this plan alone will not settle it.

## Design documentation

- After acceptance and validation: none — `web/showcase/` has no design documentation to update.
