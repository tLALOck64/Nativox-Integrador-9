import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;

  Future<void> initialize() async {
    try {
      print('🔄 FCMService: Initializing FCM service');

      // Verificar si estamos en web
      if (kIsWeb) {
        print('🌐 FCMService: Web platform detected - limited FCM functionality');
        print('✅ FCMService: FCM service initialized successfully (web mode)');
        return;
      }

      // Solicitar permisos (solo en móvil)
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

      // Solo obtener token si los permisos están concedidos
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _getFCMToken();
      } else {
        print('⚠️ FCMService: Permissions not granted, skipping token retrieval');
      }

      // Configurar handlers para mensajes
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      print('✅ FCMService: FCM service initialized successfully');
    } catch (e) {
      print('❌ FCMService: Error initializing FCM service: $e');
      // No lanzar excepción para evitar que la app se cierre
      print('✅ FCMService: FCM service initialized with errors (continuing...)');
    }
  }

  Future<String?> _getFCMToken() async {
    try {
      if (kIsWeb) {
        print('🌐 FCMService: Token not available on web platform');
        return null;
      }

      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        print(
          '✅ FCMService: FCM token obtained: ${_fcmToken!.substring(0, 20)}...',
        );
      } else {
        print('⚠️ FCMService: FCM token is null');
      }
      return _fcmToken;
    } catch (e) {
      print('❌ FCMService: Error getting FCM token: $e');
      return null;
    }
  }

  Future<String> getFCMToken() async {
    if (kIsWeb) {
      print('🌐 FCMService: Returning default token for web platform');
      return 'web_platform_token';
    }

    if (_fcmToken == null) {
      await _getFCMToken();
    }
    return _fcmToken ?? 'default_fcm_token';
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kIsWeb) return;
    
    print(
      '📱 FCMService: Foreground message received: ${message.notification?.title}',
    );
    // Aquí puedes manejar las notificaciones cuando la app está en primer plano
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if (kIsWeb) return;
    
    print(
      '📱 FCMService: Background message opened: ${message.notification?.title}',
    );
    // Aquí puedes manejar cuando el usuario abre la app desde una notificación
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      if (kIsWeb) {
        print('🌐 FCMService: Topic subscription not available on web');
        return;
      }

      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ FCMService: Subscribed to topic: $topic');
    } catch (e) {
      print('❌ FCMService: Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (kIsWeb) {
        print('🌐 FCMService: Topic unsubscription not available on web');
        return;
      }

      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ FCMService: Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ FCMService: Error unsubscribing from topic: $e');
    }
  }
}