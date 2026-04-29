import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'storage_service.dart';

/// Top-level background message handler. **Must be top-level** for FCM.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Background isolate — we don't process here, OS shows the notification.
  if (kDebugMode) {
    debugPrint('[FCM-bg] ${message.messageId}: ${message.notification?.title}');
  }
}

/// Wraps Firebase Cloud Messaging:
/// - Asks runtime permission (iOS / Android 13+).
/// - Acquires FCM token + sends to backend (`/fcm/register`).
/// - Listens for foreground messages and shows local notifications.
/// - Handles token refresh.
class FirebaseMessagingService {
  FirebaseMessagingService._();
  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifs =
      FlutterLocalNotificationsPlugin();
  final NotificationService _api = NotificationService();
  static const _kLastTokenKey = 'fcm_last_token';

  static const _channel = AndroidNotificationChannel(
    'tendapoa_default',
    'Arifa za Tendapoa',
    description: 'Arifa muhimu za kazi, malipo na maombi.',
    importance: Importance.high,
  );

  bool _initialized = false;

  /// Call once after Firebase.initializeApp() and after the user has logged in.
  /// Safe to call multiple times — will only initialize once.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Background handler must be registered before listeners.
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Local notifications setup (for displaying foreground messages).
    await _localNotifs.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    // Create Android notification channel.
    await _localNotifs
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // iOS foreground presentation.
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen for foreground messages.
    FirebaseMessaging.onMessage.listen(_handleForeground);

    // When user taps a notification while app is in background.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check if app was opened from a terminated state via notification tap.
    _fcm.getInitialMessage().then((message) {
      if (message != null) _handleMessageOpenedApp(message);
    });

    // Listen for token refresh.
    _fcm.onTokenRefresh.listen(_registerToken);
  }

  /// Request OS-level notification permission. Call after first login or when
  /// the user opens the notifications screen / settings.
  Future<bool> requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Acquire token + register with backend.
  /// Call this after login (when Sanctum token is available).
  Future<String?> registerWithBackend() async {
    try {
      await requestPermission();
      final token = await _fcm.getToken();
      if (token == null || token.isEmpty) return null;
      await _registerToken(token);
      return token;
    } catch (e) {
      debugPrint('[FCM] register failed: $e');
      return null;
    }
  }

  /// Unregister current token from backend (call before logout).
  Future<void> unregisterFromBackend() async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      await _api.unregisterDevice(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kLastTokenKey);
    } catch (e) {
      debugPrint('[FCM] unregister failed: $e');
    }
  }

  Future<void> _registerToken(String token) async {
    // Don't attempt registration if user isn't authenticated (no Sanctum token).
    final storage = StorageService();
    await storage.init(); // idempotent — safe to call multiple times
    final authToken = await storage.getToken();
    if (authToken == null || authToken.isEmpty) {
      debugPrint('[FCM] skipped register — no auth token');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_kLastTokenKey);
    if (last == token) return; // Already registered.

    String? appVersion;
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = '${info.version}+${info.buildNumber}';
    } catch (_) {}

    final platform = !kIsWeb && Platform.isIOS ? 'ios' : 'android';

    final ok = await _api.registerDevice(
      token: token,
      platform: platform,
      appVersion: appVersion,
    );
    if (ok) {
      await prefs.setString(_kLastTokenKey, token);
      debugPrint('[FCM] token registered with backend');
    }
  }

  Future<void> _handleForeground(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;

    await _localNotifs.show(
      message.hashCode,
      notif.title,
      notif.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }

  /// Handle notification tap (background or terminated state).
  void _handleMessageOpenedApp(RemoteMessage message) {
    final data = message.data;
    debugPrint('[FCM] notification tapped: ${data['notification_type']}');
    // Navigation is handled by the app's root context —
    // the data payload (e.g. job_id, type) can be read by
    // any widget listening to a global notification stream.
  }
}
