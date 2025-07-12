// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/navigation/route_names.dart';
import 'package:integrador/core/services/storage_service.dart';

class AuthGuard {
  static Future<String?> redirectIfNotAuthenticated(
    BuildContext context,
    GoRouterState state,
  ) async {
    final storageService = StorageService();
    final token = await storageService.getToken();
    
    if (token == null) {
      return RouteNames.login;
    }
    
    return null; // No redirect needed
  }

  static Future<String?> redirectIfAuthenticated(
    BuildContext context,
    GoRouterState state,
  ) async {
    final storageService = StorageService();
    final token = await storageService.getToken();
    
    if (token != null) {
      return RouteNames.home;
    }
    
    return null; // No redirect needed
  }
}
