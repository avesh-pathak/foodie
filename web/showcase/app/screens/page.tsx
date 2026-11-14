import type { Metadata } from "next";
import Link from "next/link";
import { SiteHeader } from "@/components/site-header";
import { ScreensGallery } from "@/components/screens-gallery";
import { Footer } from "@/components/footer";

export const metadata: Metadata = {
  title: "All screens",
  description: "Every Foodie capture from the running Android build: customer, admin and kitchen.",
};

export default function AllScreensPage() {
  return (
    <>
      <a className="skip-link" href="#main">
        Skip to content
      </a>
      <SiteHeader />
      <main id="main" className="section screens">
        <div className="container">
          <div className="page-intro">
            <Link className="back-link" href="/">
              ← Back to Foodie
            </Link>
            <h1>All 30 screens.</h1>
            <p className="lede">
              Every capture from the running Android build, in one place. Filter by app, then click any
              screen to zoom. Use the arrows or swipe to move.
            </p>
          </div>
          <ScreensGallery all />
        </div>
      </main>
      <Footer />
    </>
  );
}
