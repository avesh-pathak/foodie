import { SiteHeader } from "@/components/site-header";
import { Footer } from "@/components/footer";

export default function NotFound() {
  return (
    <>
      <a className="skip-link" href="#main">
        Skip to content
      </a>
      <SiteHeader />
      <main id="main" className="container" style={{ padding: "160px 0 120px", minHeight: "60vh" }}>
        <p className="kicker">404</p>
        <h1 style={{ fontSize: "clamp(2.5rem, 6vw, 4.5rem)" }}>That screen isn&apos;t on the menu.</h1>
        <p className="lede">The page you asked for does not exist. Start on the home page.</p>
        <p>
          <a className="btn btn--primary" href="/">Back to Foodie</a>
        </p>
      </main>
      <Footer />
    </>
  );
}
