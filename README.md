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
tools/make-og.sh      Regenerates those cards
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

Card titles are sized by character count in buckets, so anything past ~120
characters needs a new bucket in the script. After deploying, LinkedIn and Slack
serve a cached preview; force a refresh through the
[Post Inspector](https://www.linkedin.com/post-inspector/).

## Design

The page is built as a register: hairline rules, tabular figures, and numbered
records. Capability is marked in ultramarine, stated limits in brass, and the
two are never mixed.

There's no JavaScript. Scroll effects use CSS scroll-driven animations and
degrade to plain, visible content where unsupported.

## About reusing this

The code structure is plain enough to poke around in, but the name, résumé,
writing, and design language on this site are mine, so please don't lift them
wholesale for your own portfolio.
