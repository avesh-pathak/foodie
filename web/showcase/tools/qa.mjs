import { existsSync, mkdirSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { chromium } from "playwright-core";

const base = process.env.QA_URL ?? "http://localhost:3000";
const out = join(process.cwd(), "tools", ".qa");
mkdirSync(out, { recursive: true });

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

const ids = ["top", "apps", "screens", "architecture", "tour", "build", "faq"];

async function prepare(page) {
  await page.goto(base, { waitUntil: "networkidle" });
  const height = await page.evaluate(() => document.body.scrollHeight);
  for (let y = 0; y < height; y += 650) {
    await page.evaluate((top) => window.scrollTo(0, top), y);
    await page.waitForTimeout(70);
  }
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.waitForTimeout(350);
  await page.evaluate(async () => {
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
}

async function inspect(page, label) {
  const metrics = await page.evaluate(() => ({
    width: window.innerWidth,
    scrollWidth: document.documentElement.scrollWidth,
    height: document.body.scrollHeight,
    brokenImages: Array.from(document.images)
      .filter((image) => !image.complete || image.naturalWidth === 0)
      .map((image) => image.currentSrc || image.src),
    missingAnchors: Array.from(document.querySelectorAll('a[href^="#"]'))
      .map((link) => link.getAttribute("href"))
      .filter((href) => href && href.length > 1 && !document.querySelector(href)),
    h1: document.querySelectorAll("h1").length,
    h2: Array.from(document.querySelectorAll("h2")).map((node) => node.textContent?.trim()),
  }));
  console.log(`\n[${label}]`, JSON.stringify(metrics, null, 2));
  return metrics;
}

async function sections(page, label) {
  for (const id of ids) {
    const top = await page.evaluate((sectionId) => {
      const element = document.getElementById(sectionId);
      if (!element) return null;
      return element.getBoundingClientRect().top + window.scrollY - 84;
    }, id);
    if (top == null) continue;
    await page.evaluate((value) => window.scrollTo(0, value), top);
    await page.waitForTimeout(220);
    await page.screenshot({ path: join(out, `${id}-${label}.png`) });
  }
  await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
  await page.waitForTimeout(250);
  await page.screenshot({ path: join(out, `footer-${label}.png`) });
}

const browser = await chromium.launch({ executablePath: findChromium() });
const errors = [];

try {
  for (const [label, width, height] of [
    ["desktop", 1440, 1000],
    ["tablet", 768, 1024],
    ["mobile", 390, 844],
  ]) {
    const page = await browser.newPage({ viewport: { width, height } });
    page.on("console", (message) => {
      if (message.type() === "error") errors.push(`[${label}] console: ${message.text()}`);
    });
    page.on("pageerror", (error) => errors.push(`[${label}] pageerror: ${error.message}`));
    page.on("requestfailed", (request) =>
      errors.push(`[${label}] failed: ${request.url()} ${request.failure()?.errorText ?? ""}`)
    );
    page.on("response", (response) => {
      if (response.status() >= 400) errors.push(`[${label}] http ${response.status()}: ${response.url()}`);
    });

    await prepare(page);
    await inspect(page, label);
    await sections(page, label);
    await page.screenshot({ path: join(out, `full-${label}.png`), fullPage: true });
    await page.close();
  }
} finally {
  await browser.close();
}

console.log("\nErrors:", errors.length ? errors : "none");
