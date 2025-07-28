import 'package:flutter/foundation.dart';

class FCMServiceWeb {
  static final FCMServiceWeb _instance = FCMServiceWeb._internal();
  factory FCMServiceWeb() => _instance;
  FCMServiceWeb._internal();

  Future<void> initialize() async {
    if (kIsWeb) {
      print('🌐 FCM: Web platform detected - skipping FCM initialization');
      print('✅ FCM: Web service initialized (no-op)');
      return;
    }
    
    // Para otras plataformas, usar el FCM normal
    print('📱 FCM: Non-web platform - FCM should be initialized normally');
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      print('🌐 FCM: Web platform - no token needed');
      return null;
    }
    
    // Para otras plataformas, retornar el token real
    return null;
  }

  Future<void> requestPermission() async {
    if (kIsWeb) {
      print('🌐 FCM: Web platform - permission request skipped');
      return;
    }
    
    // Para otras plataformas, solicitar permisos reales
  }

  void onMessage(Function(Map<String, dynamic>) callback) {
    if (kIsWeb) {
      print('🌐 FCM: Web platform - message listener not needed');
      return;
    }
    
    // Para otras plataformas, configurar listener real
  }

  void onMessageOpenedApp(Function(Map<String, dynamic>) callback) {
    if (kIsWeb) {
      print('🌐 FCM: Web platform - app opened listener not needed');
      return;
    }
    
    // Para otras plataformas, configurar listener real
  }
}