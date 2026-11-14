import Image from "next/image";
import { Play, Plus } from "@phosphor-icons/react/dist/ssr";
import { transcript } from "@/lib/site";
import { VideoButton } from "@/components/video-provider";

export function Tour() {
  return (
    <section className="section tour" id="tour">
      <div className="container">
        <header className="section-head">
          <h2>Thirty seconds. No voiceover.</h2>
          <p className="lede">
            A silent tour of the three apps and the system behind them. The captions are burned in, so it
            reads with the sound off.
          </p>
        </header>

        <div className="tour__grid">
          <div className="tour__copy">
            <dl className="tour__specs">
              <div><dt>Format</dt><dd>1920 × 1080</dd></div>
              <div><dt>Length</dt><dd>30 seconds</dd></div>
              <div><dt>Sound</dt><dd>None</dd></div>
              <div><dt>Captions</dt><dd>Burned in</dd></div>
            </dl>
            <p className="tour__note">
              Composed in HTML, captured frame by frame with Playwright and encoded with ffmpeg. No screen
              recording.
            </p>
          </div>

          <div className="tour__player">
            <VideoButton className="poster" ariaLabel="Play the 30-second Foodie tour">
              <Image
                src="/assets/video/poster.jpg"
                width={1920}
                height={1080}
                alt="Poster for the Foodie tour, showing three phone screens on a warm paper stage"
                loading="lazy"
              />
              <span className="poster__play" aria-hidden="true">
                <Play className="icon" weight="fill" />
              </span>
            </VideoButton>
          </div>
        </div>

        <details className="fold fold--light transcript">
          <summary>
            Read the transcript
            <span className="fold__icon" aria-hidden="true"><Plus className="icon" weight="bold" /></span>
          </summary>
          <div className="transcript__body">
            {transcript.map(([time, line]) => (
              <p key={time}>
                <span>{time}</span>
                {line}
              </p>
            ))}
          </div>
        </details>
      </div>
    </section>
  );
}
