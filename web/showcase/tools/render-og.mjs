import { execFileSync } from "node:child_process";
import { createServer } from "node:http";
import { existsSync, mkdirSync, readFileSync, readdirSync, rmSync, statSync } from "node:fs";
import { extname, join, normalize, resolve, sep } from "node:path";
import { dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright-core";

const TOOLS = dirname(fileURLToPath(import.meta.url));
const SHOWCASE = resolve(TOOLS, "..");
const OUTPUT = join(SHOWCASE, "public", "assets", "img", "og.png");
const TEMP = join(TOOLS, ".render", "og@2x.png");

const mime = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".webp": "image/webp",
  ".ttf": "font/ttf",
};

function findChromium() {
  const candidates = [];
  const bundled = chromium.executablePath();
  if (bundled && existsSync(bundled)) candidates.push(bundled);
  const root = join(process.env.LOCALAPPDATA ?? "", "ms-playwright");
  if (existsSync(root)) {
    for (const name of readdirSync(root)) {
      if (!name.startsWith("chromium-")) continue;
      for (const variant of ["chrome-win64/chrome.exe", "chrome-win/chrome.exe", "chrome-linux/chrome"]) {
        const candidate = join(root, name, variant);
        if (existsSync(candidate)) candidates.push(candidate);
      }
    }
  }
  if (candidates.length) return candidates.sort().reverse()[0];
  throw new Error("No Chromium executable found.");
}

function startServer(root) {
  const server = createServer((request, response) => {
    const url = decodeURIComponent((request.url ?? "/").split("?")[0]);
    const relative = normalize(url.replace(/^\/+/, ""));
    const file = join(root, relative);
    if (!file.startsWith(root + sep) || !existsSync(file) || statSync(file).isDirectory()) {
      response.writeHead(404).end("Not found");
      return;
    }
    response.writeHead(200, { "Content-Type": mime[extname(file)] ?? "application/octet-stream" });
    response.end(readFileSync(file));
  });

  return new Promise((resolveStart) => {
    server.listen(0, "127.0.0.1", () => {
      const address = server.address();
      resolveStart({ server, port: typeof address === "object" && address ? address.port : 0 });
    });
  });
}

async function main() {
  mkdirSync(dirname(OUTPUT), { recursive: true });
  mkdirSync(dirname(TEMP), { recursive: true });

  const { server, port } = await startServer(SHOWCASE);
  const browser = await chromium.launch({ executablePath: findChromium() });

  try {
    const page = await browser.newPage({
      viewport: { width: 1200, height: 630 },
      deviceScaleFactor: 2,
    });
    await page.goto(`http://127.0.0.1:${port}/tools/og.html`, { waitUntil: "networkidle" });
    await page.evaluate(async () => {
      await document.fonts.ready;
      await Promise.all(
        Array.from(document.images).map((image) =>
          image.complete
            ? Promise.resolve()
            : new Promise((done) => {
                image.addEventListener("load", done, { once: true });
                image.addEventListener("error", done, { once: true });
              })
        )
      );
    });
    await page.screenshot({ path: TEMP, type: "png" });
  } finally {
    await browser.close();
    server.close();
  }

  execFileSync(
    "ffmpeg",
    ["-y", "-hide_banner", "-loglevel", "error", "-i", TEMP, "-vf", "scale=1200:630", "-frames:v", "1", OUTPUT],
    { stdio: "inherit" }
  );
  rmSync(dirname(TEMP), { recursive: true, force: true });
  process.stdout.write(`wrote ${OUTPUT}\n`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
