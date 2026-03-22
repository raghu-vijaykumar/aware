import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const String _channelId = 'aware_feed_updates';
  static const String _channelName = 'Feed updates';
  static const int _summaryNotificationId = 1001;
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized || kIsWeb) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings);

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Notifies you when new articles arrive',
      importance: Importance.defaultImportance,
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(androidChannel);
    await androidImpl?.requestNotificationsPermission();

    _initialized = true;
  }

  static Future<void> showNewArticles(int count) async {
    if (count <= 0) return;
    if (!_initialized && !kIsWeb) {
      await ensureInitialized();
    }
    if (kIsWeb) return;

    // Wait for initialization to complete before showing notification
    if (!_initialized) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final title =
        count == 1 ? 'Fetched 1 new article' : 'Fetched $count new articles';
    const body = 'Ready to read — open Aware to start.';

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        styleInformation: BigTextStyleInformation(body),
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'New articles',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _plugin.show(
        _summaryNotificationId,
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      // Log the error but don't crash the background task
      print('Notification error: $e');
    }
  }
}
