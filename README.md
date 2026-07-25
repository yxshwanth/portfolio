# yashwanthreddymali.com

Static site. No build step, no dependencies, no framework.

```
index.html                          Work
blog/index.html                     Blog index
blog/failed-its-own-test/           Post: why the site publishes its own limits
contact/index.html                  Contact
assets/site.css                     All styling
resume.pdf                          Linked from /contact/
```

## Deploy to Cloudflare Pages

1. Cloudflare dashboard → **Workers & Pages** → **Create** → **Pages** → **Upload assets**
2. Drag this entire folder in
3. **Custom domains** → add `yashwanthreddymali.com` and `www.yashwanthreddymali.com`

Cloudflare adds the apex A records and the `www` CNAME automatically, which fills the gap
left when the GoDaddy parking records were deleted. HTTPS is automatic.

For git-based deploys instead, push to GitHub and connect the repo — build command empty,
output directory `/`.

## Before publishing

- [ ] Confirm `resume.pdf` is the current version
- [ ] Optional: add an `og:image` (1200x630) so shared links render a preview card.
      The `og:` tags are already in place on every page; only the image is missing.

## Notes

- Fonts load from Google Fonts. To self-host, download IBM Plex and swap the `<link>` for `@font-face`.
- Dark mode follows the OS setting via `prefers-color-scheme`. No toggle, no storage.
- Every color and font is defined once at the top of `assets/site.css`.

## Design

The page is built as a register: hairline rules, tabular figures, and numbered
records. Two rules hold the system together.

- **Brass means a stated limit, and nothing else.** It appears on the known-gaps
  panel and the article blockquote. Never on capability.
- **The ledger is double-entry.** Capability is a credit (`+`, ultramarine);
  every named limit is a debit (`−`, brass). The gaps panel appears only where
  there is a genuine scope boundary, not on every project. Measurement caveats
  belong inline next to their numbers, not under a "known gaps" heading.

Entry numbers come from a CSS counter, so adding or reordering a project in
`index.html` renumbers the section automatically. There is no JavaScript: the
reading-progress rule and the scroll reveals use CSS scroll-driven animations,
and both degrade to plain visible content where unsupported.
