import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integrador/firebase_options.dart';
import 'package:integrador/core/di/injection_container.dart' as di;
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/core/services/notifications_service.dart';
import 'package:integrador/core/services/fcm_service.dart';
import 'package:integrador/core/navigation/app_router.dart';
import 'package:integrador/core/config/platform_config.dart';
import 'package:integrador/core/config/app_theme.dart';
import 'package:integrador/login/presentation/viewmodels/login_viewmodel.dart';
import 'package:integrador/register/presentation/viewmodels/registration_viewmodel.dart';
import 'package:integrador/perfil/presentation/viewmodels/profile_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Log platform information
    PlatformConfig.logPlatformInfo();

    // Initialize Firebase
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('✅ Firebase initialized successfully');

    // Initialize Storage
    print('💾 Initializing Storage...');
    await StorageService.init();
    print('✅ Storage initialized successfully');

    // Initialize Dependencies
    print('🔧 Initializing Dependencies...');
    await di.initializeDependencies();
    print('✅ Dependencies initialized successfully');

    // Initialize Notifications (only on mobile)
    if (PlatformConfig.shouldRequestNotificationPermissions) {
      print('🔔 Initializing Notifications...');
      try {
        await di.sl<NotificationService>().init();
        print('✅ Notifications initialized successfully');
      } catch (e) {
        print('⚠️ Notifications initialization failed: $e');
      }
    } else {
      print('🌐 Skipping notifications initialization (web platform)');
    }

    // Initialize FCM (only on mobile)
    if (PlatformConfig.shouldInitializeFCM) {
      print('📱 Initializing FCM...');
      try {
        await di.sl<FCMService>().initialize();
        print('✅ FCM initialized successfully');
      } catch (e) {
        print('⚠️ FCM initialization failed: $e');
      }
    } else {
      print('🌐 Skipping FCM initialization (web platform)');
    }

    print('🚀 Main initialization completed successfully');
    
  } catch (e, stackTrace) {
    print('❌ Critical error during initialization: $e');
    if (kDebugMode) {
      print('Stack trace: $stackTrace');
    }
    // Continue with app launch even if some services fail
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginViewModel>(
          create: (_) {
            try {
              return di.sl<LoginViewModel>();
            } catch (e) {
              print('❌ Error creating LoginViewModel: $e');
              // Return a fallback or rethrow
              rethrow;
            }
          },
        ),
        ChangeNotifierProvider<RegistrationViewModel>(
          create: (_) {
            try {
              return di.sl<RegistrationViewModel>();
            } catch (e) {
              print('❌ Error creating RegistrationViewModel: $e');
              rethrow;
            }
          },
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) {
            try {
              return di.sl<ProfileViewModel>();
            } catch (e) {
              print('❌ Error creating ProfileViewModel: $e');
              rethrow;
            }
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'Nativox',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}