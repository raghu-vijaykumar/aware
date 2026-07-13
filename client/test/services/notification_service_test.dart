import 'package:flutter_test/flutter_test.dart';

import 'package:aware/services/notification_service.dart';

void main() {
  group('NotificationService', () {
    group('showNewArticles', () {
      test('no-ops when count is zero', () async {
        await NotificationService.showNewArticles(0);
      });

      test('no-ops when count is negative', () async {
        await NotificationService.showNewArticles(-1);
      });

      test('handles positive count without crashing', () async {
        await NotificationService.showNewArticles(3);
      });
    });


  });
}
