import Link from "next/link";
import { ArrowRight } from "@phosphor-icons/react/dist/ssr";
import { commands, credentials, reviewFiles, site } from "@/lib/site";
import { CopyButton } from "@/components/copy-button";
import { AndroidLogo, ArrowUpRight, HardDrives, Stack } from "@phosphor-icons/react/dist/ssr";

const reviewMark = (path: string) => {
  if (path.startsWith("lib/")) return "customer";
  if (path.startsWith("HardDrives/")) return "api";
  return "shared";
};

const tree = `foodie/
├─ lib/                 customer app
├─ admin/               admin app
├─ kitchen/             kitchen app
├─ packages/
│  └─ foodie_core/      shared models + client
├─ HardDrives/              Hono + Drizzle
│  ├─ src/routes/       28 REST routes
│  └─ src/realtime.ts   Neon → SSE
├─ docs/screenshots/    all captures
└─ web/                 this page`;

export function Build() {
  return (
    <section className="section build" id="build">
      <div className="container">
        <header className="section-head">
          <h2>The parts, and how to run them.</h2>
          <p className="lede">
            The customer app runs on bundled demo data and syncs when the API is reachable. Admin and kitchen
            need the API and Neon. Everything else is a Flutter app with a README and a demo login.
          </p>
        </header>

        <div className="build__grid">
          <div className="repo-card">
            <div className="repo-card__head">
              <span>Repository</span>
              <span>4 Flutter targets, 1 API</span>
            </div>
            <pre className="tree"><code>{tree}</code></pre>
            <div className="repo-card__foot">
              <span>Flutter 3.50+, Dart 3.14+</span>
              <span>Node + Neon</span>
            </div>
          </div>

          <div className="run">
            <div className="run-step">
              <h3><span>1</span> Start the API</h3>
              <div className="code">
                <pre tabIndex={0} aria-label="API commands"><code>{commands.api}</code></pre>
                <CopyButton text={commands.api} label="Copy" />
              </div>
            </div>

            <div className="run-step">
              <h3><span>2</span> Run a Flutter app</h3>
              <div className="code">
                <pre tabIndex={0} aria-label="Flutter commands"><code>{commands.flutter}</code></pre>
                <CopyButton text={commands.flutter} label="Copy" />
              </div>
              <p className="run-note">
                Android emulators reach the host at <code>10.0.2.2:3001</code>; web uses{" "}
                <code>localhost:3001</code>. Override the base URL with a Dart define if your host differs.
              </p>
            </div>

            <div className="run-step">
              <h3><span>3</span> Sign in</h3>
              <div className="table-wrap">
                <table>
                  <caption className="sr-only">Demo credentials for each app</caption>
                  <thead>
                    <tr><th scope="col">App</th><th scope="col">Credentials</th></tr>
                  </thead>
                  <tbody>
                    {credentials.map(([app, value]) => (
                      <tr key={app}>
                        <th scope="row">
                          <span className="credential-app">
                            <img
                              src={app === "Customer" ? "/assets/brand/foodie-mark.svg" : "/assets/brand/foodie-admin-logo.png"}
                              width={18}
                              height={18}
                              alt=""
                            />
                            {app}
                          </span>
                        </th>
                        <td>{value}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

        <div className="build-notes">
          <div>
            <p className="build-notes__label">Where to look in a review</p>
            <ul className="file-list">
              {reviewFiles.map(([path, description]) => {
                const tone = reviewMark(path);
                return (
                  <li key={path}>
                    <span className={`file-list__mark file-list__mark--${tone}`}>
                      {tone === "customer" ? (
                        <img src="/assets/brand/foodie-mark.svg" width={18} height={18} alt="" />
                      ) : tone === "api" ? (
                        <HardDrives className="icon" weight="bold" aria-hidden="true" />
                      ) : (
                        <Stack className="icon" weight="bold" aria-hidden="true" />
                      )}
                    </span>
                    <div>
                      <code>{path}</code>
                      <span>{description}</span>
                    </div>
                  </li>
                );
              })}
            </ul>
          </div>
          <div>
            <p className="build-notes__label build-notes__label--apk">
              <AndroidLogo className="icon" weight="fill" aria-hidden="true" />
              Build an Android APK
            </p>
            <div className="code code--dark">
              <pre tabIndex={0} aria-label="APK build command"><code>{commands.apk}</code></pre>
              <CopyButton text={commands.apk} label="Copy" />
            </div>
            <p className="build-notes__note">
              Release mode, debug-signed. The repo README&apos;s <code>dist/</code> APKs are not present in
              this checkout, so this page does not link a download.
            </p>
          </div>
        </div>

        <div className="verify">
          <div>
            <p className="build-notes__label">Source and demo</p>
            <p className="verify__copy">
              The Flutter and Next.js source is on GitHub. Browse the repo or browse the full capture set.
            </p>
          </div>
          <div className="verify__actions">
            <a className="btn btn--primary" href={site.repo} target="_blank" rel="noreferrer">
              Visit the repo <ArrowUpRight className="icon" weight="bold" aria-hidden="true" />
            </a>
            <Link className="btn btn--ghost" href="/screens">
              See all 30 screens <ArrowRight className="icon" weight="bold" aria-hidden="true" />
            </Link>
          </div>
        </div>
      </div>
    </section>
  );
}
