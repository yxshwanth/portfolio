# CLAUDE.md

Static HTML site, no build step and no dependencies. Keep it that way.

`worker.js` exists only to serve the site and accept the reading-depth beacon at
`POST /api/read`. It is a public endpoint: validate everything, and run
`node tools/tracking.test.mjs` after touching it or `assets/read.js`.

**Every new page needs a link-preview card.** Run `tools/make-og.sh` and add the
`og:image` / `twitter:image` tags to its `<head>`. Full steps and the gotchas are
in the "Link previews" section of `README.md` — read it before adding a page.
