import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:aware/models/article.dart';
import 'package:aware/services/feed_service.dart';

import 'package:readability/article.dart' as readability_article;
import 'package:readability/readability.dart' as readability;

import 'package:aware/services/feed_service.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class MockReadability extends Mock implements ReadabilityClient {}

void main() {
  late FeedService service;
  late MockHttpClient mockClient;
  late MockReadability mockReadability;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://fallback.example.com'));
  });

  setUp(() {
    mockClient = MockHttpClient();
    mockReadability = MockReadability();
    service = FeedService(client: mockClient, readability: mockReadability);
    when(() => mockReadability.parseAsync(any()))
        .thenThrow(Exception('readability unavailable'));
  });

  group('DefaultReadabilityClient', () {
    test('implements ReadabilityClient', () {
      expect(DefaultReadabilityClient(), isA<ReadabilityClient>());
    });

    // parseAsync cannot be tested in standard test environment because
    // the readability package loads a native DLL at call time, which is
    // unavailable on most CI/test runners (see readability.dll error).
  });

  group('URL validation', () {
    test('throws ArgumentError for empty URL', () {
      expect(
        () => service.fetchFeedMetadata(''),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for invalid URL', () {
      expect(
        () => service.fetchFeedMetadata('not-a-url'),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for unsupported scheme', () {
      expect(
        () => service.fetchFeedMetadata('ftp://example.com/feed.xml'),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for scheme with no authority', () {
      expect(
        () => service.fetchFeedMetadata('file:///tmp/test.xml'),
        throwsArgumentError,
      );
    });
  });

  group('fetchFeedMetadata', () {
    test('parses RSS feed metadata correctly', () async {
      final xml = '''
        <?xml version="1.0"?>
        <rss version="2.0">
          <channel>
            <title>Test Feed</title>
            <description>A test feed description</description>
            <link>https://example.com</link>
          </channel>
        </rss>
      ''';
      when(() => mockClient.get(Uri.parse('https://example.com/feed.xml')))
          .thenAnswer((_) async => http.Response(xml, 200));

      final feed = await service.fetchFeedMetadata('https://example.com/feed.xml');
      expect(feed.title, 'Test Feed');
      expect(feed.description, 'A test feed description');
      expect(feed.siteUrl, 'https://example.com');
      expect(feed.url, 'https://example.com/feed.xml');
    });

    test('throws on non-200 response', () async {
      when(() => mockClient.get(Uri.parse('https://example.com/error.xml')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () => service.fetchFeedMetadata('https://example.com/error.xml'),
        throwsException,
      );
    });

    test('handles missing title gracefully', () async {
      final xml = '''
        <?xml version="1.0"?>
        <rss version="2.0">
          <channel>
            <link>https://example.com</link>
          </channel>
        </rss>
      ''';
      when(() => mockClient.get(Uri.parse('https://example.com/no-title.xml')))
          .thenAnswer((_) async => http.Response(xml, 200));

      final feed = await service.fetchFeedMetadata('https://example.com/no-title.xml');
      expect(feed.title, isNull);
    });
  });

  group('_parseDate (via fetchArticles)', () {
    Future<List<Article>> _articlesWithDate(String dateStr) async {
      final xml = '''
        <?xml version="1.0"?>
        <rss version="2.0">
          <channel>
            <item>
              <title>Test Article</title>
              <guid>date-test-guid</guid>
              <pubDate>$dateStr</pubDate>
            </item>
          </channel>
        </rss>
      ''';
      when(() => mockClient.get(Uri.parse('https://example.com/date-feed.xml')))
          .thenAnswer((_) async => http.Response(xml, 200));
      return service.fetchArticles('https://example.com/date-feed.xml');
    }

    test('parses RFC-2822 date with timezone', () async {
      final articles = await _articlesWithDate('Mon, 02 Mar 2026 20:00:39 +0000');
      expect(articles.first.publishedAt, isNotNull);
    });

    test('parses RFC-2822 date with GMT', () async {
      final articles = await _articlesWithDate('Fri, 27 Feb 2026 17:01:01 GMT');
      expect(articles.first.publishedAt, isNotNull);
    });

    test('parses ISO-8601 date', () async {
      final articles = await _articlesWithDate('2026-02-27T17:01:01.584Z');
      expect(articles.first.publishedAt, isNotNull);
    });

    test('parses ISO-8601 date without milliseconds', () async {
      final articles = await _articlesWithDate('2026-02-27T17:01:01Z');
      expect(articles.first.publishedAt, isNotNull);
    });

    test('parses date without timezone', () async {
      final articles = await _articlesWithDate('2026-02-27 17:01:01');
      expect(articles.first.publishedAt, isNotNull);
    });

    test('parses date-only format', () async {
      final articles = await _articlesWithDate('2026-02-27');
      expect(articles.first.publishedAt, isNotNull);
    });

    test('parses HTTP-date format', () async {
      final articles = await _articlesWithDate('Thu, 01 Dec 2024 16:00:00 GMT');
      expect(articles.first.publishedAt, isNotNull);
    });

    test('returns null publishedAt for unparseable date', () async {
      final articles = await _articlesWithDate('not-a-date');
      expect(articles.first.publishedAt, isNull);
    });

    test('handles empty date string', () async {
      final articles = await _articlesWithDate('');
      expect(articles.first.publishedAt, isNull);
    });
  });

  group('fetchArticles', () {
    test('parses RSS items into articles', () async {
      final xml = '''
        <?xml version="1.0"?>
        <rss version="2.0">
          <channel>
            <item>
              <title>Article One</title>
              <guid>guid-1</guid>
              <link>https://example.com/article-1</link>
              <description>A summary</description>
              <author>Author Name</author>
              <pubDate>Mon, 01 Jan 2024 12:00:00 GMT</pubDate>
            </item>
            <item>
              <title>Article Two</title>
              <guid>guid-2</guid>
              <link>https://example.com/article-2</link>
            </item>
          </channel>
        </rss>
      ''';
      when(() => mockClient.get(Uri.parse('https://example.com/rss-feed.xml')))
          .thenAnswer((_) async => http.Response(xml, 200));

      final articles = await service.fetchArticles('https://example.com/rss-feed.xml');
      expect(articles.length, 2);
      expect(articles[0].title, 'Article One');
      expect(articles[0].guid, 'guid-1');
      expect(articles[0].url, 'https://example.com/article-1');
      expect(articles[0].summary, 'A summary');
      expect(articles[0].author, 'Author Name');
      expect(articles[0].publishedAt, isNotNull);
      expect(articles[1].title, 'Article Two');
    });

    test('parses Atom entries into articles', () async {
      final xml = '''
        <?xml version="1.0"?>
        <feed xmlns="http://www.w3.org/2005/Atom">
          <entry>
            <title>Atom Article</title>
            <id>atom-guid-1</id>
            <link href="https://example.com/atom-article"/>
            <summary>Atom summary</summary>
            <published>2026-01-15T10:00:00Z</published>
            <author><name>Atom Author</name></author>
          </entry>
        </feed>
      ''';
      when(() => mockClient.get(Uri.parse('https://example.com/atom-feed.xml')))
          .thenAnswer((_) async => http.Response(xml, 200));

      final articles = await service.fetchArticles('https://example.com/atom-feed.xml');
      expect(articles.length, 1);
      expect(articles[0].title, 'Atom Article');
      expect(articles[0].guid, 'atom-guid-1');
      expect(articles[0].url, 'https://example.com/atom-article');
      expect(articles[0].summary, 'Atom summary');
      expect(articles[0].publishedAt, isNotNull);
    });

    test('parses content:encoded as content', () async {
      final xml = '''
        <?xml version="1.0"?>
        <rss version="2.0">
          <channel>
            <item>
              <title>Content Test</title>
              <guid>content-guid</guid>
              <content:encoded><![CDATA[<p>Full HTML content</p>]]></content:encoded>
            </item>
          </channel>
        </rss>
      ''';
      when(() => mockClient.get(Uri.parse('https://example.com/content-feed.xml')))
          .thenAnswer((_) async => http.Response(xml, 200));

      final articles = await service.fetchArticles('https://example.com/content-feed.xml');
      expect(articles[0].content, '<p>Full HTML content</p>');
    });

    test('extracts image from enclosure', () async {
      final xml = '''
        <?xml version="1.0"?>
        <rss version="2.0">
          <channel>
            <item>
              <title>Image Test</title>
              <guid>img-guid</guid>
              <enclosure url="https://example.com/image.jpg" type="image/jpeg"/>
            </item>
          </channel>
        </rss>
      ''';
      when(() => mockClient.get(Uri.parse('https://example.com/image-feed.xml')))
          .thenAnswer((_) async => http.Response(xml, 200));

      final articles = await service.fetchArticles('https://example.com/image-feed.xml');
      expect(articles[0].imageUrl, 'https://example.com/image.jpg');
    });

    test('extracts image from media:content', () async {
      final xml = '''
        <?xml version="1.0"?>
        <rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
          <channel>
            <item>
              <title>Media Content Test</title>
              <guid>media-guid</guid>
              <media:content url="https://example.com/media.jpg"/>
            </item>
          </channel>
        </rss>
      ''';
      when(() => mockClient.get(Uri.parse('https://example.com/media-feed.xml')))
          .thenAnswer((_) async => http.Response(xml, 200));

      final articles = await service.fetchArticles('https://example.com/media-feed.xml');
      expect(articles[0].imageUrl, 'https://example.com/media.jpg');
    });

    test('extracts image from HTML content fallback', () async {
      final xml = '''
        <?xml version="1.0"?>
        <rss version="2.0">
          <channel>
            <item>
              <title>HTML Image Test</title>
              <guid>html-img-guid</guid>
              <content:encoded><![CDATA[<img src="https://example.com/inline.png"/>]]></content:encoded>
            </item>
          </channel>
        </rss>
      ''';
      when(() => mockClient.get(Uri.parse('https://example.com/html-img-feed.xml')))
          .thenAnswer((_) async => http.Response(xml, 200));

      final articles = await service.fetchArticles('https://example.com/html-img-feed.xml');
      expect(articles[0].imageUrl, 'https://example.com/inline.png');
    });

    test('handles non-200 response', () async {
      when(() => mockClient.get(Uri.parse('https://example.com/bad.xml')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () => service.fetchArticles('https://example.com/bad.xml'),
        throwsException,
      );
    });

    test('handles malformed XML', () async {
      when(() => mockClient.get(Uri.parse('https://example.com/bad-xml.xml')))
          .thenAnswer((_) async => http.Response('not xml at all', 200));

      expect(
        () => service.fetchArticles('https://example.com/bad-xml.xml'),
        throwsException,
      );
    });
  });

  group('fetchFullArticle', () {
    test('uses readability when available', () async {
      when(() => mockReadability.parseAsync(any())).thenAnswer((_) async =>
          readability_article.Article(
            title: null,
            author: null,
            length: 0,
            excerpt: null,
            siteName: null,
            imageUrl: null,
            faviconUrl: null,
            content: '<p>Readable content</p>',
            textContent: null,
            language: null,
            publishedTime: null,
          ));

      final result = await service.fetchFullArticle('https://example.com/article');
      expect(result, '<p>Readable content</p>');
    });

    test('removes noise and aside elements from readability content', () async {
      when(() => mockReadability.parseAsync(any())).thenAnswer((_) async =>
          readability_article.Article(
            title: null,
            author: null,
            length: 0,
            excerpt: null,
            siteName: null,
            imageUrl: null,
            faviconUrl: null,
            content: '<html><body><aside>Sidebar</aside><div class="trending">Noise</div><p>Main text</p></body></html>',
            textContent: null,
            language: null,
            publishedTime: null,
          ));

      final result = await service.fetchFullArticle('https://example.com/article');
      expect(result, isNot(contains('Sidebar')));
      expect(result, isNot(contains('Noise')));
      expect(result, contains('Main text'));
    });

    test('falls back to HTTP when readability returns empty content', () async {
      when(() => mockReadability.parseAsync(any())).thenAnswer((_) async =>
          readability_article.Article(
            title: null,
            author: null,
            length: 0,
            excerpt: null,
            siteName: null,
            imageUrl: null,
            faviconUrl: null,
            content: null,
            textContent: null,
            language: null,
            publishedTime: null,
          ));
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                '<html><body><article>Fallback content</article></body></html>',
                200,
              ));

      final result = await service.fetchFullArticle('https://example.com/article');
      expect(result, 'Fallback content');
    });

    test('returns null when HTTP request fails', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      final result = await service.fetchFullArticle('https://example.com/article');

      expect(result, isNull);
    });

    test('returns null when HTTP throws', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('Network error'));

      final result = await service.fetchFullArticle('https://example.com/article');

      expect(result, isNull);
    });

    test('extracts content from article tag', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                '<html><body><article>Article content</article></body></html>',
                200,
              ));

      final result = await service.fetchFullArticle('https://example.com/article');

      expect(result, 'Article content');
    });

    test('extracts content from role=main', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                '<html><body><div role="main">Main content</div></body></html>',
                200,
              ));

      final result = await service.fetchFullArticle('https://example.com/article');

      expect(result, 'Main content');
    });

    test('extracts content from main tag', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                '<html><body><main>Main element</main></body></html>',
                200,
              ));

      final result = await service.fetchFullArticle('https://example.com/article');

      expect(result, 'Main element');
    });

    test('extracts content from content class', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                '<html><body><div class="post-content">Post body</div></body></html>',
                200,
              ));

      final result = await service.fetchFullArticle('https://example.com/article');

      expect(result, 'Post body');
    });

    test('returns null when no container found', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                '<html><body><div>No article here</div></body></html>',
                200,
              ));

      final result = await service.fetchFullArticle('https://example.com/article');

      expect(result, isNull);
    });

  });
}
