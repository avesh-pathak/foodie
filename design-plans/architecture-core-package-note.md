# Take the shared package out of the Clients column

Written against: unavailable — `web/showcase/` is untracked in this repository (HEAD `f6fcd88`).

## Evidence chain

- Surface: `http://localhost:3000/` → `#architecture` → the `Clients` column of `.diagram`.
- Problem: `packages/foodie_core` renders as the fourth item under the `Clients` header, after Customer, Admin and Kitchen, in the same column and the same left edge. Its own caption says "Models and API client shared by admin and kitchen", and `web/showcase/lib/site.ts:286` says the customer app has its own models. The column label therefore mis-groups it: a reader scanning the column reads four clients, one of which is not a client and one of which does not use the package.
- Design evidence: `web/showcase/components/architecture.tsx:41–44` places `.core` as the last child of the first `.diagram__col`; `web/showcase/app/globals.css:1321–1339` styles it as an unboxed 12 px note. The grouping is the only thing that makes it a client.
- Owner: `web/showcase/components/architecture.tsx` (structure) and `web/showcase/app/globals.css` `.core`.
- Scope and affected surfaces: the `#architecture` diagram band, all widths.
- Uncertainty: whether the footnote belongs inside the dark band or below it. This plan puts it inside, with a hairline, so the note stays with the diagram it annotates; the stop condition below covers the alternative.

## Design decision

Move the core-package note out of the Clients column into a full-width footnote row at the foot of the band, separated from the columns by a `--dark-line` hairline. It keeps the note attached to the diagram, stops the Clients column from implying the customer app shares `foodie_core`, and gives the band a bottom edge so the space under the shorter Neon column reads as margin instead of a hole.

## Reuse

- The existing `.core` block and its copy — no new component, token or primitive.
- `--dark-line` (`web/showcase/app/globals.css:23`) is the band's existing hairline token; it already separates the node borders from the band.
- The full-width row reuses the grid that is already there: `.diagram` is a five-track grid, so one child can span it with `grid-column: 1 / -1`.

## Changes

1. `web/showcase/components/architecture.tsx:41–44`
   - Change: move the `<p className="core"> … </p>` block out of the first `.diagram__col` and make it the last child of `.diagram`, after the third `.diagram__col`.
   - Preserve: the exact copy, the `<code>packages/foodie_core</code>` and `<span>Models and API client shared by admin and kitchen</span>` structure, and the element's class name.
   - Verify: the Clients column contains exactly Customer, Admin and Kitchen; the note is the last element inside `.diagram`.

2. `web/showcase/app/globals.css:1321–1328`
   - Change: replace `margin: 6px 0 0; padding: 0; border: 0;` with `grid-column: 1 / -1; margin: 20px 0 0; padding: 14px 0 0; border-top: 1px solid var(--dark-line);`.
   - Preserve: `color: var(--dark-muted)`, `font-size: 12px`, `line-height: 1.4`, and the `.core code` / `.core span` display rules below it.
   - Verify: at 1440 the note spans the band's full content width, sits below the tallest column, and has a 1 px `--dark-line` rule above it.

3. `web/showcase/app/globals.css`, inside `@media (max-width: 860px)` (`:2706–2730`)
   - Change: add `.core { margin-top: 4px; }`.
   - Preserve: the block's existing `gap: 16px` on `.diagram`, which already separates stacked rows; 16 px gap + 4 px margin keeps the same 20 px separation as the wide layout.
   - Verify: at 390 the note is the last element in the stacked band with 20 px above it, not 36 px.

## Scope

- Inherit: the Clients column, which loses about 40 px of height.
- Verify: the band's height grows by the footnote row; at 1440 the space under the Neon column shrinks; at 390 the note follows the Neon column rather than the Clients column.
- Exclude: the copy itself, and `.diagram__return` (`:1439–1459`), which stays outside the band as the section's return-path sentence.

## Validation

- Product: the Clients column reads as three apps; the shared package reads as a note about the diagram.
- Interface: 1440, 1200, 900, 861 and 390; the hairline must not read as a fourth column header or as the top border of the Neon column.
- System: no new tokens or components; the note keeps its existing typography.
- Repository: `cd web/showcase && npm run typecheck` → no errors; `npm run build` → successful export.

## Stop conditions

- Stop if, at 1440, the footnote reads as part of the Neon column or as a fourth column header. In that case move the note below the band next to `.diagram__return` and switch its colour from `var(--dark-muted)` to `var(--muted)` for the light surface.

## Design documentation

- After acceptance and validation: none — `web/showcase/` has no design documentation to update.
