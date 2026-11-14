import rawScreens from "@/tools/screens.json";

export type AppId = "customer" | "admin" | "kitchen";

export type Screen = {
  slug: string;
  src: string;
  app: AppId;
  title: string;
  alt: string;
  caption: string;
  thumb: string;
  full: string;
};

export const screens = rawScreens as unknown as Screen[];

export const appNames: Record<AppId, string> = {
  customer: "Customer",
  admin: "Admin",
  kitchen: "Kitchen",
};

const featuredSlugs = [
  "home",
  "dish-customisation",
  "cart",
  "tracking",
  "admin-analytics",
  "admin-menu",
  "kitchen-orders",
  "kitchen-availability",
];

export const featuredScreens = featuredSlugs
  .map((slug) => screens.find((screen) => screen.slug === slug))
  .filter((screen): screen is Screen => Boolean(screen));

export const screenCounts: Record<"all" | AppId, number> = {
  all: featuredScreens.length,
  customer: featuredScreens.filter((screen) => screen.app === "customer").length,
  admin: featuredScreens.filter((screen) => screen.app === "admin").length,
  kitchen: featuredScreens.filter((screen) => screen.app === "kitchen").length,
};

export const allScreenCounts: Record<"all" | AppId, number> = {
  all: screens.length,
  customer: screens.filter((screen) => screen.app === "customer").length,
  admin: screens.filter((screen) => screen.app === "admin").length,
  kitchen: screens.filter((screen) => screen.app === "kitchen").length,
};

export const screenHeight = (app: AppId) => (app === "customer" ? 1125 : 1156);
