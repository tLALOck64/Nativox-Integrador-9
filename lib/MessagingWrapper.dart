import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:integrador/screens/home_screen.dart';

class MessagingWrapper extends StatefulWidget {
  const MessagingWrapper({super.key});

  @override
  State<MessagingWrapper> createState() => _MessagingWrapperState();
}

class _MessagingWrapperState extends State<MessagingWrapper> {
  @override
  void initState() {
    super.initState();

    // Escuchar mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final title = message.notification!.title ?? 'Sin título';
        final body = message.notification!.body ?? 'Sin contenido';

        // Mostrar un SnackBar con el contenido
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title\n$body'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.brown[400],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
