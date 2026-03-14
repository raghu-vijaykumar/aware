import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/article.dart';
import '../models/feed.dart';

class FeedService {
  final http.Client _client;

  FeedService({http.Client? client}) : _client = client ?? http.Client();

  Future<Feed> fetchFeedMetadata(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch feed');
    }

    final document = XmlDocument.parse(response.body);
    final channelElements = document.findAllElements('channel');
    final channel = channelElements.isNotEmpty ? channelElements.first : null;

    final title = channel?.getElement('title')?.innerText ?? '';
    final description = channel?.getElement('description')?.innerText;
    final link = channel?.getElement('link')?.innerText;

    return Feed(
      url: url,
      title: title.isNotEmpty ? title : null,
      description: description,
      siteUrl: link,
    );
  }

  Future<List<Article>> fetchArticles(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch feed articles');
    }

    final document = XmlDocument.parse(response.body);
    final items = <XmlElement>[];

    if (document.findAllElements('item').isNotEmpty) {
      items.addAll(document.findAllElements('item'));
    }
    if (document.findAllElements('entry').isNotEmpty) {
      items.addAll(document.findAllElements('entry'));
    }

    final articles = items.map((item) {
      final guidElem = item.getElement('guid') ?? item.getElement('id');
      final title = item.getElement('title')?.innerText ?? '';
      final link = item.getElement('link')?.innerText ??
          item.getElement('link')?.getAttribute('href') ??
          '';
      final publishedText = item.getElement('pubDate')?.innerText ??
          item.getElement('published')?.innerText;
      final publishedAt = publishedText != null
          ? DateTime.tryParse(publishedText)?.millisecondsSinceEpoch
          : null;
      final summary = item.getElement('description')?.innerText ??
          item.getElement('summary')?.innerText;
      final content = item.getElement('content:encoded')?.innerText ??
          item.getElement('content')?.innerText;
      final author = item.getElement('author')?.innerText ??
          item.getElement('dc:creator')?.innerText;
      String? imageUrl = item
          .findAllElements('enclosure')
          .firstWhere(
            (e) => e.getAttribute('type')?.startsWith('image/') == true,
            orElse: () => XmlElement(XmlName('')),
          )
          .getAttribute('url');

      imageUrl ??= item.getElement('media:content')?.getAttribute('url');
      imageUrl ??= item.getElement('media:thumbnail')?.getAttribute('url');

      if (imageUrl == null && (content?.isNotEmpty ?? false)) {
        final regex =
            RegExp("<img[^>]+src=[\"']([^\"']+)[\"']", caseSensitive: false);
        final imgMatch = regex.firstMatch(content!);
        imageUrl = imgMatch?.group(1);
      }

      return Article(
        feedId: 0,
        guid: guidElem?.innerText ?? link,
        url: link.isNotEmpty ? link : null,
        title: title.isNotEmpty ? title : null,
        summary: summary,
        content: content,
        author: author,
        publishedAt: publishedAt,
        fetchedAt: DateTime.now().millisecondsSinceEpoch,
        imageUrl: imageUrl,
        rawData: response.body,
      );
    }).toList();

    return articles;
  }
}
