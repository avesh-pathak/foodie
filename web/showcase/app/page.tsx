import type { CSSProperties } from "react";
import { SiteHeader } from "@/components/site-header";
import { Hero } from "@/components/hero";
import { Apps } from "@/components/apps";
import { ScreensGallery } from "@/components/screens-gallery";
import { Architecture } from "@/components/architecture";
import { Tour } from "@/components/tour";
import { Build } from "@/components/build";
import { Faq } from "@/components/faq";
import { Footer } from "@/components/footer";

const swatches = [
  { hex: "#DC2B3B", name: "Brand red" },
  { hex: "#A8121F", name: "Deep red" },
  { hex: "#FDEBEE", name: "Soft red" },
  { hex: "#1C1C1E", name: "Ink" },
];

export default function HomePage() {
  return (
    <>
      <a className="skip-link" href="#main">Skip to content</a>
      <SiteHeader />
      <main id="main">
        <Hero />
        <Apps />

        <section className="section screens" id="screens">
          <div className="container">
            <header className="section-head">
              <h2>Selected screens, straight from the build.</h2>
              <p className="lede">
                Eight screens from the running Android build, grouped by app. No redraws and no placeholder
                UI. Click or tap any screen to zoom. Use the arrows or swipe to move.
              </p>
            </header>

            <ScreensGallery />

            <div className="spec">
              <div className="spec__item">
                <p className="spec__label">Colour</p>
                <div className="spec__swatches" aria-label="Brand palette">
                  {swatches.map((swatch) => (
                    <span
                      className="swatch"
                      key={swatch.hex}
                      style={{ "--swatch": swatch.hex } as CSSProperties}
                    >
                      <b>{swatch.hex}</b>
                    </span>
                  ))}
                </div>
              </div>
              <div className="spec__item">
                <p className="spec__label">Type</p>
                <p>Plus Jakarta Sans, 400 to 800. One family across the apps and this page.</p>
              </div>
              <div className="spec__item">
                <p className="spec__label">Themes</p>
                <p>Light red-on-white and red-on-black, both shipped in the app.</p>
              </div>
              <div className="spec__item">
                <p className="spec__label">Targets</p>
                <p>44 px in the apps; labelled controls and reduced motion on this page.</p>
              </div>
            </div>
          </div>
        </section>

        <Architecture />
        <Tour />
        <Build />
        <Faq />
      </main>
      <Footer />
    </>
  );
}
