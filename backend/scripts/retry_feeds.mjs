import fs from 'node:fs';
import http from 'node:http';
import https from 'node:https';

const CURATED = 'C:\\workspace\\code\\aware\\client\\assets\\curated_feeds.json';
const curated = JSON.parse(fs.readFileSync(CURATED, 'utf-8').replace(/^\uFEFF/, ''));
const feeds = curated.feeds;

const AWESOME = 'C:\\workspace\\code\\awesome-rss-feeds';
const opmlDirs = [
  'recommended\\with_category', 'recommended\\without_category',
  'countries\\with_category', 'countries\\without_category',
];
const awesomeUrls = new Set();
for (const dir of opmlDirs) {
  const dirPath = AWESOME + '\\' + dir;
  if (!fs.existsSync(dirPath)) continue;
  for (const file of fs.readdirSync(dirPath).filter(f => f.endsWith('.opml'))) {
    const content = fs.readFileSync(dirPath + '\\' + file, 'utf-8');
    for (const m of content.matchAll(/xmlUrl="([^"]+)"/g)) awesomeUrls.add(m[1]);
  }
}

const awesomeFeeds = feeds.filter(f => awesomeUrls.has(f.url));

// Failed feeds from HEAD test — retry with GET
const failedUrls = new Set([
  // 403 — retry
  "https://www.carbodydesign.com/feed/",
  "https://www.dezeen.com/interiors/feed/",
  "https://www.lizmarieblog.com/feed/",
  "https://obliviousinvestor.com/feed/",
  "https://www.codewall.co.uk/feed/",
  "https://www.jagonews24.com/rss/rss.xml",
  "https://www.elsiglodetorreon.com.mx/index.xml",
  "https://tonite.abante.com.ph/feed/",
  "https://badcryptopodcast.com/feed/",
  "https://feeds.npr.org/1025/rss.xml",
  "https://www.michaelwest.com.au/feed/",
  "https://bdnews24.com/?widgetName=rssfeed&widgetId=1150&getXmlFeed=true",
  "https://www.kalerkantho.com/rss.xml",
  "https://www.thestar.com/content/thestar/feed.RSSManagerServlet.articles.topstories.rss",
  "https://www.diplomatie.gouv.fr/spip.php?page=backend-fd&lang=en",
  "https://www.dnaindia.com/feeds/india.xml",
  "https://www.business-standard.com/rss/home_page_top_stories.rss",
  "https://www.fanpage.it/feed/",
  "https://www.ilpost.it/feed/",
  "https://japantoday.com/feed",
  "https://quequi.com.mx/feed/",
  "https://thenationonlineng.net/feed/",
  "https://guardian.ng/feed/",
  "https://businessmirror.com.ph/feed/",
  "https://www.pna.gov.ph/latest.rss",
  "https://www.pravda.com.ua/rss/",
  "https://www.repubblica.it/rss/homepage/rss2.0.xml",
  "https://androidcommunity.com/feed/",
  // 405 — retry
  "https://news.ycombinator.com/rss",
  "https://www.hket.com/rss/hongkong",
  "http://myanmargazette.net/feed",
  // 406 — retry
  "https://www.newscientist.com/subject/space/feed/",
  // timeout — retry
  "https://www.atlasobscura.com/feeds/latest",
  "https://feeds.megaphone.fm/cyberwire-daily-podcast",
  "http://tempo.com.ph/feed/",
  "http://feeds.washingtonpost.com/rss/world",
  // empty/aborted — retry
  "https://phys.org/rss-feed/",
  "https://feeds.folha.uol.com.br/emcimadahora/rss091.xml",
  "http://rss.home.uol.com.br/index.xml",
]);

function testGet(url, timeout = 10000) {
  return new Promise((resolve) => {
    const client = url.startsWith('https') ? https : http;
    const req = client.get(url, {
      timeout,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.230 Mobile Safari/537.36',
        'Accept': 'application/rss+xml, application/xml, text/xml, */*',
      },
    }, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk.toString(); if (data.length > 5000) req.destroy(); });
      res.on('end', () => {
        const ct = res.headers['content-type'] || '';
        const looksLikeFeed = data.length > 50 && (data.includes('<rss') || data.includes('<feed') || data.includes('<?xml') || ct.includes('xml') || ct.includes('rss'));
        resolve({ ok: res.statusCode >= 200 && res.statusCode < 400 && looksLikeFeed, status: res.statusCode, contentType: ct.substring(0, 50), bytes: data.length, looksLikeFeed });
      });
    });
    req.on('error', (e) => resolve({ ok: false, error: e.message.substring(0, 80), status: 0 }));
    req.on('timeout', () => { req.destroy(); resolve({ ok: false, error: 'Timeout', status: 0 }); });
  });
}

async function run() {
  // First, retry suspicious feeds with GET
  console.log('Retrying suspicious feeds with GET...\n');
  const suspiciousFeeds = awesomeFeeds.filter(f => failedUrls.has(f.url));
  console.log(`Retrying ${suspiciousFeeds.length} suspicious feeds...`);
  
  const stillFailing = [];
  const nowPassing = [];
  
  for (const feed of suspiciousFeeds) {
    const r = await testGet(feed.url);
    if (r.ok) {
      nowPassing.push(feed);
      console.log(`NOW OK [${r.status}] ${feed.category}/${feed.title || '?'}`);
    } else {
      stillFailing.push(feed);
      const err = r.error || `HTTP ${r.status} ct:${r.contentType} bytes:${r.bytes}`;
      console.log(`STILL FAIL [${err}] ${feed.category}/${feed.title || '?'}`);
    }
  }
  
  console.log(`\nNow passing with GET: ${nowPassing.length}`);
  console.log(`Still failing: ${stillFailing.length}`);
  
  if (stillFailing.length > 0) {
    console.log('\n=== STILL FAILING (should remove) ===');
    for (const f of stillFailing) {
      console.log(`${f.category} | ${f.title || '?'} | ${f.url}`);
    }
  }
}

run().catch(console.error);
