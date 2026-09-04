CREATE TABLE IF NOT EXISTS reads (
  vid  TEXT PRIMARY KEY,   -- random per page load, not per person
  slug TEXT NOT NULL,
  pct  INTEGER NOT NULL,   -- furthest point reached, 0-100
  secs INTEGER NOT NULL,
  day  TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS reads_slug_day ON reads (slug, day);
