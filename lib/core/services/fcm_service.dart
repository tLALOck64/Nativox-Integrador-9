import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;

  Future<void> initialize() async {
    try {
      print('🔄 FCMService: Initializing FCM service');

      // Solicitar permisos
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      print('✅ FCMService: Permission status: ${settings.authorizationStatus}');

      // Obtener token
      await _getFCMToken();

      // Configurar handlers para mensajes
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      print('✅ FCMService: FCM service initialized successfully');
    } catch (e) {
      print('❌ FCMService: Error initializing FCM service: $e');
    }
  }

  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print(
        '✅ FCMService: FCM token obtained: ${_fcmToken?.substring(0, 20)}...',
      );
      return _fcmToken;
    } catch (e) {
      print('❌ FCMService: Error getting FCM token: $e');
      return null;
    }
  }

  Future<String> getFCMToken() async {
    if (_fcmToken == null) {
      await _getFCMToken();
    }
    return _fcmToken ?? 'default_fcm_token';
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print(
      '📱 FCMService: Foreground message received: ${message.notification?.title}',
    );
    // Aquí puedes manejar las notificaciones cuando la app está en primer plano
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print(
      '📱 FCMService: Background message opened: ${message.notification?.title}',
    );
    // Aquí puedes manejar cuando el usuario abre la app desde una notificación
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ FCMService: Subscribed to topic: $topic');
    } catch (e) {
      print('❌ FCMService: Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ FCMService: Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ FCMService: Error unsubscribing from topic: $e');
    }
  }
}
