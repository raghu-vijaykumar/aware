class UserArticleState {
  final int? id;
  final String articleGuid;
  final int? readAt;
  final int? likedAt;
  final int? starredAt;
  final String? tags;
  final int? lastAccessedAt;
  final double? readProgress;
  final int? lastParagraphIndex;

  UserArticleState({
    this.id,
    required this.articleGuid,
    this.readAt,
    this.likedAt,
    this.starredAt,
    this.tags,
    this.lastAccessedAt,
    this.readProgress,
    this.lastParagraphIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'article_guid': articleGuid,
      'read_at': readAt,
      'liked_at': likedAt,
      'starred_at': starredAt,
      'tags': tags,
      'last_accessed_at': lastAccessedAt,
      'read_progress': readProgress,
      'last_paragraph_index': lastParagraphIndex,
    };
  }

  factory UserArticleState.fromMap(Map<String, dynamic> map) {
    return UserArticleState(
      id: map['id'],
      articleGuid: map['article_guid'],
      readAt: map['read_at'],
      likedAt: map['liked_at'],
      starredAt: map['starred_at'],
      tags: map['tags'],
      lastAccessedAt: map['last_accessed_at'],
      readProgress: map['read_progress'] != null
          ? (map['read_progress'] as num).toDouble()
          : null,
      lastParagraphIndex: map['last_paragraph_index'],
    );
  }
}
