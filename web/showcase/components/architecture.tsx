import { CookingPot, Image as ImageIcon, PencilSimple, ShoppingCart } from "@phosphor-icons/react/dist/ssr";
import { flows } from "@/lib/site";

const flowIcons = {
  order: ShoppingCart,
  ready: CookingPot,
  menu: PencilSimple,
  photo: ImageIcon,
} as const;

export function Architecture() {
  return (
    <section className="section architecture" id="architecture">
      <div className="container">
        <header className="section-head">
          <h2>What happens when an order lands.</h2>
          <p className="lede">
            The Flutter apps never touch the database. They call a Hono API, which owns the credentials and
            writes to Neon. Realtime changes come back over one SSE stream.
          </p>
        </header>

        <div className="arch-sheet">
          <div className="arch-sheet__top">
            <div className="arch-brand">
              <img src="/assets/brand/foodie-mark.svg" width={30} height={30} alt="" />
              <strong>Foodie</strong>
              <span>Service ticket</span>
            </div>
            <p>Every write goes through the pass.</p>
            <span className="arch-stamp">Live path</span>
          </div>

          <div className="arch-rail">
            <div className="arch-station arch-station--clients">
              <p className="arch-station__label">Clients</p>
              <div className="arch-client">
                <img src="/assets/brand/foodie-mark.svg" width={28} height={28} alt="" />
                <div>
                  <strong>Customer</strong>
                  <small>Demo data, REST refresh</small>
                </div>
              </div>
              <div className="arch-client">
                <img src="/assets/brand/foodie-admin-logo.png" width={28} height={28} alt="" />
                <div>
                  <strong>Admin</strong>
                  <small>Menus, orders, analytics</small>
                </div>
              </div>
              <div className="arch-client">
                <img src="/assets/brand/foodie-admin-logo.png" width={28} height={28} alt="" />
                <div>
                  <strong>Kitchen</strong>
                  <small>Live board, SSE</small>
                </div>
              </div>
              <p className="arch-core">Shared models and API client: packages/foodie_core</p>
            </div>

            <div className="arch-link" aria-hidden="true">
              <span>HTTPS</span>
              <i />
            </div>

            <div className="arch-station arch-station--api">
              <p className="arch-station__label">The pass</p>
              <strong className="arch-station__name">Hono on Node</strong>
              <small>Bearer-token writes, CORS, SSE</small>
              <p className="arch-routes">auth, restaurants, menu, orders, analytics, images</p>
              <p className="arch-count">28 REST routes + /events</p>
            </div>

            <div className="arch-link" aria-hidden="true">
              <span>Drizzle</span>
              <i />
            </div>

            <div className="arch-station arch-station--store">
              <p className="arch-station__label">The store</p>
              <div className="arch-store">
                <strong>Postgres</strong>
                <small>12 tables, system of record</small>
              </div>
              <div className="arch-store">
                <strong>Object Storage</strong>
                <small>Presigned uploads</small>
              </div>
              <div className="arch-store">
                <strong>Realtime</strong>
                <small>restaurants, menu_items, orders</small>
              </div>
            </div>
          </div>

          <p className="arch-return">
            <span>SSE /events</span> changes flow back to the customer app and the kitchen board. Admin
            reloads on demand.
          </p>

          <div className="arch-chits">
            {flows.map((flow) => {
              const Icon = flowIcons[flow.id as keyof typeof flowIcons];
              return (
                <article className={`arch-chit arch-chit--${flow.tone}`} key={flow.id}>
                  <p className="arch-chit__label">
                    <Icon className="icon" weight="bold" aria-hidden="true" />
                    {flow.label}
                  </p>
                  <ol>
                    {flow.steps.map((step, index) => (
                      <li key={step.title}>
                        <span className="arch-chit__n" aria-hidden="true">{index + 1}</span>
                        <div>
                          <strong>{step.title}</strong>
                          <span>{step.body}</span>
                        </div>
                      </li>
                    ))}
                  </ol>
                </article>
              );
            })}
          </div>

          <p className="arch-caveat">
            The customer&apos;s order timeline is a local demo, advanced by hand or every six seconds. It is
            not wired to kitchen status writes.
          </p>

          <div className="arch-ledger">
            <div className="arch-ledger__col arch-ledger__col--real">
              <p className="arch-ledger__label">Real in this build</p>
              <ul>
                <li>Postgres rows for restaurants, menu items, prices, orders and availability.</li>
                <li>A Hono REST API and one <code>/events</code> SSE stream.</li>
                <li>Neon Realtime, Object Storage and daily summary tables.</li>
              </ul>
            </div>
            <div className="arch-ledger__col arch-ledger__col--demo">
              <p className="arch-ledger__label">Simulated on purpose</p>
              <ul>
                <li>Customer login is a name field.</li>
                <li>Payments, coupons, the rider map and support chat.</li>
                <li>The customer timeline and client-side totals.</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
