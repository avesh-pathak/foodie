"use client";

import { createContext, useContext, useState, type ReactNode } from "react";
import type { AppId } from "@/lib/screens";

export type GalleryFilter = "all" | AppId;

type GalleryContextValue = {
  filter: GalleryFilter;
  setFilter: (filter: GalleryFilter) => void;
};

const GalleryContext = createContext<GalleryContextValue | null>(null);

export function useGalleryFilter() {
  const context = useContext(GalleryContext);
  if (!context) throw new Error("useGalleryFilter must be used inside GalleryFilterProvider");
  return context;
}

export function GalleryFilterProvider({ children }: { children: ReactNode }) {
  const [filter, setFilter] = useState<GalleryFilter>("all");
  return <GalleryContext.Provider value={{ filter, setFilter }}>{children}</GalleryContext.Provider>;
}
