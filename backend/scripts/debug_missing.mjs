import fs from 'node:fs';
import path from 'node:path';

const AWESOME = 'C:\\workspace\\code\\awesome-rss-feeds';

function testFile(filePath) {
  console.log('Testing:', path.basename(filePath));
  const content = fs.readFileSync(filePath, 'utf-8');
  const feedRe = /<outline\b((?:[^>"']*|"[^"]*"|'[^']*')*)\/>/gs;
  let match;
  let count = 0;
  while ((match = feedRe.exec(content)) !== null) {
    const attrs = match[1];
    const urlM = attrs.match(/xmlUrl="([^"]+)"/);
    if (urlM) {
      count++;
    }
  }
  console.log('  Feeds found via regex:', count);
  
  // Also count by simpler method
  const allXmlUrls = content.match(/xmlUrl="[^"]+"/g);
  console.log('  xmlUrl occurrences:', allXmlUrls ? allXmlUrls.length : 0);
  
  // Specifically check the known missing URLs
  const missingCheck = [
    'https://www.repubblica.it/rss/homepage/rss2.0.xml',
    'https://www.nytimes.com/svc/collections/v1/publish/http://www.nytimes.com/topic/destination/japan/rss.xml',
    'https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml',
  ];
  for (const url of missingCheck) {
    if (content.includes(url)) {
      // Find the outline element containing this URL
      const lines = content.split('\n');
      for (let i = 0; i < lines.length; i++) {
        if (lines[i].includes(url)) {
          console.log('  LINE ' + (i+1) + ': ' + lines[i].trim());
        }
      }
    }
  }
}

testFile(path.join(AWESOME, 'countries', 'with_category', 'Italy.opml'));
testFile(path.join(AWESOME, 'countries', 'with_category', 'Japan.opml'));
testFile(path.join(AWESOME, 'countries', 'with_category', 'United States.opml'));
