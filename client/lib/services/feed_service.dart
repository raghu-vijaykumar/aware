import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';
import 'package:readability/readability.dart' as readability;
import 'package:readability/article.dart' as readability_article;
import 'package:xml/xml.dart';

import '../models/article.dart';
import '../models/feed.dart';

/// Wraps the readability package so it can be injected in tests.
abstract class ReadabilityClient {
  Future<readability_article.Article> parseAsync(String url);
}

class DefaultReadabilityClient implements ReadabilityClient {
  @override
  Future<readability_article.Article> parseAsync(String url) =>
      readability.parseAsync(url);
}

class FeedService {
  final http.Client _client;
  final ReadabilityClient _readability;

  FeedService({http.Client? client, ReadabilityClient? readability})
      : _client = client ?? http.Client(),
        _readability = readability ?? DefaultReadabilityClient();

  void _validateUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw ArgumentError('Invalid feed URL: $url');
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw ArgumentError('Only http and https URLs are supported: $url');
    }
  }

  Future<Feed> fetchFeedMetadata(String url) async {
    _validateUrl(url);
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
    _validateUrl(url);
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
      final linkEl = item.getElement('link');
      final linkText = linkEl?.innerText ?? '';
      final link = linkText.isNotEmpty
          ? linkText
          : linkEl?.getAttribute('href') ?? '';
      final publishedText = item.getElement('pubDate')?.innerText ??
          item.getElement('published')?.innerText ??
          item.getElement('updated')?.innerText ??
          item.getElement('dc:date')?.innerText ??
          item.getElement('date')?.innerText;
      final publishedAt = publishedText != null
          ? _parseDate(publishedText)?.millisecondsSinceEpoch
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
        // Prefer rich HTML body; fall back to summary; lastly the item XML.
        rawData: content ?? summary ?? item.toXmlString(),
      );
    }).toList();

    return articles;
  }

  Future<String?> fetchFullArticle(String url) async {
    try {
      final article = await _readability.parseAsync(url);
      if (article.content != null && article.content!.isNotEmpty) {
        print('[FeedService] readability extracted ${article.content!.length} chars from $url');
        final doc = html_parser.parse(article.content!);
        for (final node in doc.querySelectorAll('aside')) {
          node.remove();
        }
        const noisePatterns = [
          'trending', 'sidebar', 'widget', 'popular', 'latest-news',
          'most-read', 'also-read', 'recommended', 'related',
          'aside', 'secondary', 'must-read', 'you-may-also-like',
          'in-content-related',
        ];
        for (final el in doc.querySelectorAll('*')) {
          final cl = el.className.toLowerCase();
          final id = (el.attributes['id'] ?? '').toLowerCase();
          if (noisePatterns.any((p) => cl.contains(p) || id.contains(p))) {
            el.remove();
          }
        }
        final cleaned = doc.body?.innerHtml ?? article.content!;
        print('[FeedService] cleaned content: ${cleaned.length} chars');
        return cleaned;
      }
      print('[FeedService] readability returned empty content for $url');
    } catch (e) {
      print('[FeedService] readability parseAsync failed for $url: $e');
    }

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.230 Mobile Safari/537.36',
        },
      );
      if (response.statusCode != 200) {
        print('[FeedService] HTTP ${response.statusCode} for $url');
        return null;
      }
      final doc = html_parser.parse(response.body);
      var container = doc.querySelector('article');
      container ??= doc.querySelector('[role="main"]');
      container ??= doc.querySelector('main');
      container ??= doc.querySelector('.post-content, .entry-content, .article-content, .story-body');
      if (container != null) {
        return container.innerHtml;
      }
      print('[FeedService] no article container found in $url');
    } catch (e) {
      print('[FeedService] fallback HTTP fetch failed for $url: $e');
    }

    return null;
  }

  DateTime? _parseDate(String raw) {
    final value = raw.trim();

    // Try ISO-8601 first (covers Atom <updated> like 2026-02-27T17:01:01.584Z).
    final iso = DateTime.tryParse(value);
    if (iso != null) return iso.toLocal();

    // Common RSS/Atom/HTTP date formats (ordered by likelihood).
    const patternsWithZone = [
      "EEE, dd MMM yyyy HH:mm:ss Z", // Mon, 02 Mar 2026 20:00:39 +0000
      "EEE, dd MMM yyyy HH:mm:ss zzz", // Fri, 27 Feb 2026 17:01:01 GMT
      "EEE, dd MMM yyyy HH:mm Z",
      "EEE, dd MMM yyyy HH:mm zzz",
      "dd MMM yyyy HH:mm:ss Z",
      "dd MMM yyyy HH:mm:ss zzz",
      "yyyy-MM-dd'T'HH:mm:ss.SSSZ", // 2026-02-27T17:01:01.584Z
      "yyyy-MM-dd'T'HH:mm:ssZ",
      "yyyy-MM-dd HH:mm:ss Z",
      "yyyy-MM-dd HH:mm Z",
    ];

    for (final pattern in patternsWithZone) {
      try {
        return DateFormat(pattern, 'en_US').parseUtc(value).toLocal();
      } catch (_) {}
    }

    const patternsNoZone = [
      "EEE, dd MMM yyyy HH:mm:ss",
      "EEE, dd MMM yyyy HH:mm",
      "yyyy-MM-dd'T'HH:mm:ss",
      "yyyy-MM-dd HH:mm:ss",
      "yyyy-MM-dd HH:mm",
      "yyyy-MM-dd",
    ];

    for (final pattern in patternsNoZone) {
      try {
        return DateFormat(pattern, 'en_US').parse(value, true).toLocal();
      } catch (_) {}
    }

    // Fallback to HTTP-date parser (GMT only).
    try {
      return HttpDate.parse(value).toLocal();
    } catch (_) {}

    return null;
  }
}
