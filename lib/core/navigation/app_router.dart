import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/di/injection_container.dart' as di;
import 'package:integrador/core/navigation/route_names.dart';
import 'package:integrador/core/navigation/guards/auth_guard.dart';
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/games/screen/lesson_detail_screen.dart';
import 'package:integrador/games/screen/memorama_menu_screen.dart';
import 'package:integrador/login/presentation/screens/login_activity.dart';
import 'package:integrador/perfil/presentation/screens/profile_activity.dart';
import 'package:integrador/screens/lesson_screen.dart';
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: RouteNames.memorama,
    routes: [
      // Splash
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: RouteNames.lessons
        , builder: (context, state) => const LessonsScreen()),

         GoRoute(
        path: '/lessons/:lessonId',
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return LessonDetailScreen(lessonId: lessonId);
        },
        redirect: AuthGuard.redirectIfNotAuthenticated,
      ),
      // Auth routes
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginActivity(),
      ),
       GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfileActivity(),
        redirect: AuthGuard.redirectIfNotAuthenticated,
      ),
      
      // Protected routes
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
        redirect: AuthGuard.redirectIfNotAuthenticated,
      ),
      
      // Games routes
      GoRoute(
        path: '/games/memorama',
        builder: (context, state) => const MemoramaMenuScreen(),
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
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Simular carga inicial
    await Future.delayed(const Duration(seconds: 2));
    
    // Verificar si hay usuario logueado
    final storageService = di.sl<StorageService>();
    final userData = await storageService.getUserData();
    
    if (mounted) {
      if (userData != null) {
        // Usuario logueado, ir a home o profile
        context.go(RouteNames.profile); // o RouteNames.home
      } else {
        // No hay usuario, ir a login
        context.go(RouteNames.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4A574),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o icono de tu app
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school,
                size: 60,
                color: Color(0xFFD4A574),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nativox',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aprendiendo Náhuatl',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
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