"use client";

import Image from "next/image";
import Link from "next/link";
import { useEffect, useMemo, useRef, useState, type KeyboardEvent } from "react";
import {
  ArrowRight,
  CaretLeft,
  CaretRight,
  MagnifyingGlassMinus,
  MagnifyingGlassPlus,
  X,
} from "@phosphor-icons/react/dist/ssr";
import {
  allScreenCounts,
  appNames,
  featuredScreens,
  screens,
  screenCounts,
  screenHeight,
  type AppId,
  type Screen,
} from "@/lib/screens";
import { useGalleryFilter, type GalleryFilter } from "@/components/gallery-provider";

export function ScreensGallery({ all = false }: { all?: boolean }) {
  const { filter, setFilter } = useGalleryFilter();
  const [selected, setSelected] = useState<Screen | null>(null);
  const [zoomed, setZoomed] = useState(false);
  const dialogRef = useRef<HTMLDialogElement>(null);
  const stageRef = useRef<HTMLDivElement>(null);
  const returnFocusRef = useRef<HTMLElement | null>(null);
  const touchStartRef = useRef<number | null>(null);
  const items = all ? screens : featuredScreens;
  const counts = all ? allScreenCounts : screenCounts;
  const filters: { id: GalleryFilter; label: string; count: number }[] = [
    { id: "all", label: "All", count: counts.all },
    { id: "customer", label: "Customer", count: counts.customer },
    { id: "admin", label: "Admin", count: counts.admin },
    { id: "kitchen", label: "Kitchen", count: counts.kitchen },
  ];

  const visible = useMemo(
    () => items.filter((screen) => filter === "all" || screen.app === filter),
    [filter, items]
  );

  const selectedIndex = selected ? visible.findIndex((screen) => screen.slug === selected.slug) : -1;

  useEffect(() => {
    setSelected(null);
  }, [filter]);

  useEffect(() => {
    const dialog = dialogRef.current;
    if (!dialog) return;

    if (selected) {
      document.documentElement.classList.add("dialog-open");
      if (!dialog.open) dialog.showModal();
      window.requestAnimationFrame(() => {
        dialog.querySelector<HTMLButtonElement>("[data-lightbox-close]")?.focus();
      });
      return;
    }

    if (dialog.open) dialog.close();
  }, [selected]);

  useEffect(() => {
    const dialog = dialogRef.current;
    if (!dialog) return;

    const handleClose = () => {
      setSelected(null);
      setZoomed(false);
      document.documentElement.classList.remove("dialog-open");
      returnFocusRef.current?.focus();
    };

    const handleClick = (event: MouseEvent) => {
      if (event.target === dialog) dialog.close();
    };

    dialog.addEventListener("close", handleClose);
    dialog.addEventListener("click", handleClick);

    return () => {
      dialog.removeEventListener("close", handleClose);
      dialog.removeEventListener("click", handleClick);
      document.documentElement.classList.remove("dialog-open");
    };
  }, []);

  useEffect(() => {
    if (!zoomed) return;
    const stage = stageRef.current;
    if (!stage) return;
    window.requestAnimationFrame(() => {
      stage.scrollTop = (stage.scrollHeight - stage.clientHeight) / 2;
      stage.scrollLeft = (stage.scrollWidth - stage.clientWidth) / 2;
    });
  }, [zoomed, selected]);

  const openScreen = (screen: Screen) => {
    if (document.activeElement instanceof HTMLElement) {
      returnFocusRef.current = document.activeElement;
    }
    setZoomed(false);
    setSelected(screen);
  };

  const step = (direction: number) => {
    if (!visible.length || selectedIndex < 0) return;
    const next = visible[(selectedIndex + direction + visible.length) % visible.length];
    setZoomed(false);
    setSelected(next);
    stageRef.current?.scrollTo({ top: 0, left: 0 });
  };

  const handleDialogKey = (event: KeyboardEvent<HTMLDialogElement>) => {
    if (event.key === "ArrowRight") {
      event.preventDefault();
      step(1);
    } else if (event.key === "ArrowLeft") {
      event.preventDefault();
      step(-1);
    } else if (event.key === "+" || event.key === "=") {
      event.preventDefault();
      setZoomed(true);
    } else if (event.key === "-" || event.key === "_") {
      event.preventDefault();
      setZoomed(false);
    } else if (event.key === "0") {
      setZoomed(false);
    }
  };

  return (
    <>
      <div className="gallery-head">
        <div className="filters" role="group" aria-label="Filter screens by app">
          {filters.map((item) => (
            <button
              className={`filter${filter === item.id ? " is-active" : ""}`}
              type="button"
              key={item.id}
              aria-pressed={filter === item.id}
              onClick={() => setFilter(item.id)}
            >
              {item.label} <span>{item.count}</span>
            </button>
          ))}
        </div>
        <p className="gallery-count" aria-live="polite">
          Showing {visible.length} of {items.length} screens
        </p>
      </div>

      <div className="gallery" aria-label={all ? "All Foodie screens" : "Selected Foodie screens"}>
        {visible.map((screen) => (
          <figure className="shot" key={screen.slug}>
            <button
              className="shot__open"
              type="button"
              aria-label={`Zoom into ${screen.title}`}
              onClick={() => openScreen(screen)}
            >
              <Image
                src={screen.thumb}
                width={520}
                height={screenHeight(screen.app)}
                alt={screen.alt}
                loading="lazy"
                sizes="(max-width: 640px) 45vw, (max-width: 980px) 30vw, 18vw"
              />
              <span className="shot__zoom" aria-hidden="true">
                <MagnifyingGlassPlus className="icon" weight="bold" />
              </span>
            </button>
            <figcaption>
              <span>{appNames[screen.app]}</span>
              {screen.title}
            </figcaption>
          </figure>
        ))}
      </div>

      {!all ? (
        <p className="gallery-all">
          <Link className="text-link" href="/screens">
            See all 30 captures <ArrowRight className="icon" weight="bold" aria-hidden="true" />
          </Link>
        </p>
      ) : null}

      <dialog
        className="lightbox"
        id="lightbox"
        aria-labelledby="lightbox-title"
        data-lenis-prevent
        ref={dialogRef}
        onKeyDown={handleDialogKey}
      >
        {selected ? (
          <>
            <div className="lightbox__bar">
              <div>
                <p className="lightbox__app">{appNames[selected.app]}</p>
                <h2 className="lightbox__title" id="lightbox-title">
                  {selected.title}
                </h2>
              </div>
              <div className="lightbox__tools">
                <span className="lightbox__count">
                  {selectedIndex + 1} / {visible.length}
                </span>
                <button
                  className="icon-btn"
                  type="button"
                  data-lightbox-zoom
                  aria-pressed={zoomed}
                  aria-label={zoomed ? "Zoom out" : "Zoom in"}
                  onClick={() => setZoomed((value) => !value)}
                >
                  {zoomed ? (
                    <MagnifyingGlassMinus className="icon" weight="bold" aria-hidden="true" />
                  ) : (
                    <MagnifyingGlassPlus className="icon" weight="bold" aria-hidden="true" />
                  )}
                </button>
                <button
                  className="icon-btn"
                  type="button"
                  data-lightbox-close
                  aria-label="Close the screen viewer"
                  onClick={() => dialogRef.current?.close()}
                >
                  <X className="icon" weight="bold" aria-hidden="true" />
                </button>
              </div>
            </div>
            <div
              className={`lightbox__stage${zoomed ? " is-zoomed" : ""}`}
              ref={stageRef}
              onTouchStart={(event) => {
                touchStartRef.current = event.touches[0]?.clientX ?? null;
              }}
              onTouchEnd={(event) => {
                const start = touchStartRef.current;
                touchStartRef.current = null;
                const end = event.changedTouches[0]?.clientX;
                if (start == null || end == null) return;
                if (Math.abs(end - start) > 44) step(end < start ? 1 : -1);
              }}
            >
              <button
                className="lightbox__nav lightbox__nav--prev"
                type="button"
                data-lightbox-prev
                aria-label="Previous screen"
                onClick={() => step(-1)}
              >
                <CaretLeft className="icon" weight="bold" aria-hidden="true" />
              </button>
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                key={selected.slug}
                src={selected.full}
                alt={selected.alt}
                decoding="async"
                onClick={() => setZoomed((value) => !value)}
              />
              <button
                className="lightbox__nav lightbox__nav--next"
                type="button"
                data-lightbox-next
                aria-label="Next screen"
                onClick={() => step(1)}
              >
                <CaretRight className="icon" weight="bold" aria-hidden="true" />
              </button>
            </div>
            <div className="lightbox__foot">
              <p>{selected.caption}</p>
              <p className="lightbox__hint">← → or swipe to move. + / − to zoom. Esc to close.</p>
            </div>
          </>
        ) : null}
      </dialog>
    </>
  );
}
