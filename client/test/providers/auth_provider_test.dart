import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aware/providers/auth_provider.dart';
import 'package:aware/services/api_service.dart';
import 'package:aware/services/storage_service.dart';
import 'package:aware/config.dart';

class MockApiService extends Mock implements ApiService {}
class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockApiService mockApi;
  late AuthProvider provider;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{};
        }
        // setString, setInt, setBool, etc. and remove/clear all return bool
        return true;
      },
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      null,
    );
  });

  setUp(() {
    AppConfig.setTestServerUrl('https://test.example.com');
    mockApi = MockApiService();
    provider = AuthProvider(api: mockApi);
  });

  group('AuthProvider', () {
    test('starts with no auth token or email', () {
      expect(provider.isLoggedIn, isFalse);
      expect(provider.authToken, isNull);
      expect(provider.userEmail, isNull);
    });

    test('isLoggedIn returns true when token is set', () async {
      when(() => mockApi.login(any(), any()))
          .thenAnswer((_) async => {'token': 'test-token', 'user': {'email': 'test@example.com'}});

      await provider.login('test@example.com', 'password');

      expect(provider.isLoggedIn, isTrue);
      expect(provider.authToken, 'test-token');
      expect(provider.userEmail, 'test@example.com');
    });

    test('login no-ops when server is unavailable', () async {
      AppConfig.setTestServerUrl('');
      provider = AuthProvider(api: mockApi);

      await provider.login('test@example.com', 'password');

      verifyNever(() => mockApi.login(any(), any()));
      expect(provider.isLoggedIn, isFalse);
    });

    test('logout clears auth state', () async {
      when(() => mockApi.login(any(), any()))
          .thenAnswer((_) async => {'token': 'test-token', 'user': {'email': 'test@example.com'}});
      await provider.login('test@example.com', 'password');
      expect(provider.isLoggedIn, isTrue);

      await provider.logout();

      expect(provider.isLoggedIn, isFalse);
      expect(provider.authToken, isNull);
      expect(provider.userEmail, isNull);
    });

    test('login with null token does not persist', () async {
      when(() => mockApi.login(any(), any()))
          .thenAnswer((_) async => {'token': null, 'user': null});

      await provider.login('test@example.com', 'password');

      expect(provider.isLoggedIn, isFalse);
      expect(provider.authToken, isNull);
    });

    test('notifies listeners on login', () async {
      when(() => mockApi.login(any(), any()))
          .thenAnswer((_) async => {'token': 't', 'user': {'email': 'a@b.com'}});
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.login('a@b.com', 'p');

      expect(notifyCount, greaterThan(0));
    });

    test('load restores saved auth state from storage', () async {
      final mockStorage = MockStorageService();
      when(() => mockStorage.read('auth_token'))
          .thenAnswer((_) async => 'saved-token');
      when(() => mockStorage.read('auth_email'))
          .thenAnswer((_) async => 'saved@example.com');

      provider = AuthProvider(api: mockApi, storage: mockStorage);
      await provider.load();

      expect(provider.authToken, 'saved-token');
      expect(provider.userEmail, 'saved@example.com');
      expect(provider.isLoggedIn, isTrue);
    });

    test('load handles null storage values', () async {
      final mockStorage = MockStorageService();
      when(() => mockStorage.read(any())).thenAnswer((_) async => null);

      provider = AuthProvider(api: mockApi, storage: mockStorage);
      await provider.load();

      expect(provider.authToken, isNull);
      expect(provider.userEmail, isNull);
      expect(provider.isLoggedIn, isFalse);
    });

    test('notifies listeners on logout', () async {
      when(() => mockApi.login(any(), any()))
          .thenAnswer((_) async => {'token': 't', 'user': {'email': 'a@b.com'}});
      await provider.login('a@b.com', 'p');

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.logout();

      expect(notifyCount, greaterThan(0));
    });
  });
}
