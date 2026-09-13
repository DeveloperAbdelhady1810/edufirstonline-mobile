import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_client.dart';

const _androidChannel = AndroidNotificationChannel(
  'default_channel',
  'الإشعارات',
  description: 'إشعارات EduFirstOnline',
  importance: Importance.high,
);

/// Handles a data/notification message that arrives while the app is fully
/// backgrounded or terminated. Must be a top-level (or static) function -
/// FCM runs it in its own isolate, separate from the running app.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Nothing to do here beyond letting FCM show its own default system
  // notification (which it does automatically for a "notification" payload
  // when the app isn't in the foreground) - this handler exists mainly so
  // FirebaseMessaging.onBackgroundMessage has something registered.
}

/// Wraps Firebase Cloud Messaging + local-notification display. The
/// backend has no push infrastructure until a service-account key is
/// wired in server-side (see PushNotificationService docs) - until then
/// this still registers the device's token and displays any push Firebase
/// itself delivers, it just won't receive real server-triggered ones yet.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

    // Foreground messages don't show a system banner on their own (that's
    // only automatic in background/terminated state) - show one manually
    // via flutter_local_notifications so a push is visible either way.
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Call once after a successful login/register, and once at app start if
  /// a session is already valid - registers this device's current FCM
  /// token with the backend (POST /api/device-tokens) so a
  /// server-triggered notification can reach it as a real push. Failures
  /// are swallowed - push registration is a nice-to-have, never something
  /// that should block login.
  Future<void> registerDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await ApiClient.instance.post('/device-tokens', {
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
    } catch (_) {
      // Non-fatal.
    }
  }

  /// Call on logout so a stale token isn't left registered against an
  /// account nobody's signed into anymore on this device.
  Future<void> unregisterDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await ApiClient.instance.post('/device-tokens/unregister', {'token': token});
    } catch (_) {
      // Non-fatal.
    }
  }
}
