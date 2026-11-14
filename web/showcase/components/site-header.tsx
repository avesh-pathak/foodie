"use client";

import { useEffect, useRef, useState } from "react";
import { usePathname } from "next/navigation";
import { AnimatePresence, motion, useReducedMotion } from "motion/react";
import { GithubLogo, Globe, LinkedinLogo, List, Play, X } from "@phosphor-icons/react/dist/ssr";
import { site } from "@/lib/site";
import { useVideo } from "@/components/video-provider";

const sectionIds = site.nav.map((item) => item.href.slice(1));

export function SiteHeader() {
  const headerRef = useRef<HTMLElement>(null);
  const menuButtonRef = useRef<HTMLButtonElement>(null);
  const [scrolled, setScrolled] = useState(false);
  const [activeHref, setActiveHref] = useState<string | null>(null);
  const [menuOpen, setMenuOpen] = useState(false);
  const reduce = useReducedMotion();
  const pathname = usePathname();
  const { openVideo } = useVideo();
  const homeHref = (href: string) => (pathname === "/" ? href : `/${href}`);

  useEffect(() => {
    let frame = 0;

    const update = () => {
      frame = 0;
      setScrolled(window.scrollY > 8);

      const marker = window.scrollY + 140;
      let current: string | null = null;

      for (const id of sectionIds) {
        const section = document.getElementById(id);
        if (!section) continue;
        const top = section.getBoundingClientRect().top + window.scrollY;
        if (top <= marker) current = id;
      }

      setActiveHref(current ? `#${current}` : null);
    };

    const schedule = () => {
      if (frame) return;
      frame = window.requestAnimationFrame(update);
    };

    update();
    window.addEventListener("scroll", schedule, { passive: true });
    window.addEventListener("resize", schedule);

    return () => {
      if (frame) window.cancelAnimationFrame(frame);
      window.removeEventListener("scroll", schedule);
      window.removeEventListener("resize", schedule);
    };
  }, []);

  useEffect(() => {
    if (!menuOpen) return;
    const firstLink = headerRef.current?.querySelector<HTMLAnchorElement>(".mobile-nav a");
    firstLink?.focus();
  }, [menuOpen]);

  useEffect(() => {
    if (!menuOpen) return;

    const handleKey = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        setMenuOpen(false);
        menuButtonRef.current?.focus();
      }
    };

    const handleClick = (event: MouseEvent) => {
      if (headerRef.current && !headerRef.current.contains(event.target as Node)) {
        setMenuOpen(false);
      }
    };

    document.addEventListener("keydown", handleKey);
    document.addEventListener("click", handleClick);

    return () => {
      document.removeEventListener("keydown", handleKey);
      document.removeEventListener("click", handleClick);
    };
  }, [menuOpen]);

  useEffect(() => {
    const handleHashClick = (event: MouseEvent) => {
      const link = (event.target as HTMLElement).closest<HTMLAnchorElement>('a[href^="#"]');
      const id = link?.getAttribute("href")?.slice(1);
      if (!id) return;
      const target = document.getElementById(id);
      if (!target) return;
      target.setAttribute("tabindex", "-1");
      window.setTimeout(() => target.focus({ preventScroll: true }), 450);
    };

    document.addEventListener("click", handleHashClick);
    return () => document.removeEventListener("click", handleHashClick);
  }, []);

  useEffect(() => {
    const query = window.matchMedia("(min-width: 981px)");
    const handleChange = (event: MediaQueryListEvent) => {
      if (event.matches) setMenuOpen(false);
    };
    query.addEventListener("change", handleChange);
    return () => query.removeEventListener("change", handleChange);
  }, []);

  return (
    <header className={`site-header${scrolled ? " is-scrolled" : ""}${menuOpen ? " is-open" : ""}`} ref={headerRef}>
      <div className="container header__inner">
        <a className="brand" href={homeHref("#top")} aria-label="Foodie, back to top">
          <img className="brand__mark" src="/assets/brand/foodie-mark.svg" width={34} height={34} alt="" />
          <span className="brand__name">Foodie</span>
        </a>

        <nav className="nav" aria-label="Main navigation">
          {site.nav.map((item) => (
            <a
              key={item.href}
              href={homeHref(item.href)}
              aria-current={
                (pathname === "/screens" && item.href === "#screens") ||
                (pathname === "/" && activeHref === item.href)
                  ? "location"
                  : undefined
              }
            >
              {item.label}
            </a>
          ))}
        </nav>

        <div className="header__actions">
          <nav className="header__social" aria-label="Social and project links">
            <a
              className="header__social-link"
              href={site.repo}
              target="_blank"
              rel="noreferrer"
              aria-label="Foodie on GitHub"
            >
              <GithubLogo className="icon" weight="bold" aria-hidden="true" />
            </a>
            <a
              className="header__social-link"
              href={site.linkedin}
              target="_blank"
              rel="noreferrer"
              aria-label="Avesh Pathak on LinkedIn"
            >
              <LinkedinLogo className="icon" weight="bold" aria-hidden="true" />
            </a>
            <a
              className="header__social-link"
              href={site.portfolio}
              target="_blank"
              rel="noreferrer"
              aria-label="Avesh Pathak portfolio"
            >
              <Globe className="icon" weight="bold" aria-hidden="true" />
            </a>
          </nav>
          <button
            className="btn btn--primary btn--sm header__cta"
            type="button"
            aria-label="Watch the 30-second Foodie tour"
            onClick={openVideo}
          >
            <Play className="icon" weight="fill" aria-hidden="true" />
            Watch tour
          </button>
          <button
            className="menu-toggle"
            type="button"
            aria-expanded={menuOpen}
            aria-controls="mobile-nav"
            ref={menuButtonRef}
            onClick={() => setMenuOpen((value) => !value)}
          >
            <span className="sr-only">{menuOpen ? "Close menu" : "Open menu"}</span>
            {menuOpen ? (
              <X className="icon" weight="bold" aria-hidden="true" />
            ) : (
              <List className="icon" weight="bold" aria-hidden="true" />
            )}
          </button>
        </div>
      </div>

      <AnimatePresence>
        {menuOpen ? (
          <motion.div
            className="mobile-nav"
            id="mobile-nav"
            key="mobile-nav"
            initial={reduce ? false : { opacity: 0, y: -8 }}
            animate={reduce ? undefined : { opacity: 1, y: 0 }}
            exit={reduce ? undefined : { opacity: 0, y: -8 }}
            transition={{ duration: 0.18, ease: [0.22, 0.61, 0.36, 1] }}
          >
            <nav className="container" aria-label="Mobile navigation">
              {site.nav.map((item) => (
                <a key={item.href} href={homeHref(item.href)} onClick={() => setMenuOpen(false)}>
                  {item.label}
                </a>
              ))}
              <div className="mobile-nav__social">
                <a href={site.repo} target="_blank" rel="noreferrer" aria-label="Foodie on GitHub">
                  <GithubLogo className="icon" weight="bold" aria-hidden="true" />
                </a>
                <a href={site.linkedin} target="_blank" rel="noreferrer" aria-label="Avesh Pathak on LinkedIn">
                  <LinkedinLogo className="icon" weight="bold" aria-hidden="true" />
                </a>
                <a href={site.portfolio} target="_blank" rel="noreferrer" aria-label="Avesh Pathak portfolio">
                  <Globe className="icon" weight="bold" aria-hidden="true" />
                </a>
              </div>
            </nav>
          </motion.div>
        ) : null}
      </AnimatePresence>
    </header>
  );
}
