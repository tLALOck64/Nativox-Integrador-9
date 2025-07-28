import 'package:flutter/foundation.dart';

class PlatformConfig {
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !kIsWeb;
  
  // Configuración específica para web
  static bool get shouldInitializeFCM => !kIsWeb;
  static bool get shouldRequestNotificationPermissions => !kIsWeb;
  static bool get shouldUseSecureStorage => !kIsWeb;
  
  // Configuración de timeouts
  static Duration get apiTimeout => kIsWeb 
      ? const Duration(seconds: 10) 
      : const Duration(seconds: 30);
      
  // Configuración de cache
  static Duration get cacheValidDuration => kIsWeb 
      ? const Duration(minutes: 5) 
      : const Duration(minutes: 10);
      
  // Configuración de logs
  static bool get enableVerboseLogs => kDebugMode;
  
  static void logPlatformInfo() {
    print('🔧 Platform Config:');
    print('   - Platform: ${isWeb ? "Web" : "Mobile"}');
    print('   - FCM: ${shouldInitializeFCM ? "Enabled" : "Disabled"}');
    print('   - Notifications: ${shouldRequestNotificationPermissions ? "Enabled" : "Disabled"}');
    print('   - Secure Storage: ${shouldUseSecureStorage ? "Enabled" : "Disabled"}');
    print('   - API Timeout: ${apiTimeout.inSeconds}s');
    print('   - Cache Duration: ${cacheValidDuration.inMinutes}min');
  }
}