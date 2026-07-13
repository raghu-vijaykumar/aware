import fs from 'node:fs';
import path from 'node:path';

const AWESOME = 'C:\\workspace\\code\\awesome-rss-feeds';
const curated = JSON.parse(fs.readFileSync('C:\\workspace\\code\\aware\\client\\assets\\curated_feeds.json', 'utf-8').replace(/^\uFEFF/, ''));
const curatedUrls = new Set(curated.feeds.map(f => f.url));

const dirs = [
  'recommended\\with_category',
  'recommended\\without_category',
  'countries\\with_category',
  'countries\\without_category',
];

const opmlUrls = new Set();
let totalOpml = 0;

for (const dir of dirs) {
  const dirPath = path.join(AWESOME, dir);
  if (!fs.existsSync(dirPath)) continue;
  const files = fs.readdirSync(dirPath).filter(f => f.endsWith('.opml'));
  for (const file of files) {
    const content = fs.readFileSync(path.join(dirPath, file), 'utf-8');
    const matches = [...content.matchAll(/xmlUrl="([^"]+)"/g)];
    for (const m of matches) {
      opmlUrls.add(m[1]);
      totalOpml++;
    }
  }
}

console.log('=== OVERALL ===');
console.log('Total OPML feed entries (with dupes):', totalOpml);
console.log('Unique OPML URLs:', opmlUrls.size);
console.log('Curated feeds:', curated.feeds.length);

const missing = [...opmlUrls].filter(u => !curatedUrls.has(u));
console.log('\n=== COVERAGE ===');
console.log('Covered:', opmlUrls.size - missing.length);
console.log('MISSING:', missing.length);
if (missing.length > 0) {
  console.log('\nMISSING feeds:');
  missing.forEach(u => console.log('  ' + u));
}

// Per-file breakdown
console.log('\n=== PER-FILE BREAKDOWN ===');
for (const dir of dirs) {
  const dirPath = path.join(AWESOME, dir);
  if (!fs.existsSync(dirPath)) { console.log(dir + ': dir not found'); continue; }
  const files = fs.readdirSync(dirPath).filter(f => f.endsWith('.opml')).sort();
  for (const file of files) {
    const content = fs.readFileSync(path.join(dirPath, file), 'utf-8');
    const catUrls = [...content.matchAll(/xmlUrl="([^"]+)"/g)].map(m => m[1]);
    const catUnique = new Set(catUrls);
    const covered = [...catUnique].filter(u => curatedUrls.has(u));
    const missed = [...catUnique].filter(u => !curatedUrls.has(u));
    const status = missed.length === 0 ? '✓' : 'MISSING ' + missed.length;
    console.log(dir + '\\' + file + ': ' + covered.length + '/' + catUnique.size + ' ' + status);
    if (missed.length > 0) {
      missed.forEach(u => console.log('    ' + u));
    }
  }
}
