class UserArticleState {
  final int? id;
  final String articleGuid;
  final int? readAt;
  final int? starredAt;
  final String? tags;

  UserArticleState({
    this.id,
    required this.articleGuid,
    this.readAt,
    this.starredAt,
    this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'article_guid': articleGuid,
      'read_at': readAt,
      'starred_at': starredAt,
      'tags': tags,
    };
  }

  factory UserArticleState.fromMap(Map<String, dynamic> map) {
    return UserArticleState(
      id: map['id'],
      articleGuid: map['article_guid'],
      readAt: map['read_at'],
      starredAt: map['starred_at'],
      tags: map['tags'],
    );
  }
}
