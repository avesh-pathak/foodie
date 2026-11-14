import type { Metadata, Viewport } from "next";
import localFont from "next/font/local";
import { GalleryFilterProvider } from "@/components/gallery-provider";
import { SmoothScroll } from "@/components/smooth-scroll";
import { VideoProvider } from "@/components/video-provider";
import { site } from "@/lib/site";
import "./globals.css";

const jakarta = localFont({
  src: [
    { path: "./fonts/PlusJakartaSans-Regular.ttf", weight: "400", style: "normal" },
    { path: "./fonts/PlusJakartaSans-Medium.ttf", weight: "500", style: "normal" },
    { path: "./fonts/PlusJakartaSans-SemiBold.ttf", weight: "600", style: "normal" },
    { path: "./fonts/PlusJakartaSans-Bold.ttf", weight: "700", style: "normal" },
    { path: "./fonts/PlusJakartaSans-ExtraBold.ttf", weight: "800", style: "normal" },
  ],
  variable: "--font-jakarta",
  display: "swap",
  fallback: ["ui-sans-serif", "system-ui", "-apple-system", "Segoe UI", "sans-serif"],
});

const siteUrl = process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000";

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: {
    default: site.title,
    template: "%s | Foodie",
  },
  description: site.description,
  applicationName: "Foodie",
  authors: [{ name: "Avesh Pathak", url: site.portfolio }],
  creator: "Avesh Pathak",
  keywords: [
    "Foodie",
    "restaurant ordering",
    "Flutter",
    "Hono",
    "Neon Postgres",
    "case study",
  ],
  openGraph: {
    type: "website",
    url: "/",
    siteName: "Foodie",
    title: site.title,
    description: site.description,
    images: [
      {
        url: "/assets/img/og.png",
        width: 1200,
        height: 630,
        alt: "Foodie: one restaurant, three apps, one live system",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: site.title,
    description: site.description,
    images: ["/assets/img/og.png"],
  },
  icons: {
    icon: "/favicon.svg",
    apple: "/favicon.svg",
  },
  robots: {
    index: true,
    follow: true,
  },
};

export const viewport: Viewport = {
  themeColor: "#FFF8F4",
  colorScheme: "light",
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={jakarta.variable}>
      <body>
        <SmoothScroll />
        <VideoProvider>
          <GalleryFilterProvider>{children}</GalleryFilterProvider>
        </VideoProvider>
      </body>
    </html>
  );
}
