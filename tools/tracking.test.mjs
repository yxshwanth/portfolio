// Runs the real assets/read.js against a fake DOM and drives synthetic scrolling.
// node tools/read-depth.test.mjs
import { readFileSync } from "node:fs";
import { createContext, runInContext } from "node:vm";
import assert from "node:assert/strict";

function load({ articleTop = 254, articleHeight = 4627, viewport = 900 } = {}) {
  const beacons = [];
  const listeners = { win: {}, doc: {} };
  let scroll = 0;

  const doc = {
    visibilityState: "visible",
    addEventListener: (t, f) => ((listeners.doc[t] ??= []).push(f)),
    querySelector: () => ({
      getBoundingClientRect: () => ({ top: articleTop - scroll, height: articleHeight })
    })
  };
  const ctx = {
    document: doc,
    location: { pathname: "/blog/test/" },
    innerHeight: viewport,
    navigator: { sendBeacon: (u, d) => (beacons.push({ u, ...JSON.parse(d) }), true) },
    crypto: { randomUUID: () => "11111111-2222-3333-4444-555555555555" },
    addEventListener: (t, f) => ((listeners.win[t] ??= []).push(f)),
    Date, Math, JSON
  };
  ctx.window = ctx;
  runInContext(readFileSync(new URL("../assets/read.js", import.meta.url), "utf8"), createContext(ctx));

  return {
    beacons,
    scrollTo(y) { scroll = y; listeners.win.scroll.forEach(f => f()); },
    leave() { doc.visibilityState = "hidden"; listeners.doc.visibilitychange.forEach(f => f()); }
  };
}

// A reader who scrolls the whole way down reports 100, monotonically.
{
  const p = load();
  const seen = [];
  for (const y of [0, 500, 1990, 3000, 3981]) { p.scrollTo(y); p.leave(); seen.push(p.beacons.at(-1).pct); }
  assert.deepEqual(seen, [...seen].sort((a, b) => a - b), `not monotonic: ${seen}`);
  assert.equal(seen.at(-1), 100, `bottom of article should be 100, got ${seen.at(-1)}`);
  assert.ok(seen[0] > 0 && seen[0] < 30, `above-the-fold should be a small slice, got ${seen[0]}`);
}

// Scrolling back up must not lower the recorded depth, or re-send.
{
  const p = load();
  p.scrollTo(3981); p.leave();
  const n = p.beacons.length;
  p.scrollTo(0); p.leave();
  assert.equal(p.beacons.length, n, "scrolling back up re-sent a beacon");
  assert.equal(p.beacons.at(-1).pct, 100, "scrolling back up lowered the depth");
}

// Never out of range, even scrolled far past the end.
{
  const p = load();
  p.scrollTo(99999); p.leave();
  assert.equal(p.beacons.at(-1).pct, 100);
}

// A post shorter than the viewport is fully visible on load, so it reads as 100.
{
  const p = load({ articleHeight: 300 });
  p.scrollTo(0); p.leave();
  assert.equal(p.beacons.at(-1).pct, 100);
}

// Payload shape the worker validates against.
{
  const p = load();
  p.scrollTo(1000); p.leave();
  const b = p.beacons.at(-1);
  assert.equal(b.u, "/api/read");
  assert.match(b.vid, /^[0-9a-f-]{36}$/);
  assert.match(b.slug, /^\/blog\/[a-z0-9-]+\/$/);
  assert.ok(Number.isInteger(b.pct) && Number.isInteger(b.secs));
}

console.log("read.js: all checks passed");

// --- worker.js: the endpoint is public, so its validation is the trust boundary ---

const worker = (await import("../worker.js")).default;

function env() {
  const rows = [];
  return {
    rows,
    ASSETS: { fetch: () => new Response("asset", { status: 200 }) },
    DB: { prepare: () => ({ bind: (...a) => ({ run: () => (rows.push(a), {}) }) }) }
  };
}

const beacon = (body, headers = {}) => new Request("https://yashwanthreddymali.com/api/read", {
  method: "POST",
  headers: { origin: "https://yashwanthreddymali.com", ...headers },
  body: typeof body === "string" ? body : JSON.stringify(body)
});

const good = { vid: "11111111-2222-3333-4444-555555555555", slug: "/blog/failed-its-own-test/", pct: 62, secs: 240 };

{ // a real beacon is stored
  const e = env();
  assert.equal((await worker.fetch(beacon(good), e)).status, 204);
  assert.deepEqual(e.rows[0], [good.vid, good.slug, good.pct, good.secs]);
}

{ // anything else falls through to the static site
  const e = env();
  assert.equal((await worker.fetch(new Request("https://yashwanthreddymali.com/blog/"), e)).status, 200);
  assert.equal(e.rows.length, 0);
}

for (const [name, body] of [
  ["bad vid", { ...good, vid: "not-a-uuid" }],
  ["path traversal in slug", { ...good, slug: "/blog/../../etc/passwd" }],
  ["off-site slug", { ...good, slug: "/contact/" }],
  ["pct over 100", { ...good, pct: 5000 }],
  ["negative pct", { ...good, pct: -1 }],
  ["fractional pct", { ...good, pct: 12.5 }],
  ["absurd secs", { ...good, secs: 99999999 }],
  ["missing fields", {}],
  ["non-numeric pct", { ...good, pct: "62; DROP TABLE reads" }],
  ["object pct", { ...good, pct: {} }]
]) {
  const e = env();
  assert.equal((await worker.fetch(beacon(body), e)).status, 400, `${name} was accepted`);
  assert.equal(e.rows.length, 0, `${name} reached the database`);
}

{ // malformed json, and a hostile Origin, are rejected rather than thrown
  const e = env();
  assert.equal((await worker.fetch(beacon("{not json"), e)).status, 400);
  assert.equal((await worker.fetch(beacon(good, { origin: "https://evil.example" }), e)).status, 403);
  assert.equal((await worker.fetch(beacon(good, { origin: "null" }), e)).status, 403);
  assert.equal((await worker.fetch(new Request("https://yashwanthreddymali.com/api/read"), e)).status, 405);
  assert.equal(e.rows.length, 0);
}

console.log("worker.js: all checks passed");
