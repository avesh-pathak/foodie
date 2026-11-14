import Image from "next/image";
import { ArrowDown, Play } from "@phosphor-icons/react/dist/ssr";
import { LiveTicket } from "@/components/live-ticket";
import { VideoButton } from "@/components/video-provider";

export function Hero() {
  return (
    <section className="hero" id="top">
      <div className="hero__glow" aria-hidden="true" />
      <div className="container hero__grid">
        <div className="hero__copy">
          <h1>
            One restaurant
            <br />
            Three apps
            <br />
            <span className="hero__accent">One live system</span>
          </h1>
          <p className="lede">
            A Flutter customer app, admin console and kitchen board on one Hono and Neon Postgres backend.
          </p>
          <div className="hero__actions">
            <a className="btn btn--primary" href="#apps">
              Explore the apps <ArrowDown className="icon" weight="bold" aria-hidden="true" />
            </a>
            <VideoButton className="btn btn--ghost">
              <span className="btn__play" aria-hidden="true">
                <Play className="icon" weight="fill" />
              </span>
              Watch the 30s tour
            </VideoButton>
          </div>
        </div>

        <div className="hero__visual">
          <div className="pass">
            <div className="pass__phones">
              <figure className="phone phone--admin">
                <div className="phone__screen">
                  <Image
                    src="/assets/img/screens/admin-analytics.webp"
                    width={520}
                    height={1156}
                    alt="Foodie Admin analytics screen with revenue, orders and returns"
                    loading="eager"
                    fetchPriority="high"
                    sizes="(max-width: 640px) 43vw, (max-width: 980px) 34vw, 20vw"
                  />
                  <Image
                    src="/assets/img/screens/admin-menu.webp"
                    width={520}
                    height={1156}
                    alt=""
                    loading="lazy"
                    sizes="(max-width: 640px) 43vw, (max-width: 980px) 34vw, 20vw"
                  />
                  <Image
                    src="/assets/img/screens/admin-orders.webp"
                    width={520}
                    height={1156}
                    alt=""
                    loading="lazy"
                    sizes="(max-width: 640px) 43vw, (max-width: 980px) 34vw, 20vw"
                  />
                </div>
                <figcaption>Admin</figcaption>
              </figure>
              <figure className="phone phone--kitchen">
                <div className="phone__screen">
                  <Image
                    src="/assets/img/screens/kitchen-orders.webp"
                    width={520}
                    height={1156}
                    alt="Foodie Kitchen orders board with ready orders and prep timers"
                    loading="eager"
                    fetchPriority="high"
                    sizes="(max-width: 640px) 43vw, (max-width: 980px) 34vw, 20vw"
                  />
                  <Image
                    src="/assets/img/screens/kitchen-availability.webp"
                    width={520}
                    height={1156}
                    alt=""
                    loading="lazy"
                    sizes="(max-width: 640px) 43vw, (max-width: 980px) 34vw, 20vw"
                  />
                  <Image
                    src="/assets/img/screens/kitchen-login.webp"
                    width={520}
                    height={1156}
                    alt=""
                    loading="lazy"
                    sizes="(max-width: 640px) 43vw, (max-width: 980px) 34vw, 20vw"
                  />
                </div>
                <figcaption>Kitchen</figcaption>
              </figure>
              <figure className="phone phone--customer">
                <div className="phone__screen">
                  <Image
                    src="/assets/img/screens/home.webp"
                    width={520}
                    height={1125}
                    alt="Foodie home screen with address, offer and cuisine filters"
                    loading="eager"
                    sizes="(max-width: 640px) 50vw, (max-width: 980px) 38vw, 22vw"
                  />
                  <Image
                    src="/assets/img/screens/menu.webp"
                    width={520}
                    height={1125}
                    alt=""
                    loading="lazy"
                    sizes="(max-width: 640px) 50vw, (max-width: 980px) 38vw, 22vw"
                  />
                  <Image
                    src="/assets/img/screens/cart.webp"
                    width={520}
                    height={1125}
                    alt=""
                    loading="lazy"
                    sizes="(max-width: 640px) 50vw, (max-width: 980px) 38vw, 22vw"
                  />
                </div>
                <figcaption>Customer</figcaption>
              </figure>
            </div>
            <LiveTicket />
          </div>
        </div>
      </div>
    </section>
  );
}
