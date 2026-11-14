import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { extname, join, relative, resolve, sep } from "node:path";

// Verifies that every /assets/... path the site references exists in public/.
// Run before a deploy, or after deleting generated media: npm run check:assets

const TOOLS = resolve(import.meta.dirname);
const SHOWCASE = resolve(TOOLS, "..");
const PUBLIC = join(SHOWCASE, "public");
const SKIP = new Set(["node_modules", ".next", "out", ".git", "tools"]);
const EXTENSIONS = new Set([".ts", ".tsx", ".js", ".mjs", ".css", ".html", ".json"]);

function walk(directory) {
  const files = [];
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    if (entry.isDirectory()) {
      if (SKIP.has(entry.name)) continue;
      files.push(...walk(join(directory, entry.name)));
    } else if (EXTENSIONS.has(extname(entry.name))) {
      files.push(join(directory, entry.name));
    }
  }
  return files;
}

const files = [...walk(join(SHOWCASE, "app")), ...walk(join(SHOWCASE, "components")), ...walk(join(SHOWCASE, "lib")), ...walk(join(SHOWCASE, "public"))];
const references = new Map();

for (const file of files) {
  const source = readFileSync(file, "utf8");
  for (const match of source.matchAll(/["'(](\/assets\/[^"')\s]+)["')]/g)) {
    const url = match[1];
    if (!references.has(url)) references.set(url, new Set());
    references.get(url).add(relative(SHOWCASE, file).split(sep).join("/"));
  }
}

const missing = [];
for (const [url, sources] of references) {
  const file = join(PUBLIC, url.replace(/^\/+/, ""));
  if (!existsSync(file) || !statSync(file).isFile()) {
    missing.push({ url, sources: [...sources] });
  }
}

const screens = readFileSync(join(TOOLS, "screens.json"), "utf8");
const screenShots = [...screens.matchAll(/"(\/assets\/img\/screens\/[^"]+)"/g)].map((match) => match[1]);
for (const url of screenShots) {
  if (!references.has(url)) references.set(url, new Set(["tools/screens.json"]));
  if (!existsSync(join(PUBLIC, url.replace(/^\/+/, "")))) missing.push({ url, sources: ["tools/screens.json"] });
}

if (missing.length) {
  console.error(`Missing ${missing.length} referenced asset(s):`);
  for (const { url, sources } of missing) console.error(`  ${url}  <- ${sources.join(", ")}`);
  console.error("\nRebuild with: npm run assets && npm run og && npm run render");
  process.exit(1);
}

console.log(`OK: all ${references.size} referenced assets exist in public/ (${screenShots.length} screen entries).`);
