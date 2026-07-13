import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:aware/config.dart';
import 'package:aware/services/api_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late ApiService service;
  late MockHttpClient mockClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    mockClient = MockHttpClient();
    service = ApiService(client: mockClient);
  });

  group('no-server path', () {
    test('login returns null token/user when no server', () async {
      final result = await service.login('a@b.com', 'pwd');
      expect(result['token'], isNull);
      expect(result['user'], isNull);
    });

    test('register returns null token/user when no server', () async {
      final result = await service.register('a@b.com', 'pwd');
      expect(result['token'], isNull);
      expect(result['user'], isNull);
    });

    test('getMarketplaceCategories returns empty list when no server', () async {
      final result = await service.getMarketplaceCategories();
      expect(result, isEmpty);
    });

    test('getMarketplaceFeeds returns empty when no server', () async {
      final result = await service.getMarketplaceFeeds('tech', 0, 10);
      expect(result['feeds'], isEmpty);
      expect(result['total'], 0);
    });

    test('proxyFeed throws when no server', () async {
      expect(
        () => service.proxyFeed('https://example.com'),
        throwsA(isA<StateError>()),
      );
    });

    test('syncState returns empty when no server', () async {
      final result = await service.syncState('token', read: [], starred: []);
      expect(result, isEmpty);
    });

    test('getSyncChanges returns empty when no server', () async {
      final result = await service.getSyncChanges('token');
      expect(result['changes'], isEmpty);
    });
  });

  group('server path', () {
    setUp(() {
      AppConfig.setTestServerUrl('https://api.example.com');
    });

    test('proxyFeed returns response body on success', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response('feed xml content', 200),
      );

      final result = await service.proxyFeed('https://example.com/feed.xml');
      expect(result, 'feed xml content');
    });

    test('getMarketplaceCategories returns parsed JSON', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response('["tech","news"]', 200),
      );

      final result = await service.getMarketplaceCategories();
      expect(result, ['tech', 'news']);
    });

    test('login returns parsed response on success', () async {
      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(
                '{"token":"t1","user":{"email":"a@b.com"}}',
                200,
              ));

      final result = await service.login('a@b.com', 'pwd');

      expect(result['token'], 't1');
      expect(result['user']['email'], 'a@b.com');
    });

    test('login throws on non-200 status', () async {
      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Unauthorized', 401));

      expect(
        () => service.login('a@b.com', 'pwd'),
        throwsA(isA<Exception>()),
      );
    });

    test('register returns parsed response on success', () async {
      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(
                '{"token":"t2","user":{"email":"b@c.com"}}',
                200,
              ));

      final result = await service.register('b@c.com', 'pwd');

      expect(result['token'], 't2');
      expect(result['user']['email'], 'b@c.com');
    });

    test('register throws on non-200 status', () async {
      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Conflict', 409));

      expect(
        () => service.register('b@c.com', 'pwd'),
        throwsA(isA<Exception>()),
      );
    });

    test('getMarketplaceFeeds returns parsed JSON', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response('{"feeds":[],"total":0}', 200),
      );

      final result = await service.getMarketplaceFeeds('tech', 0, 10);

      expect(result['feeds'], isEmpty);
      expect(result['total'], 0);
    });

    test('syncState sends auth header and read/starred lists', () async {
      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('{}', 200));

      final result = await service.syncState('my-token', read: ['g1'], starred: ['g2']);

      expect(result, {});
      verify(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .called(1);
    });

    test('getSyncChanges returns parsed response', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{"changes":[]}', 200));

      final result = await service.getSyncChanges('my-token');

      expect(result['changes'], isEmpty);
      verify(() => mockClient.get(any(), headers: any(named: 'headers')))
          .called(1);
    });

    test('getSyncChanges with lastSync includes query param', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{"changes":[]}', 200));

      await service.getSyncChanges('my-token', lastSync: '2024-01-01');

      verify(() => mockClient.get(any(), headers: any(named: 'headers')))
          .called(1);
    });
  });
}
