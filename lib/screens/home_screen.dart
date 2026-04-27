import 'package:flutter/material.dart';
import 'prestador_screen.dart';
import 'perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  final pages = const [
    PrestadorScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: const Color(0xFF1E6FD9),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Início",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}