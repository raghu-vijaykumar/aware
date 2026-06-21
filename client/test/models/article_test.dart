import 'package:flutter_test/flutter_test.dart';
import 'package:aware/models/article.dart';

void main() {
  group('Article model', () {
    final sample = Article(
      id: 1,
      feedId: 10,
      guid: 'guid-123',
      url: 'https://example.com/article',
      title: 'Test Article',
      summary: 'A short summary',
      content: '<p>Full content</p>',
      author: 'Author Name',
      publishedAt: 1700000000000,
      fetchedAt: 1700000100000,
      imageUrl: 'https://example.com/image.jpg',
    );

    test('toMap produces correct keys', () {
      final map = sample.toMap();
      expect(map['id'], 1);
      expect(map['feed_id'], 10);
      expect(map['guid'], 'guid-123');
      expect(map['title'], 'Test Article');
      expect(map['author'], 'Author Name');
    });

    test('fromMap reconstructs Article correctly', () {
      final map = sample.toMap();
      final restored = Article.fromMap(map);
      expect(restored.id, sample.id);
      expect(restored.guid, sample.guid);
      expect(restored.title, sample.title);
    });

    test('toMap and fromMap round-trip preserves all fields', () {
      final map = sample.toMap();
      final restored = Article.fromMap(map);
      expect(restored.id, sample.id);
      expect(restored.feedId, sample.feedId);
      expect(restored.guid, sample.guid);
      expect(restored.url, sample.url);
      expect(restored.title, sample.title);
      expect(restored.summary, sample.summary);
      expect(restored.content, sample.content);
      expect(restored.author, sample.author);
      expect(restored.publishedAt, 1700000000000);
      expect(restored.fetchedAt, 1700000100000);
      expect(restored.imageUrl, sample.imageUrl);
    });

    test('copyWith overrides specific fields', () {
      final copy = sample.copyWith(title: 'Updated Title');
      expect(copy.id, sample.id);
      expect(copy.title, 'Updated Title');
      expect(copy.feedId, sample.feedId);
    });

    test('copyWith with no args returns same values', () {
      final copy = sample.copyWith();
      expect(copy.id, sample.id);
      expect(copy.title, sample.title);
      expect(copy.guid, sample.guid);
    });

    test('handles null fields in fromMap', () {
      final minimal = Article.fromMap({
        'feed_id': 1,
        'guid': 'minimal-guid',
      });
      expect(minimal.feedId, 1);
      expect(minimal.guid, 'minimal-guid');
      expect(minimal.title, isNull);
      expect(minimal.url, isNull);
    });
  });
}
