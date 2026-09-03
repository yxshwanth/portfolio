#!/bin/bash
# Regenerates the link-preview cards in assets/og/. Add a card() line for each new page.
set -euo pipefail
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/assets/og"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$OUT"

# card <slug> <kicker> <title> <footer-left>
card() {
  local slug=$1 kicker=$2 title=$3 foot=$4 size
  local n=${#title}
  if   [ "$n" -lt 34 ]; then size=88
  elif [ "$n" -lt 60 ]; then size=68
  elif [ "$n" -lt 90 ]; then size=56
  else size=46
  fi
  cat > "$TMP/$slug.html" <<HTML
<!DOCTYPE html><html><head><meta charset="utf-8">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=IBM+Plex+Serif:wght@400;600&display=swap" rel="stylesheet">
<style>
  * { margin:0; padding:0; box-sizing:border-box; }
  html,body { width:1200px; height:630px; }
  body {
    background:#101216; color:#E7E9ED; overflow:hidden;
    border-left:10px solid #9DAEFF;
    padding:64px 72px 56px;
    display:flex; flex-direction:column;
    font-family:"IBM Plex Mono", ui-monospace, Menlo, monospace;
  }
  .top { display:flex; justify-content:space-between; align-items:baseline;
         font-size:22px; letter-spacing:.14em; text-transform:uppercase;
         color:#6B7280; padding-bottom:26px; border-bottom:1px solid #39404B; }
  .top .k { color:#9DAEFF; }
  h1 { flex:1; display:flex; align-items:center;
       font-family:"IBM Plex Serif", Georgia, serif; font-weight:600;
       font-size:${size}px; line-height:1.16; letter-spacing:-.015em;
       padding:52px 0; max-width:20ch; }
  .foot { display:flex; justify-content:space-between; align-items:baseline;
          font-size:22px; color:#9DA4B0; padding-top:26px; border-top:1px solid #39404B; }
  .foot strong { color:#E7E9ED; font-weight:500; }
</style></head><body>
  <div class="top"><span>yashwanthreddymali.com</span><span class="k">${kicker}</span></div>
  <h1>${title}</h1>
  <div class="foot"><span>${foot}</span><strong>Yashwanth Reddy Mali</strong></div>
</body></html>
HTML
  "$CHROME" --headless --disable-gpu --hide-scrollbars --force-color-profile=srgb \
    --virtual-time-budget=4000 --window-size=1200,630 \
    --screenshot="$OUT/$slug.png" "file://$TMP/$slug.html" >/dev/null 2>&1
  echo "assets/og/$slug.png  ($(du -h "$OUT/$slug.png" | cut -f1))"
}

card home     "Backend engineer" "Production systems in Go, Python, and TypeScript" "Platform, authorization, systems"
card blog     "Blog"     "Notes on systems, security, and whatever else is worth writing down" "yashwanthreddymali.com/blog"
card contact  "Contact"  "Get in touch about backend, platform, and authorization work" "yashwanthreddymali.com/contact"
card interlock-exfiltration-at-runtime "Blog" \
  "Interlock: a runtime firewall for AI agents that assumes prompt injection already won" "31 July 2026"
card failed-its-own-test "Blog" \
  "I built a site that publishes its own limits, then it failed its own test" "25 July 2026"
