// core/navigation/guards/auth_guard.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/navigation/route_names.dart';
import 'package:integrador/core/di/injection_container.dart' as di; // ← AGREGAR
import 'package:integrador/core/services/storage_service.dart';

class AuthGuard {
  static Future<String?> redirectIfNotAuthenticated(
    BuildContext context,
    GoRouterState state,
  ) async {
    try {
      // ✅ Usar la instancia desde DI
      final storageService = di.sl<StorageService>();
      final userData = await storageService.getUserData(); // ← Cambiar a getUserData
      
      if (userData == null) {
        return RouteNames.login;
      }
      
      return null; // No redirect needed
    } catch (e) {
      print('❌ AuthGuard error: $e');
      return RouteNames.login; // Si hay error, ir a login
    }
  }

  static Future<String?> redirectIfAuthenticated(
    BuildContext context,
    GoRouterState state,
  ) async {
    try {
      final storageService = di.sl<StorageService>();
      final userData = await storageService.getUserData();
      
      if (userData != null) {
        return RouteNames.home; // ← Cambiar a profile
      }
      
      return null; // No redirect needed
    } catch (e) {
      print('❌ AuthGuard error: $e');
      return null;
    }
  }
}