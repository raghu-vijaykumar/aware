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

    final title = '$count new articles available to read';
    const body = 'Across your subscriptions';

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
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

    await _plugin.show(
      _summaryNotificationId,
      title,
      body,
      notificationDetails,
    );
  }
}
