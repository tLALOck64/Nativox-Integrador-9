import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integrador/firebase_options.dart'; // ← AGREGAR ESTE IMPORT
import 'package:integrador/core/di/injection_container.dart' as di;
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/core/services/notifications_service.dart';
import 'package:integrador/core/services/fcm_service.dart';
import 'package:integrador/core/navigation/app_router.dart';
import 'package:integrador/login/presentation/viewmodels/login_viewmodel.dart';
import 'package:integrador/register/presentation/viewmodels/registration_viewmodel.dart';
import 'package:integrador/perfil/presentation/viewmodels/profile_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await StorageService.init();
  await di.initializeDependencies();

  await di.sl<NotificationService>().init();
  await di.sl<FCMService>().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginViewModel>(
          create: (_) => di.sl<LoginViewModel>(),
        ),
        ChangeNotifierProvider<RegistrationViewModel>(
          create: (_) => di.sl<RegistrationViewModel>(),
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => di.sl<ProfileViewModel>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Nativox',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          fontFamily: 'SF Pro Display',
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4A574)),
          useMaterial3: true,
        ),
      ),
    );
  }
}
