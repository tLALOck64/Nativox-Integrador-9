import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integrador/firebase_options.dart';
import 'package:integrador/core/di/injection_container.dart' as di;
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/core/services/notifications_service.dart';
import 'package:integrador/core/navigation/app_router.dart';
import 'package:integrador/login/presentation/viewmodels/login_viewmodel.dart';
import 'package:integrador/perfil/presentation/viewmodels/profile_viewmodel.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // ← AGREGAR ESTE IMPORT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await StorageService.init();
  await di.initializeDependencies();

  await di.sl<NotificationService>().init();

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  String? token = await firebaseMessaging.getToken();
  if (token != null) {
    print('Firebase Device Token: $token');
  } else {
    print('No se pudo obtener el token de Firebase.');
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Notificación recibida en primer plano:');
    print('Título: ${message.notification?.title}');
    print('Cuerpo: ${message.notification?.body}');
    print('Datos: ${message.data}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notificación abierta desde bandeja:');
    print('Título: ${message.notification?.title}');
    print('Cuerpo: ${message.notification?.body}');
    print('Datos: ${message.data}');
  });

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
