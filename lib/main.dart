import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integrador/core/di/injection_container.dart' as di;
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/core/services/notifications_service.dart';
import 'package:integrador/core/navigation/app_router.dart';
import 'package:integrador/login/presentation/viewmodels/login_viewmodel.dart';
import 'package:integrador/profile/presentation/viewmodels/profile_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Core Services
  await StorageService.init();
  await di.initializeDependencies();
  
  // Initialize Notification Service
  await di.sl<NotificationService>().init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ViewModels using GetIt
        ChangeNotifierProvider<LoginViewModel>(
          create: (_) => di.sl<LoginViewModel>(),
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => di.sl<ProfileViewModel>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Yoloxóchitl',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          fontFamily: 'SF Pro Display',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD4A574),
          ),
          useMaterial3: true,
        ),
      ),
    );
  }
}