# yashwanthreddymali.com

Source for my personal site and blog. Static HTML, one stylesheet, no build
step, no dependencies, no framework.

**Live:** [yashwanthreddymali.com](https://yashwanthreddymali.com)

```
index.html            Work (home page)
blog/                 Blog
contact/              Contact
assets/site.css       Styling
resume.pdf            Résumé
```

## How I update it

Everything is hand-written HTML: no CMS, no templating, no generator.

- **New project**: copy an `<article class="entry">` block in `index.html`.
  Entry numbers come from a CSS counter, so new or reordered entries renumber
  themselves automatically.
- **New blog post**: create `blog/<slug>/index.html` and link it from
  `blog/index.html`.
- **Résumé**: replace `resume.pdf` in place; every link points to that same
  filename.

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
