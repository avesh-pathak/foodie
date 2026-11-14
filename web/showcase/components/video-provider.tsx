"use client";

import {
  createContext,
  useContext,
  useEffect,
  useRef,
  useState,
  type ReactNode,
} from "react";
import { DownloadSimple, X } from "@phosphor-icons/react/dist/ssr";

type VideoContextValue = {
  openVideo: () => void;
};

const VideoContext = createContext<VideoContextValue | null>(null);

export function useVideo() {
  const context = useContext(VideoContext);
  if (!context) throw new Error("useVideo must be used inside VideoProvider");
  return context;
}

export function VideoProvider({ children }: { children: ReactNode }) {
  const dialogRef = useRef<HTMLDialogElement>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const returnFocusRef = useRef<HTMLElement | null>(null);
  const [open, setOpen] = useState(false);
  const [videoState, setVideoState] = useState<"loading" | "ready" | "error">("loading");

  const openVideo = () => {
    if (typeof document !== "undefined" && document.activeElement instanceof HTMLElement) {
      returnFocusRef.current = document.activeElement;
    }
    setVideoState("loading");
    setOpen(true);
  };

  useEffect(() => {
    const dialog = dialogRef.current;
    const video = videoRef.current;
    if (!dialog) return;

    if (open) {
      document.documentElement.classList.add("dialog-open");
      if (!dialog.open) dialog.showModal();
      const attempt = video?.play();
      if (attempt && typeof attempt.catch === "function") attempt.catch(() => {});
      return;
    }

    if (dialog.open) dialog.close();
  }, [open]);

  useEffect(() => {
    const dialog = dialogRef.current;
    const video = videoRef.current;
    if (!dialog) return;

    const handleClose = () => {
      setOpen(false);
      document.documentElement.classList.remove("dialog-open");
      if (video) {
        video.pause();
        video.currentTime = 0;
      }
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

  return (
    <VideoContext.Provider value={{ openVideo }}>
      {children}
      <dialog
        className="video-dialog"
        id="video-dialog"
        aria-labelledby="video-title"
        data-lenis-prevent
        ref={dialogRef}
      >
        <div className="video-dialog__bar">
          <div>
            <p className="video-dialog__kicker">Foodie tour</p>
            <h2 id="video-title">Three apps, thirty seconds</h2>
          </div>
          <button
            className="icon-btn icon-btn--light"
            type="button"
            aria-label="Close the tour"
            onClick={() => dialogRef.current?.close()}
          >
            <X className="icon" weight="bold" aria-hidden="true" />
          </button>
        </div>
        <div className="video-dialog__stage">
          <video
            id="tour-video"
            ref={videoRef}
            controls
            autoPlay
            muted
            playsInline
            preload="metadata"
            poster="/assets/video/poster.jpg"
            onCanPlay={() => setVideoState("ready")}
            onLoadedData={() => setVideoState("ready")}
            onPlaying={() => setVideoState("ready")}
            onError={() => setVideoState("error")}
          >
            <source src="/assets/video/foodie-tour.mp4" type="video/mp4" />
            <p>
              Your browser cannot play this video.{" "}
              <a href="/assets/video/foodie-tour.mp4">Download the MP4</a>.
            </p>
          </video>
          {videoState !== "ready" ? (
            <div
              className={`video-dialog__status${videoState === "error" ? " video-dialog__status--error" : ""}`}
              role="status"
              aria-live="polite"
            >
              {videoState === "error" ? (
                <p>
                  The tour could not load.{" "}
                  <a href="/assets/video/foodie-tour.mp4">Download the MP4</a>.
                </p>
              ) : (
                <p>Loading the tour…</p>
              )}
            </div>
          ) : null}
        </div>
        <div className="video-dialog__foot">
          <p>Silent, captioned. The transcript is on the page.</p>
          <a href="/assets/video/foodie-tour.mp4" download>
            <DownloadSimple className="icon icon--xs" weight="bold" aria-hidden="true" /> Download the MP4
          </a>
        </div>
      </dialog>
    </VideoContext.Provider>
  );
}

export function VideoButton({
  className = "btn btn--primary",
  ariaLabel,
  children,
}: {
  className?: string;
  ariaLabel?: string;
  children: ReactNode;
}) {
  const { openVideo } = useVideo();
  return (
    <button type="button" className={className} aria-label={ariaLabel} onClick={openVideo}>
      {children}
    </button>
  );
}
