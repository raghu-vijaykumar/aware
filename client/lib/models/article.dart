class Article {
  final int? id;
  final int feedId;
  final String guid;
  final String? url;
  final String? title;
  final String? summary;
  final String? content;
  final String? author;
  final int? publishedAt;
  final int? fetchedAt;
  final String? imageUrl;
  final String? rawData;

  Article({
    this.id,
    required this.feedId,
    required this.guid,
    this.url,
    this.title,
    this.summary,
    this.content,
    this.author,
    this.publishedAt,
    this.fetchedAt,
    this.imageUrl,
    this.rawData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'feed_id': feedId,
      'guid': guid,
      'url': url,
      'title': title,
      'summary': summary,
      'content': content,
      'author': author,
      'published_at': publishedAt,
      'fetched_at': fetchedAt,
      'image_url': imageUrl,
      'raw_data': rawData,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'],
      feedId: map['feed_id'],
      guid: map['guid'],
      url: map['url'],
      title: map['title'],
      summary: map['summary'],
      content: map['content'],
      author: map['author'],
      publishedAt: map['published_at'],
      fetchedAt: map['fetched_at'],
      imageUrl: map['image_url'],
      rawData: map['raw_data'],
    );
  }

  Article copyWith({
    int? id,
    int? feedId,
    String? guid,
    String? url,
    String? title,
    String? summary,
    String? content,
    String? author,
    int? publishedAt,
    int? fetchedAt,
    String? imageUrl,
    String? rawData,
  }) {
    return Article(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      guid: guid ?? this.guid,
      url: url ?? this.url,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      author: author ?? this.author,
      publishedAt: publishedAt ?? this.publishedAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      rawData: rawData ?? this.rawData,
    );
  }
}
