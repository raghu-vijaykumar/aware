import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(__dirname, '..', '..');
const AWESOME = 'C:\\workspace\\code\\awesome-rss-feeds';
const CURATED_FEEDS = path.join(REPO, 'client', 'assets', 'curated_feeds.json');
const SQL_OUT = path.join(__dirname, '..', 'seed_marketplace.sql');

const OPML_DIRS = [
  'recommended\\with_category',
  'recommended\\without_category',
  'countries\\with_category',
  'countries\\without_category',
];

// URLs confirmed dead — skip on next build
const DEAD_URLS = new Set([
  'http://rssfeeds.9news.com/kusa/home&x=1',
  'https://www.tasnimnews.com/fa/rss/feed/0/8/0/%D9%85%D9%87%D9%85%D8%AA%D8%B1%DB%8C%D9%86-%D8%A7%D8%AE%D8%A8%D8%A7%D8%B1-%D8%AA%D8%B3%D9%86%DB%8C%D9%85',
  'https://vesti.ua/feeds/partners',
  'https://androidcommunity.com/feed/',
  'https://www.financialexpress.com/feed/',
  'https://indiegamesplus.com/feed',
  'https://architizer.wpengine.com/feed/',
  'https://www.cyanogenmods.org/feed',
]);

const PALETTE = [
  '#FF5252', '#FF4081', '#E040FB', '#7C4DFF', '#536DFE',
  '#448AFF', '#40C4FF', '#18FFFF', '#64FFDA', '#69F0AE',
  '#B2FF59', '#EEFF41', '#FFD740', '#FFAB40', '#FF6E40',
  '#F48FB1', '#CE93D8', '#90CAF9', '#81D4FA', '#80DEEA',
  '#A5D6A7', '#C5E1A5', '#E6EE9C', '#FFF59D', '#FFCC80',
  '#BCAAA4', '#B0BEC5', '#F06292', '#BA68C8', '#4DB6AC',
  '#AED581', '#FF8A65', '#A1887F', '#90A4AE', '#DCE775',
  '#4DD0E1', '#7986CB', '#F6BF26', '#33B679', '#E67C73',
  '#8E24AA', '#F4511E', '#5E35B1', '#EEFF41', '#00BCD4',
];

function decodeEntities(str) {
  return str
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&apos;/g, "'");
}

function normalizeLabel(label) {
  return label.toLowerCase().replace(/[^a-z0-9]/g, '');
}

function slugify(label) {
  return label.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

function sqlEscape(val) {
  if (!val) return '';
  return val.replace(/'/g, "''");
}

// ---- Load existing curated feeds ----
const curated = JSON.parse(fs.readFileSync(CURATED_FEEDS, 'utf-8').replace(/^\uFEFF/, ''));
const existingFeeds = curated.feeds || [];
const existingCategories = curated.categories || [];

const existingUrlSet = new Set(existingFeeds.map(f => f.url));
const catIdToLabel = {};
const catIdToColor = {};
const normLabelToId = {};

for (const c of existingCategories) {
  catIdToLabel[c.id] = c.label;
  catIdToColor[c.id] = c.color;
  normLabelToId[normalizeLabel(c.label)] = c.id;
}

console.log(`Existing: ${existingFeeds.length} feeds, ${existingCategories.length} categories`);

// ---- Process OPML ----
const newFeeds = [];
const newUrlSet = new Set();

// Maps: filename label → { label (canonical), id (slug), color, isNew }
const catByFilename = {};
let paletteIdx = 0;

function canonicalCat(label) {
  if (catByFilename[label]) return catByFilename[label];
  const norm = normalizeLabel(label);
  const existingId = normLabelToId[norm];
  if (existingId) {
    const result = { label: catIdToLabel[existingId], id: existingId, color: catIdToColor[existingId], isNew: false };
    catByFilename[label] = result;
    return result;
  }
  const id = slugify(label);
  const color = PALETTE[paletteIdx++ % PALETTE.length];
  const result = { label, id, color, isNew: true };
  catByFilename[label] = result;
  return result;
}

function processOpml(filePath) {
  const label = path.basename(filePath, '.opml');
  const cat = canonicalCat(label);
  const content = fs.readFileSync(filePath, 'utf-8');
  // Match <outline ... />; handle > inside quoted attribute values
  const feedRe = /<outline\b((?:[^>"']*|"[^"]*"|'[^']*')*)\/>/gs;
  let count = 0;
  let match;
  while ((match = feedRe.exec(content)) !== null) {
    const attrs = match[1];
    const urlM = attrs.match(/xmlUrl\s*=\s*"([^"]*)"/);
    if (!urlM) continue;
    const url = urlM[1];
    if (DEAD_URLS.has(url)) continue;
    if (existingUrlSet.has(url) || newUrlSet.has(url)) continue;
    const titleM = attrs.match(/title\s*=\s*"([^"]*)"/);
    const textM = attrs.match(/text\s*=\s*"([^"]*)"/);
    const descM = attrs.match(/description\s*=\s*"([^"]*)"/);
    newFeeds.push({
      url,
      title: decodeEntities(titleM?.[1] || textM?.[1] || ''),
      description: decodeEntities(descM?.[1] || ''),
      categoryLabel: cat.label,
    });
    newUrlSet.add(url);
    count++;
  }
  return count;
}

let totalNew = 0;
for (const dir of OPML_DIRS) {
  const dirPath = path.join(AWESOME, dir);
  if (!fs.existsSync(dirPath)) { console.warn(`  Skipping (not found): ${dirPath}`); continue; }
  const files = fs.readdirSync(dirPath).filter(f => f.endsWith('.opml')).sort();
  for (const file of files) {
    const c = processOpml(path.join(dirPath, file));
    totalNew += c;
    console.log(`  ${dir}\\${file}: ${c} new`);
  }
}
console.log(`\nNew feeds found: ${totalNew}`);

// ---- Build final categories ----
const seenLabels = new Set(existingCategories.map(c => c.label));
const finalCategories = [...existingCategories.map(c => ({ ...c }))];

// Determine which categories have at least one feed across existing + new
const catFeedCount = {};
for (const f of existingFeeds) {
  const label = catIdToLabel[f.category] || f.category || 'Uncategorized';
  catFeedCount[label] = (catFeedCount[label] || 0) + 1;
}
for (const f of newFeeds) {
  catFeedCount[f.categoryLabel] = (catFeedCount[f.categoryLabel] || 0) + 1;
}

for (const [filenameLabel, cat] of Object.entries(catByFilename)) {
  if ((catFeedCount[cat.label] ?? 0) === 0) {
    console.log(`  Skipping empty category: ${cat.label}`);
    continue;
  }
  if (!seenLabels.has(cat.label)) {
    finalCategories.push({ id: cat.id, label: cat.label, color: cat.color });
    seenLabels.add(cat.label);
    console.log(`  New category: ${cat.label} -> id=${cat.id} color=${cat.color} (${catFeedCount[cat.label]} feeds)`);
  } else {
    if (cat.isNew) {
      console.log(`  New category: ${cat.label} -> id=${cat.id} color=${cat.color} (${catFeedCount[cat.label]} feeds)`);
    }
  }
}

// Remove any existing categories that now have zero feeds
const filteredFinalCategories = finalCategories.filter(c => (catFeedCount[c.label] ?? 0) > 0);
if (filteredFinalCategories.length !== finalCategories.length) {
  const removed = finalCategories.filter(c => (catFeedCount[c.label] ?? 0) === 0).map(c => c.label);
  console.log(`  Removing empty existing categories: ${removed.join(', ')}`);
}

// ---- Build final feeds (JSON) ----
function jsonCategory(label) {
  const cat = catByFilename[label] || Object.values(catByFilename).find(c => c.label === label);
  return cat ? cat.id : slugify(label);
}

const mergedFeeds = [
  ...existingFeeds.map(f => ({
    title: f.title || undefined,
    url: f.url,
    description: f.description || undefined,
    category: f.category || undefined,
  })),
  ...newFeeds.map(f => ({
    title: f.title || undefined,
    url: f.url,
    description: f.description || undefined,
    category: jsonCategory(f.categoryLabel),
  })),
];

const outputJson = { feeds: mergedFeeds, categories: filteredFinalCategories };
fs.writeFileSync(CURATED_FEEDS, JSON.stringify(outputJson, null, 2), 'utf-8');
console.log(`\nWritten ${CURATED_FEEDS} (${mergedFeeds.length} feeds, ${filteredFinalCategories.length} categories)`);

// ---- Generate SQL ----
const sqlCategories = [...filteredFinalCategories];
const sqlFeedsExisting = existingFeeds.map(f => ({
  url: f.url,
  title: f.title || '',
  description: f.description || '',
  categoryName: catIdToLabel[f.category] || f.category || 'Uncategorized',
}));
const sqlFeedsNew = newFeeds.map(f => ({
  url: f.url,
  title: f.title,
  description: f.description,
  categoryName: f.categoryLabel,
}));

// Dedupe by url for SQL too
const sqlSeen = new Set();
const sqlAllFeeds = [...sqlFeedsExisting, ...sqlFeedsNew].filter(f => {
  if (sqlSeen.has(f.url)) return false;
  sqlSeen.add(f.url);
  return true;
});

const sqlLines = [];
sqlLines.push('-- Seed marketplace categories and feeds');
sqlLines.push('-- Generated by build_marketplace.mjs');
sqlLines.push('');

sqlLines.push('-- marketplace_categories (idempotent)');
for (const c of sqlCategories) {
  const name = sqlEscape(c.label);
  sqlLines.push(`INSERT INTO marketplace_categories (name) VALUES ('${name}') ON CONFLICT (name) DO NOTHING;`);
}
sqlLines.push('');

sqlLines.push('-- marketplace_feeds (idempotent)');
for (const f of sqlAllFeeds) {
  const name = sqlEscape(f.categoryName);
  const title = sqlEscape(f.title);
  const url = sqlEscape(f.url);
  const desc = sqlEscape(f.description);
  sqlLines.push(
    `INSERT INTO marketplace_feeds (category_id, title, url, description) VALUES ((SELECT id FROM marketplace_categories WHERE name = '${name}'), '${title}', '${url}', '${desc}') ON CONFLICT (url) DO NOTHING;`
  );
}
sqlLines.push('');

fs.writeFileSync(SQL_OUT, sqlLines.join('\n'), 'utf-8');
console.log(`Written ${SQL_OUT} (${sqlCategories.length} categories (all with feeds), ${sqlAllFeeds.length} feeds)`);

console.log('\nDone!');
