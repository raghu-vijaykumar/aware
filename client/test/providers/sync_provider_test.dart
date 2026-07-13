import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aware/models/user_article_state.dart';
import 'package:aware/providers/auth_provider.dart';
import 'package:aware/providers/sync_provider.dart';
import 'package:aware/services/api_service.dart';
import 'package:aware/services/database_service.dart';
import 'package:aware/config.dart';

class MockApiService extends Mock implements ApiService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class FakeAuthProvider extends AuthProvider {
  FakeAuthProvider({bool loggedIn = true, String token = 'test-token'})
      : _loggedIn = loggedIn,
        _token = token;

  final bool _loggedIn;
  final String _token;

  @override
  bool get isLoggedIn => _loggedIn;

  @override
  String? get authToken => _token;

  @override
  bool get isAvailable => true;
}

void main() {
  late MockApiService mockApi;
  late MockDatabaseService mockDb;
  late FakeAuthProvider fakeAuth;
  late SyncProvider provider;

  setUp(() {
    AppConfig.setTestServerUrl('https://test.example.com');
    mockApi = MockApiService();
    mockDb = MockDatabaseService();
    fakeAuth = FakeAuthProvider();
    provider = SyncProvider(api: mockApi, db: mockDb);
  });

  group('SyncProvider', () {
    test('starts with isSyncing false', () {
      expect(provider.isSyncing, isFalse);
    });

    test('syncState no-ops when server unavailable', () async {
      AppConfig.setTestServerUrl('');
      provider = SyncProvider(api: mockApi, db: mockDb);

      await provider.syncState(fakeAuth);

      verifyNever(() => mockApi.syncState(any(), read: any(named: 'read'), starred: any(named: 'starred')));
    });

    test('syncState no-ops when not logged in', () async {
      fakeAuth = FakeAuthProvider(loggedIn: false);

      await provider.syncState(fakeAuth);

      verifyNever(() => mockApi.syncState(any(), read: any(named: 'read'), starred: any(named: 'starred')));
    });

    test('syncState partitions read and starred states and calls API', () async {
      when(() => mockDb.getAllUserState()).thenAnswer((_) async => <UserArticleState>[
            UserArticleState(articleGuid: 'read-1', readAt: 100),
            UserArticleState(articleGuid: 'read-2', readAt: 200),
            UserArticleState(articleGuid: 'star-1', starredAt: 300),
            UserArticleState(articleGuid: 'both', readAt: 50, starredAt: 400),
            UserArticleState(articleGuid: 'none'),
          ]);
      when(() => mockApi.syncState(any(), read: any(named: 'read'), starred: any(named: 'starred')))
          .thenAnswer((_) async => {});

      await provider.syncState(fakeAuth);

      verify(() => mockApi.syncState(
        'test-token',
        read: ['read-1', 'read-2', 'both'],
        starred: ['star-1', 'both'],
      )).called(1);
    });

    test('syncState sets isSyncing during sync', () async {
      when(() => mockDb.getAllUserState()).thenAnswer((_) async => <UserArticleState>[]);
      when(() => mockApi.syncState(any(), read: any(named: 'read'), starred: any(named: 'starred')))
          .thenAnswer((_) async => {});

      expect(provider.isSyncing, isFalse);

      await provider.syncState(fakeAuth);

      expect(provider.isSyncing, isFalse);
    });
  });
}
