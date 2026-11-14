"use client";

import { useEffect, useRef, useState } from "react";
import { Check, Copy, WarningCircle } from "@phosphor-icons/react/dist/ssr";

type CopyState = "idle" | "copied" | "error";

export function CopyButton({ text, label = "Copy" }: { text: string; label?: string }) {
  const [state, setState] = useState<CopyState>("idle");
  const timerRef = useRef<number | null>(null);

  useEffect(() => {
    return () => {
      if (timerRef.current) window.clearTimeout(timerRef.current);
    };
  }, []);

  const reset = () => {
    if (timerRef.current) window.clearTimeout(timerRef.current);
    timerRef.current = window.setTimeout(() => setState("idle"), 1800);
  };

  const fallbackCopy = (value: string) => {
    const textarea = document.createElement("textarea");
    textarea.value = value;
    textarea.setAttribute("readonly", "");
    textarea.style.position = "fixed";
    textarea.style.opacity = "0";
    document.body.appendChild(textarea);
    textarea.select();
    let ok = false;
    try {
      ok = document.execCommand("copy");
    } catch {
      ok = false;
    }
    textarea.remove();
    return ok;
  };

  const copy = async () => {
    let ok = false;
    try {
      if (!navigator.clipboard) throw new Error("Clipboard unavailable");
      await navigator.clipboard.writeText(text);
      ok = true;
    } catch {
      ok = fallbackCopy(text);
    }
    setState(ok ? "copied" : "error");
    reset();
  };

  return (
    <button
      className={`copy${state === "copied" ? " is-copied" : ""}${state === "error" ? " is-error" : ""}`}
      type="button"
      aria-label={state === "error" ? "Copy failed" : label}
      onClick={copy}
    >
      {state === "copied" ? (
        <Check className="icon" weight="bold" aria-hidden="true" />
      ) : state === "error" ? (
        <WarningCircle className="icon" weight="bold" aria-hidden="true" />
      ) : (
        <Copy className="icon" weight="bold" aria-hidden="true" />
      )}
      <span>{state === "copied" ? "Copied" : state === "error" ? "Copy failed" : label}</span>
      <span className="sr-only" aria-live="polite">
        {state === "copied" ? "Copied to clipboard." : state === "error" ? "Copy failed. Select the text and copy it manually." : ""}
      </span>
    </button>
  );
}
