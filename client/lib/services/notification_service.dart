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
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings);

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Notifies you when new articles arrive',
      importance: Importance.high,
    );

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final macosImpl = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();

    await androidImpl?.createNotificationChannel(androidChannel);
    await androidImpl?.requestNotificationsPermission();
    await iosImpl?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    await macosImpl?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    _initialized = true;
  }

  static Future<void> showNewArticles(int count) async {
    if (count <= 0 || kIsWeb) return;
    if (!_initialized) {
      await ensureInitialized();
    }

    final title =
        count == 1 ? 'Fetched 1 new article' : 'Fetched $count new articles';
    const body = 'Ready to read - open Aware to start.';

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
      debugPrint('Notification error: $e');
    }
  }

  static Future<void> showDebugNoNewArticles() async {
    if (!kDebugMode || kIsWeb) return;
    if (!_initialized) {
      await ensureInitialized();
    }

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        styleInformation: BigTextStyleInformation(
            'Background refresh finished with no changes.'),
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'Feed refresh',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
      ),
    );

    try {
      await _plugin.show(
        _summaryNotificationId,
        'No new articles',
        'Background refresh finished with no changes.',
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }
}
