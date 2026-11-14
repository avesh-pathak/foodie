"use client";

import { useRef, useState, type KeyboardEvent } from "react";
import Image from "next/image";
import { AnimatePresence, motion, useReducedMotion } from "motion/react";
import { apps } from "@/lib/site";
import { GalleryFilterLink } from "@/components/gallery-filter-link";

const marks = {
  customer: "/assets/brand/foodie-mark.svg",
  admin: "/assets/brand/foodie-admin-logo.png",
  kitchen: "/assets/brand/foodie-admin-logo.png",
} as const;

export function AppsTabs() {
  const [activeId, setActiveId] = useState(apps[0].id);
  const tabsRef = useRef<Array<HTMLButtonElement | null>>([]);
  const reduce = useReducedMotion();
  const active = apps.find((app) => app.id === activeId) ?? apps[0];

  const activate = (id: (typeof apps)[number]["id"], focus = false) => {
    setActiveId(id);
    if (focus) {
      const index = apps.findIndex((app) => app.id === id);
      tabsRef.current[index]?.focus();
    }
  };

  const handleKey = (event: KeyboardEvent<HTMLButtonElement>, index: number) => {
    let next = index;
    if (event.key === "ArrowRight") next = (index + 1) % apps.length;
    else if (event.key === "ArrowLeft") next = (index - 1 + apps.length) % apps.length;
    else if (event.key === "Home") next = 0;
    else if (event.key === "End") next = apps.length - 1;
    else return;
    event.preventDefault();
    activate(apps[next].id, true);
  };

  return (
    <div className="app-tabs">
      <div className="app-tabs__list" role="tablist" aria-label="The three apps">
        {apps.map((app, index) => {
          const selected = app.id === activeId;
          return (
            <button
              className={`app-tab${selected ? " is-active" : ""}`}
              type="button"
              role="tab"
              id={`app-tab-${app.id}`}
              aria-selected={selected}
              aria-controls={`app-panel-${app.id}`}
              tabIndex={selected ? 0 : -1}
              key={app.id}
              ref={(node) => {
                tabsRef.current[index] = node;
              }}
              onClick={() => activate(app.id)}
              onKeyDown={(event) => handleKey(event, index)}
            >
              <img className="app-tab__mark" src={marks[app.id]} width={28} height={28} alt="" />
              <strong>{app.label}</strong>
            </button>
          );
        })}
      </div>

      <p className="app-tabs__note">
        Demo logins run the local Flutter build. There is no hosted demo.{" "}
        <a href="#build">See the run steps</a>.
      </p>

      <AnimatePresence mode="wait" initial={false}>
        <motion.div
          className="app-panel"
          role="tabpanel"
          id={`app-panel-${active.id}`}
          aria-labelledby={`app-tab-${active.id}`}
          key={active.id}
          initial={reduce ? false : { opacity: 0, y: 8 }}
          animate={reduce ? undefined : { opacity: 1, y: 0 }}
          exit={reduce ? undefined : { opacity: 0, y: -8 }}
          transition={{ duration: 0.22, ease: [0.22, 0.61, 0.36, 1] }}
        >
          <div className="app-panel__copy">
            <h3>{active.title}</h3>
            <p>{active.description}</p>
            <ul className="ticks">
              {active.bullets.map((bullet) => (
                <li key={bullet}>{bullet}</li>
              ))}
            </ul>
            <p className="demo-line">
              <span className="demo-badge">Demo</span>
              {active.demoKind === "credentials"
                ? active.demo.split(" / ").map((part, index) => (
                    <span key={part}>
                      {index > 0 ? " / " : null}
                      <code>{part}</code>
                    </span>
                  ))
                : active.demo}
            </p>
            <GalleryFilterLink filter={active.id}>{active.linkLabel}</GalleryFilterLink>
          </div>

          <div className="app-panel__visual">
            <figure className="still still--main">
              <Image
                src={active.main.src}
                width={active.main.width}
                height={active.main.height}
                alt={active.main.alt}
                sizes="(max-width: 420px) 68vw, (max-width: 980px) 64vw, 300px"
              />
            </figure>
            <figure className="still still--aside">
              <Image
                src={active.aside.src}
                width={active.aside.width}
                height={active.aside.height}
                alt={active.aside.alt}
                sizes="(max-width: 420px) 48vw, (max-width: 980px) 46vw, 218px"
              />
            </figure>
          </div>
        </motion.div>
      </AnimatePresence>
    </div>
  );
}
