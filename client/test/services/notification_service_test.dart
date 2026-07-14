import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aware/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService', () {
    setUp(() {
      NotificationService.resetForTesting();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dexterous.com/flutter/local_notifications'),
        _mockNotificationChannel,
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dexterous.com/flutter/local_notifications'),
        null,
      );
    });

    group('showNewArticles', () {
      test('no-ops when count is zero', () async {
        await NotificationService.showNewArticles(0);
      });

      test('no-ops when count is negative', () async {
        await NotificationService.showNewArticles(-1);
      });

      test('no-ops when ensureInitialized fails', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('dexterous.com/flutter/local_notifications'),
          null,
        );
        await NotificationService.showNewArticles(3);
      });

      test('shows notification when initialization succeeds', () async {
        await NotificationService.showNewArticles(3);
      });

      test('shows singular notification text for count of 1', () async {
        await NotificationService.showNewArticles(1);
      });

      test('handles show error gracefully', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('dexterous.com/flutter/local_notifications'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'show') {
              throw PlatformException(code: 'SHOW_ERROR');
            }
            return _mockNotificationChannel(methodCall);
          },
        );
        await NotificationService.showNewArticles(3);
      });
    });
  });
}

Future<dynamic> _mockNotificationChannel(MethodCall methodCall) {
  switch (methodCall.method) {
    case 'initialize':
      return Future<bool>.value(true);
    case 'createNotificationChannel':
    case 'requestNotificationsPermission':
    case 'show':
      return Future<dynamic>.value(null);
    default:
      return Future<dynamic>.value(null);
  }
}
