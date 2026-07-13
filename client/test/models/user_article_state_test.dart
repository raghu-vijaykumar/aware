import 'package:flutter_test/flutter_test.dart';
import 'package:aware/models/user_article_state.dart';

void main() {
  group('UserArticleState model', () {
    final sample = UserArticleState(
      id: 1,
      articleGuid: 'guid-123',
      readAt: 1700000000000,
      likedAt: 1700000100000,
      starredAt: 1700000200000,
      tags: 'test,example',
      lastAccessedAt: 1700000300000,
      readProgress: 0.75,
      lastParagraphIndex: 3,
    );

    test('toMap produces correct keys', () {
      final map = sample.toMap();
      expect(map['id'], 1);
      expect(map['article_guid'], 'guid-123');
      expect(map['read_at'], 1700000000000);
      expect(map['liked_at'], 1700000100000);
      expect(map['starred_at'], 1700000200000);
      expect(map['tags'], 'test,example');
      expect(map['last_accessed_at'], 1700000300000);
      expect(map['read_progress'], 0.75);
      expect(map['last_paragraph_index'], 3);
    });

    test('fromMap reconstructs UserArticleState correctly', () {
      final map = sample.toMap();
      final restored = UserArticleState.fromMap(map);
      expect(restored.id, sample.id);
      expect(restored.articleGuid, sample.articleGuid);
      expect(restored.readAt, sample.readAt);
      expect(restored.readProgress, sample.readProgress);
    });

    test('toMap and fromMap round-trip preserves all fields', () {
      final map = sample.toMap();
      final restored = UserArticleState.fromMap(map);
      expect(restored.id, sample.id);
      expect(restored.articleGuid, sample.articleGuid);
      expect(restored.readAt, sample.readAt);
      expect(restored.likedAt, sample.likedAt);
      expect(restored.starredAt, sample.starredAt);
      expect(restored.tags, sample.tags);
      expect(restored.lastAccessedAt, sample.lastAccessedAt);
      expect(restored.readProgress, sample.readProgress);
      expect(restored.lastParagraphIndex, sample.lastParagraphIndex);
    });

    test('readProgress is converted from num to double', () {
      final state = UserArticleState.fromMap({
        'article_guid': 'guid-456',
        'read_progress': 0.5,
      });
      expect(state.readProgress, isA<double>());
      expect(state.readProgress, 0.5);
    });

    test('readProgress is null when map value is null', () {
      final state = UserArticleState.fromMap({
        'article_guid': 'guid-789',
      });
      expect(state.readProgress, isNull);
    });

    test('handles null fields in fromMap', () {
      final state = UserArticleState.fromMap({
        'article_guid': 'guid-minimal',
      });
      expect(state.articleGuid, 'guid-minimal');
      expect(state.id, isNull);
      expect(state.readAt, isNull);
      expect(state.likedAt, isNull);
      expect(state.starredAt, isNull);
      expect(state.tags, isNull);
      expect(state.lastAccessedAt, isNull);
      expect(state.readProgress, isNull);
      expect(state.lastParagraphIndex, isNull);
    });
  });
}
