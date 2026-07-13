import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aware/services/storage_service.dart';

void main() {
  group('StorageService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('write and read round-trip', () async {
      final storage = await StorageService.getInstance();
      await storage.write('test_key', 'hello');
      final value = await storage.read('test_key');
      expect(value, 'hello');
    });

    test('read returns null for missing key', () async {
      final storage = await StorageService.getInstance();
      final value = await storage.read('nonexistent');
      expect(value, isNull);
    });

    test('delete removes value', () async {
      final storage = await StorageService.getInstance();
      await storage.write('del_key', 'to delete');
      await storage.delete('del_key');
      final value = await storage.read('del_key');
      expect(value, isNull);
    });

    test('write overwrites existing value', () async {
      final storage = await StorageService.getInstance();
      await storage.write('overwrite_key', 'first');
      await storage.write('overwrite_key', 'second');
      final value = await storage.read('overwrite_key');
      expect(value, 'second');
    });

    test('multiple keys are isolated', () async {
      final storage = await StorageService.getInstance();
      await storage.write('key_a', 'value_a');
      await storage.write('key_b', 'value_b');
      expect(await storage.read('key_a'), 'value_a');
      expect(await storage.read('key_b'), 'value_b');
    });
  });
}
