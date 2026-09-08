#!/bin/bash
# Regenerates the link-preview cards in assets/og/. Add a card() line for each new page.
set -euo pipefail
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/assets/og"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$OUT"

# shot <slug> — renders $TMP/<slug>.html to assets/og/<slug>.png
shot() {
  "$CHROME" --headless --disable-gpu --hide-scrollbars --force-color-profile=srgb \
    --virtual-time-budget=4000 --window-size=1200,630 \
    --screenshot="$OUT/$1.png" "file://$TMP/$1.html" >/dev/null 2>&1
  echo "assets/og/$1.png  ($(du -h "$OUT/$1.png" | cut -f1))"
}

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
  shot "$slug"
}

# The landing page gets its own card: the site's thesis, with capability in
# ultramarine and stated limits in brass, the same grammar the site itself uses.
card_home() {
  cat > "$TMP/home.html" <<'HTML'
<!DOCTYPE html><html><head><meta charset="utf-8">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=IBM+Plex+Serif:ital,wght@0,400;0,600;1,400&display=swap" rel="stylesheet">
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
  .mid { flex:1; display:flex; flex-direction:column; justify-content:center; padding:46px 0; }
  h1 { font-family:"IBM Plex Serif", Georgia, serif; font-weight:600;
       font-size:66px; line-height:1.18; letter-spacing:-.018em; max-width:19ch; }
  h1 .cap { color:#9DAEFF; }
  h1 .lim { color:#D9B25C; }
  .stack { margin-top:34px; display:flex; gap:26px; align-items:center;
           font-size:20px; letter-spacing:.1em; text-transform:uppercase; color:#6B7280; }
  .stack span { position:relative; }
  .stack span + span::before { content:""; position:absolute; left:-14px; top:50%;
    width:3px; height:3px; border-radius:50%; background:#39404B; transform:translateY(-50%); }
  .foot { display:flex; justify-content:space-between; align-items:baseline;
          font-size:22px; color:#9DA4B0; padding-top:26px; border-top:1px solid #39404B; }
  .foot strong { color:#E7E9ED; font-weight:500; }
</style></head><body>
  <div class="top"><span>yashwanthreddymali.com</span><span class="k">Backend engineer</span></div>
  <div class="mid">
    <h1>I build systems that <span class="cap">enforce limits</span>, and I <span class="lim">publish the limits</span>.</h1>
    <div class="stack"><span>Go</span><span>Rust</span><span>eBPF</span><span>Raft</span><span>Kubernetes</span></div>
  </div>
  <div class="foot"><span>Platform, authorization, systems</span><strong>Yashwanth Reddy Mali</strong></div>
</body></html>
HTML
  shot home
}

card_home
card blog     "Blog"     "Notes on systems, security, and whatever else is worth writing down" "yashwanthreddymali.com/blog"
card contact  "Contact"  "Get in touch about backend, platform, and authorization work" "yashwanthreddymali.com/contact"
card interlock-exfiltration-at-runtime "Blog" \
  "Interlock: a runtime firewall for AI agents that assumes prompt injection already won" "31 July 2026"
card failed-its-own-test "Blog" \
  "I built a site that publishes its own limits, then it failed its own test" "25 July 2026"
