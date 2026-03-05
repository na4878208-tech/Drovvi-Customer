// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize notifications on app start
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      print('🔔 Initializing notifications...');

      // 1. Setup local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      await _notifications.initialize(
        const InitializationSettings(android: androidSettings),
      );

      // 2. Create notification channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'Order Notifications',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification'),
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // 3. Request permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('🔔 Notification permission: ${settings.authorizationStatus}');

      // 4. Get FCM token
      String? token = await _messaging.getToken();
      print('🔔 FCM Token: $token');

      // 5. Listen to messages
      _setupMessageHandlers();

      _initialized = true;
      print('✅ Notifications initialized successfully');
    } catch (error) {
      print('❌ Error initializing notifications: $error');
    }
  }

  /// Setup message handlers
  static void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Foreground notification received');
      print('   Title: ${message.notification?.title}');
      print('   Body: ${message.notification?.body}');
      print('   Data: ${message.data}');

      _showLocalNotification(
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? '',
        message.data,
      );
    });

    // When app is opened from terminated state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 App opened from notification');
      print('   Data: ${message.data}');
      _handleNotificationClick(message.data);
    });

    // Background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Background message handler
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print('📱 Background notification received');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');

    // You can show local notification here if needed
  }

  /// Show local notification
  static Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'Order Notifications',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notification'),
        );

    await _notifications.show(
      0,
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: data.toString(),
    );
  }

  /// Handle notification click
  static void _handleNotificationClick(Map<String, dynamic> data) {
    print('🖱️ Notification clicked with data: $data');

    final type = data['type'];
    final orderId = data['orderId'];

    // Navigate based on notification type
    if (type == 'order_created') {
      // Navigate to order details
      print('Navigate to order: $orderId');
    } else if (type == 'order_status_update') {
      print('Navigate to order status: $orderId');
    }
  }

  /// Save FCM token for user
  static Future<void> saveTokenForUser(String userId) async {
    try {
      String? token = await _messaging.getToken();

      if (token != null && userId.isNotEmpty) {
        await _firestore.collection('users').doc(userId).set({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print('✅ FCM token saved for user: $userId');
      }
    } catch (error) {
      print('❌ Error saving FCM token: $error');
    }
  }

  /// Remove FCM token on logout
  static Future<void> removeTokenForUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
      print('✅ FCM token removed for user: $userId');
    } catch (error) {
      print('❌ Error removing FCM token: $error');
    }
  }

  /// Get current FCM token
  static Future<String?> getCurrentToken() async {
    return await _messaging.getToken();
  }
}
