# yashwanthreddymali.com

Source for my personal site and blog. Static HTML, one stylesheet, no build
step, no dependencies, no framework.

**Live:** [yashwanthreddymali.com](https://yashwanthreddymali.com)

```
index.html            Work (home page)
blog/                 Blog
contact/              Contact
assets/site.css       Styling
assets/og/            Link-preview cards (1200x630 PNG, one per page)
assets/read.js        Reading-depth beacon (blog posts only)
worker.js             Serves the site; handles POST /api/read
schema.sql            D1 table for reading depth
tools/make-og.sh      Regenerates the preview cards
tools/tracking.test.mjs   Checks read.js and worker.js
resume.pdf            Résumé
```

## How I update it

Everything is hand-written HTML: no CMS, no templating, no generator.

- **New project**: copy an `<article class="entry">` block in `index.html`.
  Entry numbers come from a CSS counter, so new or reordered entries renumber
  themselves automatically.
- **New blog post**: create `blog/<slug>/index.html` and link it from
  `blog/index.html`, then generate its link-preview card (below).
- **Résumé**: replace `resume.pdf` in place; every link points to that same
  filename.

## Link previews

**Every page gets a preview card. No exceptions** — a page without one shares as
a blank grey rectangle, which is most of the first impression a link makes.

Adding a page is two steps:

1. Append a `card` line to `tools/make-og.sh` and run it. Arguments are
   `<slug> <kicker> <title> <footer-left>`; the slug is the PNG filename, and
   posts use the publish date as the footer. The script renders
   `assets/og/<slug>.png` at 1200x630 with headless Chrome.
2. Add the tags to the page `<head>`, alongside the existing `og:` block:

   ```html
   <meta property="og:image" content="https://yashwanthreddymali.com/assets/og/<slug>.png">
   <meta property="og:image:width" content="1200">
   <meta property="og:image:height" content="630">
   <meta property="og:image:alt" content="<title> — yashwanthreddymali.com">
   <meta name="twitter:card" content="summary_large_image">
   <meta name="twitter:image" content="https://yashwanthreddymali.com/assets/og/<slug>.png">
   ```

Two things that are easy to get wrong: `og:image` must be an absolute URL, and
`og:title` is the bare title with no `| Yashwanth Reddy Mali` suffix — the
suffix is already in `og:site_name`, and repeating it truncates the real title
in Slack and LinkedIn.

The home page is the one exception: it has its own `card_home` block in the
script, because it carries the site's thesis with capability in ultramarine and
stated limits in brass. Edit that block directly rather than adding a `card`
line for it.

Card titles are sized by character count in buckets, so anything past ~120
characters needs a new bucket in the script. After deploying, LinkedIn and Slack
serve a cached preview; force a refresh through the
[Post Inspector](https://www.linkedin.com/post-inspector/).

## Reading depth

How far people actually get through a post. Cloudflare Web Analytics counts
pageviews and nothing else, so this is a small beacon of my own.

`assets/read.js` runs on post pages only. It tracks the furthest point of
`.article-body` that has scrolled past the bottom of the viewport, and sends one
`sendBeacon` to `/api/read` when the reader leaves. `worker.js` validates it and
writes a row to D1. The id in the beacon is a random UUID generated per page
load and never stored in the browser, so it groups one visit's beacons together
and identifies nobody: no cookies, no localStorage, no fingerprint.

One-time setup:

```bash
npx wrangler d1 create portfolio-reads
```

Put the returned `database_id` into `wrangler.jsonc`, then create the table:

```bash
npx wrangler d1 execute portfolio-reads --remote --file=schema.sql
```

The funnel, per post:

```bash
npx wrangler d1 execute portfolio-reads --remote --command "SELECT slug, count(*) opened, sum(pct>=25) got25, sum(pct>=50) got50, sum(pct>=75) got75, sum(pct>=90) finished, round(avg(secs)) avg_secs FROM reads GROUP BY slug ORDER BY opened DESC"
```

`opened` counts visits that stayed long enough to fire a beacon, so it runs
below the Cloudflare pageview count and the gap is roughly the instant bounces.
A post shorter than one screen reads as 100% on load, which is correct but worth
remembering when comparing a short post against a long one.

After changing either file:

```bash
node tools/tracking.test.mjs
```

## Design

The page is built as a register: hairline rules, tabular figures, and numbered
records. Capability is marked in ultramarine, stated limits in brass, and the
two are never mixed.

There's almost no JavaScript: the reading-depth beacon on post pages and the
analytics beacon, both deferred and both optional to the page working. Scroll
effects use CSS scroll-driven animations and degrade to plain, visible content
where unsupported.

## About reusing this

The code structure is plain enough to poke around in, but the name, résumé,
writing, and design language on this site are mine, so please don't lift them
wholesale for your own portfolio.
