import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const IJobApp());
}

class IJobApp extends StatelessWidget {
  const IJobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IJob',
      theme: ThemeData(
        primaryColor: const Color(0xFF1E6FD9),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const HomeScreen(),
    );
  }
}