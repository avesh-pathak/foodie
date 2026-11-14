import { existsSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { chromium } from "playwright-core";
import axe from "axe-core";

const base = process.env.QA_URL ?? "http://localhost:3000";

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
  return candidates.sort().reverse()[0];
}

const results = [];
const check = (name, pass, detail = "") => {
  results.push({ name, pass, detail });
  console.log(`${pass ? "PASS" : "FAIL"} ${name}${detail ? `: ${detail}` : ""}`);
};

const browser = await chromium.launch({ executablePath: findChromium() });

try {
  const context = await browser.newContext({
    viewport: { width: 1440, height: 1000 },
    permissions: ["clipboard-read", "clipboard-write"],
  });
  const page = await context.newPage();
  const errors = [];
  page.on("console", (message) => {
    if (message.type() === "error") errors.push(message.text());
  });
  page.on("pageerror", (error) => errors.push(error.message));

  await page.goto(base, { waitUntil: "networkidle" });
  await page.waitForTimeout(700);

  check("Lenis is active", await page.evaluate(() => document.documentElement.classList.contains("lenis")));
  check("One h1", (await page.locator("h1").count()) === 1);
  check("No section is wrongly active on the hero", (await page.locator(".nav [aria-current]").count()) === 0);
  check("Header tour action is present", await page.getByRole("button", { name: "Watch the 30-second Foodie tour" }).isVisible());
  await page.waitForTimeout(5200);
  check(
    "Demo ticket stops at out for delivery",
    (await page.locator(".ticket__status").innerText()).includes("Out for delivery")
  );

  // app tabs
  await page.getByRole("tab", { name: /Admin app/ }).click();
  await page.waitForTimeout(350);
  check(
    "App tab switches to admin",
    (await page.locator(".app-panel").innerText()).includes("Run the menu. Read the numbers.")
  );
  await page.getByRole("tab", { name: /Kitchen app/ }).click();
  await page.waitForTimeout(350);
  check(
    "App tab switches to kitchen",
    (await page.locator(".app-panel").innerText()).includes("Cook from the pass. Mark it ready.")
  );

  // gallery filter
  const filterGroup = page.locator(".filters");
  const allCards = await page.locator(".shot").count();
  check("Eight selected screens render", allCards === 8, String(allCards));
  await filterGroup.getByRole("button", { name: /Customer/ }).click();
  await page.waitForTimeout(250);
  check("Customer filter shows four screens", (await page.locator(".shot").count()) === 4);
  await filterGroup.getByRole("button", { name: /All/ }).click();
  await page.waitForTimeout(250);

  // gallery lightbox
  await page.locator(".shot__open").first().click();
  await page.waitForTimeout(350);
  check("Lightbox opens", await page.locator("#lightbox[open]").isVisible());
  const firstTitle = await page.locator("#lightbox-title").innerText();
  await page.locator("[data-lightbox-zoom]").click();
  check("Lightbox zoom toggles", await page.locator(".lightbox__stage").evaluate((node) => node.classList.contains("is-zoomed")));
  await page.locator("[data-lightbox-next]").click();
  await page.waitForTimeout(250);
  const nextTitle = await page.locator("#lightbox-title").innerText();
  check("Lightbox next changes the screen", firstTitle !== nextTitle, `${firstTitle} -> ${nextTitle}`);
  await page.keyboard.press("Escape");
  await page.waitForTimeout(250);
  check("Lightbox closes with Escape", !(await page.locator("#lightbox[open]").isVisible()));

  // video dialog
  await page.getByRole("button", { name: /Watch the 30s tour/ }).first().click();
  await page.waitForTimeout(1400);
  check("Video dialog opens", await page.locator("#video-dialog[open]").isVisible());
  check(
    "Video source is the rendered MP4",
    (await page.locator("#tour-video source").getAttribute("src")) === "/assets/video/foodie-tour.mp4"
  );
  const playback = await page.evaluate(() => {
    const video = document.querySelector("#tour-video");
    return { paused: video?.paused, time: video?.currentTime };
  });
  check("Tour autoplays muted", playback.paused === false && (playback.time ?? 0) > 0, JSON.stringify(playback));
  check("Tour loading overlay clears", (await page.locator(".video-dialog__status").count()) === 0);
  await page.keyboard.press("Escape");
  await page.waitForTimeout(350);
  check("Video dialog closes with Escape", !(await page.locator("#video-dialog[open]").isVisible()));

  check(
    "The main gallery links to all screens",
    (await page.locator('.gallery-all a[href="/screens"]').count()) === 1
  );

  // all screens route
  await page.goto(`${base}/screens`, { waitUntil: "networkidle" });
  check("All screens route renders 30 captures", (await page.locator(".shot").count()) === 30);
  check(
    "Screens nav is current on the all-screens page",
    (await page.locator('.nav a[aria-current="location"]').innerText()) === "Screens"
  );
  await page.goto(base, { waitUntil: "networkidle" });

  // copy button
  const copyButton = page.getByRole("button", { name: "Copy" }).first();
  await copyButton.click();
  await page.waitForTimeout(200);
  check("Copy button confirms", (await copyButton.innerText()).includes("Copied"));

  // anchors + horizontal overflow
  const pageHeight = await page.evaluate(() => document.body.scrollHeight);
  for (let y = 0; y < pageHeight; y += 650) {
    await page.evaluate((top) => window.scrollTo(0, top), y);
    await page.waitForTimeout(60);
  }
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.waitForTimeout(400);

  const metrics = await page.evaluate(() => ({
    scrollWidth: document.documentElement.scrollWidth,
    width: window.innerWidth,
    missingAnchors: Array.from(document.querySelectorAll('a[href^="#"]'))
      .map((link) => link.getAttribute("href"))
      .filter((href) => href && href.length > 1 && !document.querySelector(href)),
    brokenImages: Array.from(document.images)
      .filter((image) => !image.complete || image.naturalWidth === 0)
      .map((image) => image.currentSrc || image.src),
  }));
  check("No horizontal overflow", metrics.scrollWidth <= metrics.width, `${metrics.scrollWidth} / ${metrics.width}`);
  check("All anchors resolve", metrics.missingAnchors.length === 0, metrics.missingAnchors.join(", "));
  check("All images load", metrics.brokenImages.length === 0, metrics.brokenImages.join(", "));

  // axe
  await page.addScriptTag({ content: axe.source });
  const axeResult = await page.evaluate(async () => {
    return await window.axe.run(document, {
      runOnly: { type: "tag", values: ["wcag2a", "wcag2aa"] },
    });
  });
  const serious = axeResult.violations.filter((violation) => ["serious", "critical"].includes(violation.impact));
  check("No serious axe violations", serious.length === 0, serious.map((v) => v.id).join(", "));
  if (axeResult.violations.length) {
    console.log(
      JSON.stringify(
        axeResult.violations.map((violation) => ({
          id: violation.id,
          impact: violation.impact,
          help: violation.help,
          nodes: violation.nodes.map((node) => node.target.join(" ")),
        })),
        null,
        2
      )
    );
  }

  // mobile menu
  const mobile = await browser.newPage({ viewport: { width: 390, height: 844 } });
  await mobile.goto(base, { waitUntil: "networkidle" });
  await mobile.getByRole("button", { name: "Open menu" }).click();
  await mobile.waitForTimeout(250);
  check("Mobile menu opens", await mobile.locator("#mobile-nav").isVisible());
  await mobile.locator("#mobile-nav").getByRole("link", { name: "Screens" }).click();
  await mobile.waitForTimeout(400);
  check("Mobile menu closes after navigation", (await mobile.locator("#mobile-nav").count()) === 0);
  await mobile.close();

  // reduced motion
  const reduced = await browser.newContext({
    viewport: { width: 1440, height: 1000 },
    reducedMotion: "reduce",
  });
  const reducedPage = await reduced.newPage();
  await reducedPage.goto(base, { waitUntil: "networkidle" });
  await reducedPage.waitForTimeout(400);
  check(
    "Reduced motion disables Lenis",
    !(await reducedPage.evaluate(() => document.documentElement.classList.contains("lenis")))
  );
  await reduced.close();

  check("No console errors", errors.length === 0, errors.join(" | "));
} finally {
  await browser.close();
}

const failed = results.filter((result) => !result.pass);
console.log(`\n${results.length - failed.length}/${results.length} checks passed`);
if (failed.length) process.exitCode = 1;
