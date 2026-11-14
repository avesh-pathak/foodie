import { faqs } from "@/lib/site";

export function Faq() {
  return (
    <section className="section faq" id="faq">
      <div className="container faq__grid">
        <div className="faq__intro">
          <h2>What this is, and what it isn&apos;t.</h2>
          <p className="lede">
            The short version: a real three-app build with a real API and database, and a demo-sized set of
            simulated product flows.
          </p>
        </div>
        <div className="faq__list">
          {faqs.map((item, index) => (
            <details key={item.q} open={index === 0}>
              <summary>{item.q}</summary>
              <p>{item.a}</p>
            </details>
          ))}
        </div>
      </div>
    </section>
  );
}
