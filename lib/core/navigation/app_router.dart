import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/di/injection_container.dart' as di;
import 'package:integrador/core/navigation/route_names.dart';
import 'package:integrador/core/navigation/guards/auth_guard.dart';
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/login/presentation/screens/login_activity.dart';
import 'package:integrador/perfil/presentation/screens/profile_activity.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/profile',
    routes: [
      // Splash
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth routes
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginActivity(),
      ),
       GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfileActivity(),
       
      ),
      
      
      // Protected routes
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
        redirect: AuthGuard.redirectIfNotAuthenticated,
      ),
      
     
      
      // Settings with nested routes
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
        redirect: AuthGuard.redirectIfNotAuthenticated,
        routes: [
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: 'theme',
            builder: (context, state) => const ThemeSettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );

  static GoRouter get router => _router;
}

// Placeholder screens (replace with actual implementations)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('🔄 SplashScreen renderizando...');
    
    // Navegación inmediata para probar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 SplashScreen navegando a login...');
      context.go('/login');
    });

    return Scaffold(
      backgroundColor: const Color(0xFFD4A574),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Cargando...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Home')));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Settings')));
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Notification Settings')));
}

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Theme Settings')));
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Page Not Found')));
}