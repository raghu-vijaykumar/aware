class Feed {
  final int? id;
  final String url;
  final String? title;
  final String? description;
  final String? siteUrl;
  final String? iconUrl;
  final String? category;
  final String? curator;
  final bool paused;
  final int? lastFetched;
  final String? etag;
  final String? lastModified;

  Feed({
    this.id,
    required this.url,
    this.title,
    this.description,
    this.siteUrl,
    this.iconUrl,
    this.category,
    this.curator,
    this.paused = false,
    this.lastFetched,
    this.etag,
    this.lastModified,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'description': description,
      'site_url': siteUrl,
      'icon_url': iconUrl,
      'category': category,
      'curator': curator,
      'paused': paused ? 1 : 0,
      'last_fetched': lastFetched,
      'etag': etag,
      'last_modified': lastModified,
    };
  }

  factory Feed.fromMap(Map<String, dynamic> map) {
    return Feed(
      id: map['id'],
      url: map['url'],
      title: map['title'],
      description: map['description'],
      siteUrl: map['site_url'],
      iconUrl: map['icon_url'],
      category: map['category'],
      curator: map['curator'],
      paused: (map['paused'] ?? 0) == 1,
      lastFetched: map['last_fetched'],
      etag: map['etag'],
      lastModified: map['last_modified'],
    );
  }
}
