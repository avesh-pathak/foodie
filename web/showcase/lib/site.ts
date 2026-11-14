import type { AppId } from "@/lib/screens";

export const site = {
  name: "Foodie",
  title: "Foodie: three apps, one restaurant system",
  description:
    "A restaurant-ordering demo: a Flutter customer app, admin console and kitchen board on one Hono + Neon Postgres backend. Selected screens and a 30-second tour.",
  email: "iamaveshpathak@gmail.com",
  portfolio: "https://avesh.tech",
  linkedin: "https://www.linkedin.com/in/avesh-pathak/",
  repo: "https://github.com/avesh-pathak/foodie",
  nav: [
    { label: "Apps", href: "#apps" },
    { label: "Screens", href: "#screens" },
    { label: "Architecture", href: "#architecture" },
    { label: "Tour", href: "#tour" },
    { label: "Build", href: "#build" },
  ],
} as const;

export type AppCard = {
  id: AppId;
  label: string;
  title: string;
  description: string;
  bullets: string[];
  demo: string;
  demoKind: "text" | "credentials";
  linkLabel: string;
  main: { src: string; alt: string; width: number; height: number };
  aside: { src: string; alt: string; width: number; height: number };
};

export const apps: AppCard[] = [
  {
    id: "customer",
    label: "Customer app",
    title: "Order it. Then watch it arrive.",
    description:
      "Browse six restaurants and 28 dishes, customise with add-ons, apply a coupon and place an order. The bill stays live through checkout, and a six-step timeline takes it from placed to delivered.",
    bullets: [
      "Search, favourites and a cart with quantity controls.",
      "Coupons, GST, delivery fee and COD / UPI / card checkout.",
      "A six-step timeline and a hand-drawn demo map.",
      "Light theme and a red-on-black dark theme.",
    ],
    demo: "Any name, phone or email. Password optional.",
    demoKind: "text",
    linkLabel: "See customer screens",
    main: {
      src: "/assets/img/screens/home.webp",
      alt: "Foodie home screen with delivery address, offer carousel and cuisine filters",
      width: 520,
      height: 1125,
    },
    aside: {
      src: "/assets/img/screens/home-dark.webp",
      alt: "Foodie home screen in the red-on-black dark theme",
      width: 520,
      height: 1125,
    },
  },
  {
    id: "admin",
    label: "Admin app",
    title: "Run the menu. Read the numbers.",
    description:
      "Six restaurants, their menus and prices, photo uploads, every order, and nine analytics endpoints over Neon summary tables.",
    bullets: [
      "Restaurant, menu and price editing.",
      "Presigned photo uploads to Neon Object Storage.",
      "Order status control and prep-time metrics.",
      "Revenue, AOV, returns, peak hours and areas.",
    ],
    demo: "admin / password123",
    demoKind: "credentials",
    linkLabel: "See admin screens",
    main: {
      src: "/assets/img/screens/admin-analytics.webp",
      alt: "Foodie Admin analytics dashboard with revenue, orders, AOV and returns",
      width: 520,
      height: 1156,
    },
    aside: {
      src: "/assets/img/screens/admin-menu.webp",
      alt: "Foodie Admin menu and price editor with dish thumbnails",
      width: 520,
      height: 1156,
    },
  },
  {
    id: "kitchen",
    label: "Kitchen app",
    title: "Cook from the pass. Mark it ready.",
    description:
      "A restaurant-scoped board for confirmed, preparing and ready orders. Prep timers turn amber at 10 minutes and red at 20; sold-out toggles reach the customer app over SSE.",
    bullets: [
      "Confirmed, preparing and ready columns.",
      "Live prep timers with green, amber and red states.",
      "Start cooking and mark ready in one tap.",
      "Item availability that updates the customer menu.",
    ],
    demo: "kitchen / password123",
    demoKind: "credentials",
    linkLabel: "See kitchen screens",
    main: {
      src: "/assets/img/screens/kitchen-orders.webp",
      alt: "Foodie Kitchen orders board with ready orders and preparation timers",
      width: 520,
      height: 1156,
    },
    aside: {
      src: "/assets/img/screens/kitchen-availability.webp",
      alt: "Foodie Kitchen item availability toggles",
      width: 520,
      height: 1156,
    },
  },
];

export type FlowStep = { title: string; body: string };
export type FlowTone = "red" | "gold" | "green" | "info";
export type Flow = {
  id: string;
  label: string;
  tone: FlowTone;
  steps: FlowStep[];
};

export const flows: Flow[] = [
  {
    id: "order",
    label: "Place an order",
    tone: "red",
    steps: [
      {
        title: "Total the cart",
        body: "The customer app calculates subtotal, GST, delivery and any coupon.",
      },
      {
        title: "Write the order",
        body: "POST /orders stores the order, items and a pending status in Postgres.",
      },
      {
        title: "Pass it on",
        body: "An admin confirms; the kitchen board refreshes over SSE.",
      },
    ],
  },
  {
    id: "ready",
    label: "Mark it ready",
    tone: "gold",
    steps: [
      {
        title: "Read the board",
        body: "The kitchen app loads orders for its restaurant and listens for changes.",
      },
      {
        title: "Stamp the time",
        body: "PUT /orders/:id/status sets preparing and ready timestamps.",
      },
      {
        title: "Refresh the pass",
        body: "The API broadcasts; the board re-reads the order list.",
      },
    ],
  },
  {
    id: "menu",
    label: "Change the menu",
    tone: "green",
    steps: [
      {
        title: "Edit a dish",
        body: "Admin changes a price, category or photo.",
      },
      {
        title: "Save it",
        body: "PUT /menu/:id writes the item and add-ons to Postgres.",
      },
      {
        title: "Refresh the menu",
        body: "Neon Realtime and /events tell the customer app to reload.",
      },
    ],
  },
  {
    id: "photo",
    label: "Upload a photo",
    tone: "info",
    steps: [
      {
        title: "Ask for a URL",
        body: "Admin calls POST /images/presign.",
      },
      {
        title: "Upload direct",
        body: "The app PUTs the file to Neon Object Storage.",
      },
      {
        title: "Save the URL",
        body: "PUT /menu/:id stores it; the menu refreshes over SSE.",
      },
    ],
  },
];

export const faqs = [
  {
    q: "Is this a real product?",
    a: "It is a portfolio build. The three apps, the API, the database and the realtime path are real and run locally. Payments, coupons, rider tracking and support chat are simulated.",
  },
  {
    q: "Can I try it in the browser?",
    a: "Not yet. The apps are Flutter and the customer app has a web target, but a hosted demo is not part of this build. The selected screenshots, the all-screens page and the 30-second tour cover the main surfaces.",
  },
  {
    q: "Where does the data live?",
    a: "Neon Postgres. Six restaurants and 28 dishes are seeded; admin and kitchen writes persist. The customer app falls back to its bundled demo data when the API is unreachable.",
  },
  {
    q: "How does realtime work?",
    a: "Neon Realtime watches restaurants, menu items and orders. The API republishes changes on /events; the customer app refreshes menus, and the kitchen board refreshes orders. Admin reloads on demand. The customer's order timeline is simulated.",
  },
  {
    q: "Why three apps instead of one?",
    a: "ADR 0001: keep operator concerns out of the customer build while sharing models and the API client in foodie_core. The kitchen gets a board tuned for a phone at the pass, not a tab inside the admin console.",
  },
] as const;

export const commands = {
  api: `cd server
npm install
npm run db:seed
npm run db:seed:orders
npm run dev`,
  flutter: `cd admin   # or kitchen, or the repo root
flutter pub get
flutter run`,
  apk: "flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64",
} as const;

export const reviewFiles = [
  ["lib/state/foodie_app_state.dart", "Cart, coupons, bill maths and order state"],
  ["lib/services/api_sync.dart", "The SSE loop and menu refresh"],
  ["server/src/routes/orders.ts", "Order writes, status timestamps, summary upserts"],
  ["server/src/realtime.ts", "Neon Realtime to SSE fan-out"],
  ["packages/foodie_core/lib/src/api/client.dart", "The shared admin + kitchen API client"],
] as const;

export const credentials = [
  ["Customer", "Any name, phone or email. Password optional."],
  ["Admin", "admin / password123"],
  ["Kitchen", "kitchen / password123"],
] as const;

export const transcript = [
  ["0:00", "One restaurant, three apps, one live system."],
  ["0:06", "Customers browse six restaurants and 28 dishes, then track a demo delivery."],
  ["0:12", "Admins run menus, prices, orders and analytics."],
  ["0:18", "The kitchen cooks from a live board with prep timers."],
  ["0:24", "One Hono API. Neon Postgres, storage and realtime."],
  ["0:27", "Foodie, built with Flutter and Neon."],
] as const;
