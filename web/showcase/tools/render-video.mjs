import { execFileSync } from "node:child_process";
import { createServer } from "node:http";
import { existsSync, mkdirSync, readFileSync, readdirSync, rmSync, statSync } from "node:fs";
import { extname, join, normalize, resolve, sep } from "node:path";
import { dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright-core";

const TOOLS = dirname(fileURLToPath(import.meta.url));
const SHOWCASE = resolve(TOOLS, "..");
const PUBLIC = join(SHOWCASE, "public");
const FRAMES = join(TOOLS, "frames");
const OUTPUT = join(PUBLIC, "assets", "video", "foodie-tour.mp4");
const POSTER = join(PUBLIC, "assets", "video", "poster.jpg");
const FPS = 30;
const SECONDS = 30;
const WIDTH = 1920;
const HEIGHT = 1080;

const mime = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".webp": "image/webp",
  ".ttf": "font/ttf",
  ".mp4": "video/mp4",
};

function findChromium() {
  if (process.env.PLAYWRIGHT_CHROMIUM_PATH && existsSync(process.env.PLAYWRIGHT_CHROMIUM_PATH)) {
    return process.env.PLAYWRIGHT_CHROMIUM_PATH;
  }

  const bundled = chromium.executablePath();
  if (bundled && existsSync(bundled)) return bundled;

  const root = join(process.env.LOCALAPPDATA ?? "", "ms-playwright");
  if (existsSync(root)) {
    const candidates = [];
    for (const name of readdirSync(root)) {
      if (!name.startsWith("chromium-")) continue;
      for (const variant of ["chrome-win64/chrome.exe", "chrome-win/chrome.exe", "chrome-linux/chrome"]) {
        const candidate = join(root, name, variant);
        if (existsSync(candidate)) candidates.push(candidate);
      }
    }
    if (candidates.length) {
      candidates.sort().reverse();
      return candidates[0];
    }
  }

  throw new Error("No Chromium executable found. Run `npx playwright install chromium` or set PLAYWRIGHT_CHROMIUM_PATH.");
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
  rmSync(FRAMES, { recursive: true, force: true });
  mkdirSync(FRAMES, { recursive: true });
  mkdirSync(join(PUBLIC, "assets", "video"), { recursive: true });

  const { server, port } = await startServer(PUBLIC);
  const browser = await chromium.launch({ executablePath: findChromium() });

  try {
    const page = await browser.newPage({
      viewport: { width: WIDTH, height: HEIGHT },
      deviceScaleFactor: 1,
    });

    await page.goto(`http://127.0.0.1:${port}/video/index.html`, { waitUntil: "networkidle" });
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

    const stage = await page.evaluate(() => ({
      width: document.getElementById("stage")?.getBoundingClientRect().width,
      height: document.getElementById("stage")?.getBoundingClientRect().height,
    }));
    if (stage.width !== WIDTH || stage.height !== HEIGHT) {
      throw new Error(`Stage is ${stage.width}×${stage.height}, expected ${WIDTH}×${HEIGHT}`);
    }

    await page.evaluate(() => {
      for (const animation of document.getAnimations()) animation.pause();
    });

    const totalFrames = FPS * SECONDS;
    for (let index = 0; index < totalFrames; index += 1) {
      const ms = (index / FPS) * 1000;
      await page.evaluate((time) => {
        for (const animation of document.getAnimations()) {
          animation.currentTime = time;
        }
      }, ms);
      await page.screenshot({
        path: join(FRAMES, `f${String(index).padStart(4, "0")}.png`),
        type: "png",
      });
      if (index % 150 === 0) process.stdout.write(`frame ${index}/${totalFrames}\n`);
    }

    await page.evaluate(() => {
      for (const animation of document.getAnimations()) animation.currentTime = 2400;
    });
    await page.screenshot({ path: POSTER, type: "jpeg", quality: 92 });

    process.stdout.write(`rendered ${totalFrames} frames\n`);
  } finally {
    await browser.close();
    server.close();
  }

  execFileSync(
    "ffmpeg",
    [
      "-y",
      "-hide_banner",
      "-loglevel",
      "error",
      "-framerate",
      String(FPS),
      "-i",
      join(FRAMES, "f%04d.png"),
      "-c:v",
      "libx264",
      "-preset",
      "slow",
      "-crf",
      "18",
      "-pix_fmt",
      "yuv420p",
      "-movflags",
      "+faststart",
      OUTPUT,
    ],
    { stdio: "inherit" }
  );

  process.stdout.write(`wrote ${OUTPUT}\nwrote ${POSTER}\n`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
