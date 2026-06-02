import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'IJob',

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: const Color(0xFFF5F7FA),

        primaryColor: const Color(0xFF1E6FD9),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E6FD9),
          brightness: Brightness.light,
        ),

        fontFamily: 'Roboto',

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E6FD9),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E6FD9),
            foregroundColor: Colors.white,

            elevation: 0,

            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1E6FD9),

            side: const BorderSide(
              color: Color(0xFF1E6FD9),
            ),

            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF1E6FD9),
              width: 1.5,
            ),
          ),

          labelStyle: const TextStyle(
            color: Colors.grey,
          ),
        ),

        cardTheme: CardThemeData(
          color: Colors.white,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,

          selectedItemColor: Color(0xFF1E6FD9),
          unselectedItemColor: Colors.grey,

          type: BottomNavigationBarType.fixed,

          elevation: 10,
        ),

        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFEAF2FF),

          selectedColor: const Color(0xFF1E6FD9),

          labelStyle: const TextStyle(
            color: Color(0xFF1E6FD9),
            fontWeight: FontWeight.w500,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),

      home: const HomeScreen(),
    );
  }
}