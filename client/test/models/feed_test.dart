import 'package:flutter_test/flutter_test.dart';
import 'package:aware/models/feed.dart';

void main() {
  group('Feed model', () {
    final sample = Feed(
      id: 1,
      url: 'https://example.com/feed.xml',
      title: 'Test Feed',
      description: 'A test feed description',
      siteUrl: 'https://example.com',
      iconUrl: 'https://example.com/icon.png',
      category: 'tech',
      curator: 'Test Curator',
      paused: true,
      lastFetched: 1700000000000,
      etag: '"abc123"',
      lastModified: 'Mon, 01 Jan 2024 00:00:00 GMT',
    );

    test('toMap produces correct keys', () {
      final map = sample.toMap();
      expect(map['id'], 1);
      expect(map['url'], 'https://example.com/feed.xml');
      expect(map['title'], 'Test Feed');
      expect(map['description'], 'A test feed description');
      expect(map['site_url'], 'https://example.com');
      expect(map['icon_url'], 'https://example.com/icon.png');
      expect(map['category'], 'tech');
      expect(map['curator'], 'Test Curator');
      expect(map['paused'], 1);
      expect(map['last_fetched'], 1700000000000);
      expect(map['etag'], '"abc123"');
      expect(map['last_modified'], 'Mon, 01 Jan 2024 00:00:00 GMT');
    });

    test('fromMap reconstructs Feed correctly', () {
      final map = sample.toMap();
      final restored = Feed.fromMap(map);
      expect(restored.id, sample.id);
      expect(restored.url, sample.url);
      expect(restored.title, sample.title);
      expect(restored.paused, isTrue);
    });

    test('toMap and fromMap round-trip preserves all fields', () {
      final map = sample.toMap();
      final restored = Feed.fromMap(map);
      expect(restored.id, sample.id);
      expect(restored.url, sample.url);
      expect(restored.title, sample.title);
      expect(restored.description, sample.description);
      expect(restored.siteUrl, sample.siteUrl);
      expect(restored.iconUrl, sample.iconUrl);
      expect(restored.category, sample.category);
      expect(restored.curator, sample.curator);
      expect(restored.paused, sample.paused);
      expect(restored.lastFetched, sample.lastFetched);
      expect(restored.etag, sample.etag);
      expect(restored.lastModified, sample.lastModified);
    });

    test('paused is true when map value is 1', () {
      final feed = Feed.fromMap({'url': 'https://example.com/feed.xml', 'paused': 1});
      expect(feed.paused, isTrue);
    });

    test('paused is false when map value is 0', () {
      final feed = Feed.fromMap({'url': 'https://example.com/feed.xml', 'paused': 0});
      expect(feed.paused, isFalse);
    });

    test('paused defaults to false when map value is null', () {
      final feed = Feed.fromMap({'url': 'https://example.com/feed.xml'});
      expect(feed.paused, isFalse);
    });

    test('handles null fields in fromMap', () {
      final feed = Feed.fromMap({'url': 'https://example.com/minimal.xml'});
      expect(feed.url, 'https://example.com/minimal.xml');
      expect(feed.title, isNull);
      expect(feed.description, isNull);
      expect(feed.siteUrl, isNull);
      expect(feed.iconUrl, isNull);
      expect(feed.category, isNull);
      expect(feed.curator, isNull);
      expect(feed.lastFetched, isNull);
      expect(feed.etag, isNull);
      expect(feed.lastModified, isNull);
    });
  });
}
