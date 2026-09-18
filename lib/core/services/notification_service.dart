import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background message handler required by Firebase Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('🔔 [FCM Background Message]: ${message.messageId} | ${message.notification?.title}');
  } catch (e) {
    debugPrint('Error in background message handler: $e');
  }
}

/// Centralized notification service managing Firebase Cloud Messaging (Push Notifications)
/// and high-importance local foreground notifications.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const String channelId = 'kalika_general_channel';
  static const String channelName = 'Kalika Notifications';
  static const String channelDescription =
      'Important vocabulary updates, daily words, reminders, and learning streaks.';

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  String? _fcmToken;

  /// Returns the cached or current FCM device token for sending test notifications
  String? get fcmToken => _fcmToken;

  /// Initializes notification services, channels, and message listeners
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Firebase messaging is natively supported on Android, iOS, macOS, Web
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      debugPrint('ℹ️ FCM is not natively supported on Windows/Linux desktop.');
      return;
    }

    try {
      // 1. Set background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 2. Request permission (required for Android 13+ and iOS)
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('🔔 Notification Authorization Status: ${settings.authorizationStatus}');

      // 3. Initialize local notifications for Android foreground heads-up banners
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('🔔 Foreground Notification tapped: ${response.payload}');
        },
      );

      // 4. Create high-importance Android notification channel
      if (!kIsWeb && Platform.isAndroid) {
        final androidImplementation = _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          const androidChannel = AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          );
          await androidImplementation.createNotificationChannel(androidChannel);
        }
      }

      // 5. Configure foreground presentation options
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 6. Setup Foreground Message Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔔 [FCM Foreground Message]: ${message.notification?.title} - ${message.notification?.body}');
        _showLocalNotification(message);
      });

      // 7. Setup Tap on Notification Listener (when app is in background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🔔 [FCM Notification Clicked from Background]: ${message.data}');
      });

      // 8. Check if launched by tapping a notification (when app was terminated)
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🔔 [FCM App Launched via Notification]: ${initialMessage.data}');
      }

      // 9. Retrieve and log FCM registration token
      await _retrieveToken();

      // Automatically subscribe to general broadcast topic for Kalika updates
      await subscribeToTopic('all_users');
      await subscribeToTopic('daily_words');

      _isInitialized = true;
      debugPrint('✅ NotificationService successfully initialized.');
    } catch (e, stack) {
      debugPrint('⚠️ NotificationService initialization skipped or encountered error: $e');
      debugPrint('$stack');
    }
  }

  /// Displays a heads-up banner when notification arrives in the foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title ?? 'Kalika',
      notification.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  /// Retrieves device FCM token and sets up token refresh listener
  Future<String?> _retrieveToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      _fcmToken = token;
      debugPrint('====================================================');
      debugPrint('🔥 Kalika FCM Device Registration Token:');
      debugPrint(token ?? 'Unavailable');
      debugPrint('====================================================');

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('🔥 Kalika FCM Token Refreshed: $newToken');
      });

      return token;
    } catch (e) {
      debugPrint('Could not retrieve FCM token: $e');
      return null;
    }
  }

  /// Subscribes to a broadcast topic (e.g. 'daily_words')
  Future<void> subscribeToTopic(String topic) async {
    try {
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) return;
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribes from a broadcast topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) return;
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }
}
