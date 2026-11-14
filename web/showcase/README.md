# Foodie showcase

The Next.js landing page for the Foodie restaurant-ordering build. It presents the
customer, admin and kitchen apps, the architecture behind them, a selected screen
gallery and a 30-second product tour.

The site lives in `web/showcase/` so it sits inside the existing `web/` folder without
overwriting Flutter's `web/index.html` (the app's web host).

## Stack

- Next.js 16 (App Router) and React 19
- TypeScript, strict
- Custom CSS design system in `app/globals.css` (no Tailwind dependency)
- Motion for the app tabs and mobile menu
- Lenis for restrained smooth scrolling, disabled with `prefers-reduced-motion`
- Phosphor icons
- Self-hosted Plus Jakarta Sans via `next/font/local`

## Run it

```bash
cd web/showcase
npm install
npm run dev -- -p 3000
```

Open `http://localhost:3000`. The current session is already running there.

Production check:

```bash
npm run typecheck
npm run build
npm start
```

## Routes

- `/` - the showcase
- `/screens` - all 30 captures, with the same filters and lightbox

## Where the content comes from

- Screenshots: `docs/screenshots/` at the repo root. `npm run assets` copies and
  converts every capture to two WebP sizes in `public/assets/img/screens/` and writes
  `tools/screens.json`.
- Selected set: `lib/screens.ts` chooses the eight screens shown on the landing page.
  The all-screens route reads the same manifest.
- Logos:
  - `public/assets/brand/foodie-mark.svg` mirrors the customer app's red gradient
    tile and white ramen mark (`lib/widgets/foodie_logo.dart`).
  - `public/assets/brand/foodie-admin-logo.png` is copied from the admin/kitchen app
    branding (`admin/assets/brand/`).
  - `public/favicon.svg` is the same customer mark.
- Video: `public/video/index.html` is the composition. `npm run render` serves
  `public/`, captures 900 deterministic frames with Playwright and encodes
  `public/assets/video/foodie-tour.mp4` with ffmpeg. `npm run og` regenerates the
  1200 x 630 social card.

## Structure

```text
web/showcase/
├─ app/
│  ├─ page.tsx           the showcase
│  ├─ screens/page.tsx   all 30 captures
│  ├─ layout.tsx         fonts, metadata, providers
│  └─ globals.css        design system
├─ components/           header, hero, apps, gallery, architecture, tour, build, FAQ, footer
├─ lib/                  typed screen manifest and site copy
├─ public/
│  ├─ assets/brand/      Foodie and admin logos
│  ├─ assets/img/        screens and OG image
│  ├─ assets/video/      MP4 and poster
│  └─ video/             HTML composition used by the renderer
└─ tools/                asset, video, OG and QA scripts
```

## Verified facts on the page

- 3 Flutter apps: customer (`lib/`), admin (`admin/`), kitchen (`kitchen/`)
- 28 REST routes plus the `/events` SSE stream
- 6 seeded restaurants and 28 dishes
- 12 Postgres tables, 9 analytics endpoints
- 44 px targets in the apps; labelled controls and reduced motion on this page
- 30 screenshots captured from the running Android build on a Redmi

Payments, coupons, rider tracking, support chat and the customer order timeline are
simulated. Admin, kitchen and menu writes are real rows in Neon Postgres.

## Deploy

The site is standard Next.js and deploys to Vercel or Netlify without special
configuration. Before sharing, set the absolute origin:

```bash
NEXT_PUBLIC_SITE_URL=https://your-domain.example
```

That value drives canonical and Open Graph URLs. The fallback is
`http://localhost:3000`.

## Verification

```bash
npm run typecheck
npm run check:assets   # every /assets/... reference resolves in public/
npm run build
node tools/qa.mjs
node tools/qa-interactions.mjs
```

Current local checks:

- TypeScript and production build pass
- 30/30 interaction checks pass
- axe-core: no serious violations on `/` or `/screens`
- Impeccable URL detector: one warning remains, the deliberate cream brand
  background (`#FFF8F4`), down from 84 findings
- Video: 1920 x 1080, 30 fps, 900 frames, 30.000 s, H.264, silent

## Known limits

- There is no hosted Flutter demo. The Build section links to the public repository
  and shows the local run steps.
- Contact details are inherited from the existing portfolio site; update
  `lib/site.ts` if they change.
- The tour is silent and captioned; a voiced version is not part of this build.
- `tools/frames/` and `tools/.qa/` are ignored runtime artifacts.
- `public/assets/` is runtime content (screens, OG card, tour video), not build
  output, so it is committed. `prebuild` runs `check:assets` and fails before
  `next build` if any referenced file is missing.
