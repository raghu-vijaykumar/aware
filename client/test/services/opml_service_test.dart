import 'package:flutter_test/flutter_test.dart';
import 'package:aware/models/feed.dart';
import 'package:aware/services/opml_service.dart';

void main() {
  late OpmlService service;

  setUp(() {
    service = OpmlService();
  });

  group('extractFeedUrls', () {
    test('extracts URLs from valid OPML', () {
      final opml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="1.0">
  <head><title>Test</title></head>
  <body>
    <outline text="Feed 1" xmlUrl="https://example.com/feed1.xml"/>
    <outline text="Feed 2" xmlUrl="https://example.com/feed2.xml"/>
  </body>
</opml>''';
      final urls = service.extractFeedUrls(opml);
      expect(urls, contains('https://example.com/feed1.xml'));
      expect(urls, contains('https://example.com/feed2.xml'));
      expect(urls.length, 2);
    });

    test('ignores outlines without xmlUrl', () {
      final opml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="1.0">
  <body>
    <outline text="Folder">
      <outline text="Feed A" xmlUrl="https://example.com/a.xml"/>
      <outline text="No URL"/>
    </outline>
  </body>
</opml>''';
      final urls = service.extractFeedUrls(opml);
      expect(urls, contains('https://example.com/a.xml'));
      expect(urls.length, 1);
    });

    test('deduplicates URLs', () {
      final opml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="1.0">
  <body>
    <outline text="Feed 1" xmlUrl="https://example.com/dup.xml"/>
    <outline text="Feed 2" xmlUrl="https://example.com/dup.xml"/>
  </body>
</opml>''';
      final urls = service.extractFeedUrls(opml);
      expect(urls.length, 1);
    });

    test('trims whitespace from xmlUrl', () {
      final opml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="1.0">
  <body>
    <outline text="Feed" xmlUrl="  https://example.com/spaced.xml  "/>
  </body>
</opml>''';
      final urls = service.extractFeedUrls(opml);
      expect(urls, contains('https://example.com/spaced.xml'));
    });

    test('returns empty list for OPML with no feeds', () {
      final opml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="1.0">
  <head><title>Empty</title></head>
  <body/>
</opml>''';
      final urls = service.extractFeedUrls(opml);
      expect(urls, isEmpty);
    });
  });

  group('buildOpml', () {
    test('generates valid OPML with feeds', () {
      final feeds = [
        Feed(url: 'https://example.com/feed1.xml', title: 'Feed 1'),
        Feed(url: 'https://example.com/feed2.xml', title: 'Feed 2'),
      ];
      final opml = service.buildOpml(feeds);
      expect(opml, contains('<?xml version="1.0"'));
      expect(opml, contains('<opml version="1.0"'));
      expect(opml, contains('xmlUrl="https://example.com/feed1.xml"'));
      expect(opml, contains('xmlUrl="https://example.com/feed2.xml"'));
      expect(opml, contains('title="Feed 1"'));
      expect(opml, contains('title="Feed 2"'));
    });

    test('round-trips feeds through buildOpml and extractFeedUrls', () {
      final feeds = [
        Feed(url: 'https://example.com/a.xml', title: 'Feed A'),
        Feed(url: 'https://example.com/b.xml', title: 'Feed B'),
      ];
      final opml = service.buildOpml(feeds);
      final urls = service.extractFeedUrls(opml);
      expect(urls, contains('https://example.com/a.xml'));
      expect(urls, contains('https://example.com/b.xml'));
    });

    test('handles empty feed list', () {
      final opml = service.buildOpml([]);
      expect(opml, contains('<opml version="1.0"'));
      expect(opml, contains('</opml>'));
    });

    test('escapes double quotes in titles', () {
      final feeds = [
        Feed(url: 'https://example.com/feed.xml', title: 'Test "Feed" Title'),
      ];
      final opml = service.buildOpml(feeds);
      expect(opml, contains("title=\"Test 'Feed' Title\""));
    });
  });
}
