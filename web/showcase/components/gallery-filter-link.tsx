"use client";

import { ArrowRight } from "@phosphor-icons/react/dist/ssr";
import type { ReactNode } from "react";
import type { AppId } from "@/lib/screens";
import { useGalleryFilter } from "@/components/gallery-provider";

export function GalleryFilterLink({ filter, children }: { filter: AppId; children: ReactNode }) {
  const { setFilter } = useGalleryFilter();
  return (
    <a className="text-link" href="#screens" onClick={() => setFilter(filter)}>
      {children}
      <ArrowRight className="icon" weight="bold" aria-hidden="true" />
    </a>
  );
}
