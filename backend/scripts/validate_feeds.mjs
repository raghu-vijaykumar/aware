import fs from 'node:fs';
import http from 'node:http';
import https from 'node:https';

const AWESOME_FEEDS_BASE = 'C:\\workspace\\code\\awesome-rss-feeds';
const CURATED = 'C:\\workspace\\code\\aware\\client\\assets\\curated_feeds.json';

// Collect all OPML URLs from awesome-rss-feeds (the 837 unique ones)
const opmlDirs = [
  'recommended\\with_category', 'recommended\\without_category',
  'countries\\with_category', 'countries\\without_category',
];

const awesomeUrls = new Set();
for (const dir of opmlDirs) {
  const dirPath = AWESOME_FEEDS_BASE + '\\' + dir;
  if (!fs.existsSync(dirPath)) continue;
  for (const file of fs.readdirSync(dirPath).filter(f => f.endsWith('.opml'))) {
    const content = fs.readFileSync(dirPath + '\\' + file, 'utf-8');
    for (const m of content.matchAll(/xmlUrl="([^"]+)"/g)) {
      awesomeUrls.add(m[1]);
    }
  }
}
console.log('Awesome OPML unique URLs:', awesomeUrls.size);

// Load curated feeds
const curated = JSON.parse(fs.readFileSync(CURATED, 'utf-8').replace(/^\uFEFF/, ''));
const curatedFeeds = curated.feeds;
console.log('Curated feeds:', curatedFeeds.length);

// Identify which curated feeds came from awesome-rss (by URL)
const feedsToTest = curatedFeeds.filter(f => awesomeUrls.has(f.url));
console.log('Awesome-derived feeds to test:', feedsToTest.length);

// Test a single feed — HEAD is lighter
function testUrl(url, timeout = 8000) {
  return new Promise((resolve) => {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return resolve({ url, ok: false, error: 'Invalid scheme', status: 0 });
    }
    const client = url.startsWith('https') ? https : http;
    const req = client.request(url, {
      method: 'HEAD',
      timeout,
      headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; FeedValidator/1.0)',
        'Accept': 'application/rss+xml, application/xml, text/xml, */*',
      },
    }, (res) => {
      res.resume();
      resolve({ url, ok: res.statusCode >= 200 && res.statusCode < 400, status: res.statusCode });
    });
    req.on('error', (err) => resolve({ url, ok: false, error: err.message.substring(0, 80), status: 0 }));
    req.on('timeout', () => { req.destroy(); resolve({ url, ok: false, error: 'Timeout', status: 0 }); });
    req.end();
  });
}

async function run() {
  const CONCURRENT = 50;
  let passed = 0, failed = 0;
  const failures = [];
  
  for (let i = 0; i < feedsToTest.length; i += CONCURRENT) {
    const batch = feedsToTest.slice(i, i + CONCURRENT);
    const results = await Promise.all(batch.map(f => testUrl(f.url)));
    
    for (let j = 0; j < results.length; j++) {
      const r = results[j];
      if (r.ok) {
        passed++;
      } else {
        failed++;
        const feed = batch[j];
        failures.push({ ...r, feed });
        console.log(`FAIL [${r.status || r.error}] ${feed.category}/${feed.title || '?'}`);
        console.log(`  ${feed.url}`);
      }
    }
    console.log(`Progress: ${Math.min(i+CONCURRENT, feedsToTest.length)}/${feedsToTest.length} (passed: ${passed}, failed: ${failed})`);
  }
  
  console.log(`\n=== RESULTS ===`);
  console.log(`Tested: ${feedsToTest.length}`);
  console.log(`Passed: ${passed}`);
  console.log(`Failed: ${failed}`);
  
  if (failures.length > 0) {
    console.log(`\n=== FAILED FEEDS (${failures.length}) ===`);
    for (const f of failures) {
      console.log(`${f.status || f.error} | ${f.feed.category} | ${f.feed.title || 'Untitled'} | ${f.feed.url}`);
    }
  }
}

run().catch(console.error);
