import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/di/injection_container.dart' as di;
import 'package:integrador/core/navigation/route_names.dart';
import 'package:integrador/core/navigation/guards/auth_guard.dart';
import 'package:integrador/core/navigation/navigation_service.dart';
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/core/layouts/main_layout.dart';
import 'package:integrador/games/lecciones/screens/lesson_detail_screen.dart';
import 'package:integrador/games/practicas/screen/audio_translate_screen.dart';
import 'package:integrador/games/practicas/screen/memorama_menu_screen.dart';
import 'package:integrador/games/practicas/screen/traductor_screen.dart';
import 'package:integrador/login/presentation/screens/login_activity.dart';
import 'package:integrador/register/presentation/screens/resgistration_screen.dart';
import 'package:integrador/perfil/presentation/screens/profile_activity.dart';
import 'package:integrador/global/screens/home_screen.dart';

import 'package:integrador/games/cuentos/cuentos_screen.dart';
import 'package:integrador/games/lecciones/lesson_screen.dart';
import 'package:integrador/games/practicas/practice_screen.dart';
import 'package:integrador/core/utils/screens/download_pdf.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/lessons',
    navigatorKey: NavigationService.navigatorKey,
    routes: [
      // Rutas sin navbar
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginActivity(),
      ),

      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegistrationActivity(),
      ),
      GoRoute(
        path: RouteNames.downloadPdf,
        builder: (context, state) => const DownloadPdfScreen(),
      ),

      GoRoute(
        path: '/lessons/:lessonId',
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return LessonDetailScreen(lessonId: lessonId);
        },
      ),

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

      // Rutas con navbar usando ShellRoute
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(location: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),

          GoRoute(
            path: RouteNames.lessons,
            builder: (context, state) => const LessonsScreen(),
          ),

          GoRoute(
            path: RouteNames.practice,
            builder: (context, state) => const PracticeScreen(),
          ),

          GoRoute(
            path: RouteNames.traductor,
            builder: (context, state) => const TraductorScreen(),
          ),

          GoRoute(
            path: RouteNames.game,
            builder: (context, state) => const MemoramaMenuScreen(),
          ),

          GoRoute(path: RouteNames.audioTranslate,
            builder: (context, state) => const AudioTranslatorScreen(),
          ),

          GoRoute(
            path: RouteNames.profile,
            builder: (context, state) => const ProfileActivity(),
          ),
          GoRoute(
            path: RouteNames.cuentos,
            builder: (context, state) => const CuentosScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );

  static GoRouter get router => _router;
}

// Screens placeholder
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
    await Future.delayed(const Duration(seconds: 2));

    final storageService = di.sl<StorageService>();
    final userData = await storageService.getUserData();

    if (mounted) {
      if (userData != null) {
        context.go(RouteNames.home);
      } else {
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
              'Aprendiendo Zapoteco',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Settings')));
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Notification Settings')));
}

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Theme Settings')));
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Page Not Found')));
}
