import { AppsTabs } from "@/components/apps-tabs";

export function Apps() {
  return (
    <section className="section apps" id="apps">
      <div className="container">
        <header className="section-head">
          <h2>Three apps. One source of truth.</h2>
          <p className="lede">
            Each app has one job and reads the same API, so a price change, a sold-out dish or an order lands
            where it matters.
          </p>
        </header>
        <AppsTabs />
      </div>
    </section>
  );
}
