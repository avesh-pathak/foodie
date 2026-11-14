"use client";

import { usePathname } from "next/navigation";
import { ArrowUpRight, GithubLogo } from "@phosphor-icons/react/dist/ssr";
import { site } from "@/lib/site";

export function Footer() {
  const pathname = usePathname();
  const homeHref = (href: string) => (pathname === "/" ? href : `/${href}`);

  return (
    <footer className="footer">
      <div className="container">
        <div className="footer__top">
          <div>
            <img className="footer__mark" src="/assets/brand/foodie-mark.svg" width={64} height={64} alt="" />
            <p className="footer__word">Foodie</p>
            <p className="footer__line">
              A restaurant-ordering build with Flutter, Hono and Neon. Source and setup notes are on GitHub.
            </p>
          </div>
          <a className="btn btn--cream" href={site.repo} target="_blank" rel="noreferrer">
            <GithubLogo className="icon" weight="bold" aria-hidden="true" />
            Visit the GitHub repository
          </a>
        </div>

        <div className="footer__grid">
          <div>
            <p className="footer__label">Explore</p>
            <a href={homeHref("#apps")}>Apps</a>
            <a href={homeHref("#screens")}>Screens</a>
            <a href="/screens">All screens</a>
            <a href={homeHref("#architecture")}>Architecture</a>
            <a href={homeHref("#tour")}>Tour</a>
            <a href={homeHref("#build")}>Build</a>
            <a href={homeHref("#faq")}>FAQ</a>
          </div>
          <div>
            <p className="footer__label">Stack</p>
            <span>Flutter, Dart</span>
            <span>Hono, Node</span>
            <span>Drizzle, Postgres</span>
            <span>Neon Realtime</span>
            <span>Neon Object Storage</span>
          </div>
          <div>
            <p className="footer__label">Contact</p>
            <a href={`mailto:${site.email}`}>{site.email}</a>
            <a href={site.repo} target="_blank" rel="noreferrer">
              Visit the repo <ArrowUpRight className="icon icon--xs" weight="bold" aria-hidden="true" />
            </a>
            <a href={site.portfolio} target="_blank" rel="noreferrer">
              avesh.tech <ArrowUpRight className="icon icon--xs" weight="bold" aria-hidden="true" />
            </a>
            <a href={site.linkedin} target="_blank" rel="noreferrer">
              LinkedIn <ArrowUpRight className="icon icon--xs" weight="bold" aria-hidden="true" />
            </a>
          </div>
        </div>

        <div className="footer__legal">
          <p>
            Demo build. Payments, coupons, tracking and support chat are simulated. Not affiliated with any
            restaurant brand.
          </p>
          <p>© {new Date().getFullYear()} Avesh Pathak</p>
        </div>
      </div>
    </footer>
  );
}
