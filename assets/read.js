// One beacon per reader, sent when they leave: how far down the article they got.
// Cookieless. The id is random per page load and never persisted, so it groups
// this visit's beacons together and identifies nobody.
(function () {
  var article = document.querySelector('.article-body');
  if (!article || !navigator.sendBeacon || !crypto.randomUUID) return;

  var vid = crypto.randomUUID();
  var start = Date.now();
  var max = 0;
  var sentAt = -1;

  function mark() {
    var box = article.getBoundingClientRect();
    var seen = Math.min(window.innerHeight - box.top, box.height);
    max = Math.max(max, Math.min(100, Math.round((seen / box.height) * 100)));
  }

  function send() {
    if (document.visibilityState !== 'hidden') return;
    mark();
    if (max <= sentAt) return; // nothing new since the last beacon
    sentAt = max;
    navigator.sendBeacon('/api/read', JSON.stringify({
      vid: vid,
      slug: location.pathname,
      pct: max,
      secs: Math.round((Date.now() - start) / 1000)
    }));
  }

  addEventListener('scroll', mark, { passive: true });
  addEventListener('resize', mark, { passive: true });
  document.addEventListener('visibilitychange', send);
  addEventListener('pagehide', send); // iOS Safari fires this more reliably
  mark();
})();
