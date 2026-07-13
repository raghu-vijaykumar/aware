import fs from 'node:fs';

const CURATED = 'C:\\workspace\\code\\aware\\client\\assets\\curated_feeds.json';
const curated = JSON.parse(fs.readFileSync(CURATED, 'utf-8').replace(/^\uFEFF/, ''));

// URLs confirmed dead: DNS errors, connection refused, 410 gone, 500 server error
const DEAD_URLS = new Set([
  // DNS resolution failure
  'http://rssfeeds.9news.com/kusa/home&x=1',
  'https://www.tasnimnews.com/fa/rss/feed/0/8/0/%D9%85%D9%87%D9%85%D8%AA%D8%B1%DB%8C%D9%86-%D8%A7%D8%AE%D8%A8%D8%A7%D8%B1-%D8%AA%D8%B3%D9%86%DB%8C%D9%85',
  'https://vesti.ua/feeds/partners',
  // Connection refused
  'https://androidcommunity.com/feed/',
  // 410 Gone
  'https://www.financialexpress.com/feed/',
  // 500 Internal Server Error
  'https://indiegamesplus.com/feed',
  // 404 — confirmed dead (wpengine domain, dead site)
  'https://architizer.wpengine.com/feed/',
  // 404 — dead domain
  'https://www.cyanogenmods.org/feed',
]);

const before = curated.feeds.length;
curated.feeds = curated.feeds.filter(f => !DEAD_URLS.has(f.url));
const removed = before - curated.feeds.length;

// Remove categories that now have 0 feeds
const catCount = {};
for (const f of curated.feeds) {
  if (f.category) catCount[f.category] = (catCount[f.category] || 0) + 1;
}
const catsBefore = curated.categories.length;
curated.categories = curated.categories.filter(c => (catCount[c.id] || 0) > 0);
const catsRemoved = catsBefore - curated.categories.length;

fs.writeFileSync(CURATED, JSON.stringify(curated, null, 2), 'utf-8');
console.log(`Removed ${removed} dead feeds`);
console.log(`Removed ${catsRemoved} empty categories`);
console.log(`Now: ${curated.feeds.length} feeds, ${curated.categories.length} categories`);

// Also write updated SQL
const sqlLines = [];
sqlLines.push('-- Seed marketplace categories and feeds (after dead-feed removal)');
sqlLines.push('');
sqlLines.push('-- marketplace_categories');
for (const c of curated.categories) {
  sqlLines.push(`INSERT INTO marketplace_categories (name) VALUES ('${c.label.replace(/'/g, "''")}') ON CONFLICT (name) DO NOTHING;`);
}
sqlLines.push('');
sqlLines.push('-- marketplace_feeds');
for (const f of curated.feeds) {
  const catName = curated.categories.find(c => c.id === f.category)?.label || f.category || 'Uncategorized';
  sqlLines.push(
    `INSERT INTO marketplace_feeds (category_id, title, url, description) VALUES ((SELECT id FROM marketplace_categories WHERE name = '${catName.replace(/'/g, "''")}'), '${(f.title || '').replace(/'/g, "''")}', '${f.url.replace(/'/g, "''")}', '${(f.description || '').replace(/'/g, "''")}') ON CONFLICT (url) DO NOTHING;`
  );
}

fs.writeFileSync('C:\\workspace\\code\\aware\\backend\\seed_marketplace.sql', sqlLines.join('\n'), 'utf-8');
console.log('Updated seed_marketplace.sql');
