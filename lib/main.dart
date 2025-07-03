import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
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
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}