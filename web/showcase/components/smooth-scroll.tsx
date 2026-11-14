"use client";

import { useEffect } from "react";
import Lenis from "lenis";

export function SmoothScroll() {
  useEffect(() => {
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (reduce) return;

    const lenis = new Lenis({
      autoRaf: true,
      autoToggle: true,
      anchors: { offset: -88 },
      lerp: 0.1,
      smoothWheel: true,
      stopInertiaOnNavigate: true,
      respectReducedMotion: true,
    });

    const syncLock = () => {
      if (document.documentElement.classList.contains("dialog-open")) lenis.stop();
      else lenis.start();
    };

    syncLock();
    const observer = new MutationObserver(syncLock);
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ["class"] });

    return () => {
      observer.disconnect();
      lenis.destroy();
    };
  }, []);

  return null;
}
