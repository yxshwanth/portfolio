// Everything except POST /api/read is a static file. See README "Reading depth".
const SLUG = /^\/blog\/[a-z0-9-]+\/$/;
const VID = /^[0-9a-f-]{36}$/;

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname !== "/api/read") return env.ASSETS.fetch(request);
    if (request.method !== "POST") return new Response("method not allowed", { status: 405 });

    // Public endpoint: only accept beacons the site itself sent.
    const origin = request.headers.get("origin");
    if (origin && origin !== url.origin) return new Response("forbidden", { status: 403 });

    let body;
    try { body = await request.json(); } catch { return new Response("bad json", { status: 400 }); }

    const vid = String(body.vid ?? "");
    const slug = String(body.slug ?? "");
    const pct = Number(body.pct);
    const secs = Number(body.secs);
    if (!VID.test(vid) || !SLUG.test(slug) ||
        !Number.isInteger(pct) || pct < 0 || pct > 100 ||
        !Number.isInteger(secs) || secs < 0 || secs > 86400) {
      return new Response("bad request", { status: 400 });
    }

    // Same visit can beacon more than once (tab away, come back, read on).
    // Keep the furthest point reached rather than the last one reported.
    await env.DB.prepare(
      `INSERT INTO reads (vid, slug, pct, secs, day) VALUES (?, ?, ?, ?, date('now'))
       ON CONFLICT(vid) DO UPDATE SET pct = max(pct, excluded.pct), secs = max(secs, excluded.secs)`
    ).bind(vid, slug, pct, secs).run();

    return new Response(null, { status: 204 });
  }
};
