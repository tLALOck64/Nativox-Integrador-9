import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:integrador/MessagingWrapper.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseMessaging.instance.requestPermission();
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  print("🔑 FCM Token: $fcmToken");

  runApp(const YoloxochitlApp());
}

class YoloxochitlApp extends StatelessWidget {
  const YoloxochitlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yoloxóchitl',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'SF Pro Display',
      ),
      home: const MessagingWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
