import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheCleanerService {
  // Limpiar SharedPreferences
  static Future<void> clearSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ SharedPreferences limpiado exitosamente');
    } catch (e) {
      print('❌ Error al limpiar SharedPreferences: $e');
      rethrow;
    }
  }

  // Limpiar caché de imágenes
  static Future<void> clearImageCache() async {
    try {
      await DefaultCacheManager().emptyCache();
      print('✅ Caché de imágenes limpiado exitosamente');
    } catch (e) {
      print('❌ Error al limpiar caché de imágenes: $e');
      rethrow;
    }
  }

  // Limpiar directorio de caché de la aplicación
  static Future<void> clearAppCacheDirectory() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
        print('✅ Directorio de caché de la app limpiado exitosamente');
      }
    } catch (e) {
      print('❌ Error al limpiar directorio de caché: $e');
      rethrow;
    }
  }

  // Limpiar todo el caché y almacenamiento
  static Future<void> clearAllCache() async {
    try {
      await Future.wait([
        clearSharedPreferences(),
        clearImageCache(),
        clearAppCacheDirectory(),
      ]);
      print('✅ Todos los datos de caché y almacenamiento han sido limpiados');
    } catch (e) {
      print('❌ Error al limpiar caché: $e');
      rethrow;
    }
  }
}
