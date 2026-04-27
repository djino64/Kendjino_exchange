// lib/services/notification/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Android init
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create channels
    await _createChannels();

    // Get FCM token
    _fcmToken = await _fcm.getToken();
    debugPrint('FCM Token: $_fcmToken');

    // Listen to token refresh
    _fcm.onTokenRefresh.listen((token) {
      _fcmToken = token;
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
  }

  Future<void> _createChannels() async {
    const transactionChannel = AndroidNotificationChannel(
      AppConstants.transactionChannel,
      'Transactions',
      description: 'Notifications pour les transferts et paiements',
      importance: Importance.high,
      playSound: true,
    );

    const securityChannel = AndroidNotificationChannel(
      AppConstants.securityChannel,
      'Sécurité',
      description: 'Alertes de sécurité',
      importance: Importance.max,
    );

    const promoChannel = AndroidNotificationChannel(
      AppConstants.promoChannel,
      'Promotions',
      description: 'Offres et promotions',
      importance: Importance.defaultImportance,
    );

    final plugin =
        _local.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await plugin?.createNotificationChannel(transactionChannel);
    await plugin?.createNotificationChannel(securityChannel);
    await plugin?.createNotificationChannel(promoChannel);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message: ${message.notification?.title}');
    await showLocalNotification(
      title: message.notification?.title ?? 'Kendjino',
      body: message.notification?.body ?? '',
      channel: message.data['channel'] ?? AppConstants.transactionChannel,
      payload: message.data.toString(),
    );
  }

  void _handleNotificationOpen(RemoteMessage message) {
    debugPrint('Notification opened: ${message.data}');
    // Navigation handled by app router
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String channel = AppConstants.transactionChannel,
    String? payload,
    int id = 0,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channel,
      channel,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _local.show(id, title, body, details, payload: payload);
  }

  Future<void> showTransactionNotification({
    required String type,
    required double amount,
    required String currency,
    String? counterparty,
  }) async {
    final isCredit = type == 'received';
    final sign = isCredit ? '+' : '-';
    final emoji = isCredit ? '💰' : '📤';

    await showLocalNotification(
      title: '$emoji ${isCredit ? 'Argent reçu' : 'Transfert envoyé'}',
      body:
          '$sign$amount $currency${counterparty != null ? ' · $counterparty' : ''}',
      channel: AppConstants.transactionChannel,
    );
  }

  Future<void> showSecurityAlert(String message) async {
    await showLocalNotification(
      title: '🔐 Alerte sécurité',
      body: message,
      channel: AppConstants.securityChannel,
      id: 999,
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }

  Future<void> clearAll() async {
    await _local.cancelAll();
  }
}