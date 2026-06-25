import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/location_service.dart';
import 'perfil_screen.dart';
import 'prestador_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  bool pediuLocalizacaoInicial = false;

  final List<Widget> pages = const [
    PrestadorScreen(),
    PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pedirLocalizacaoInicial();
    });
  }

  Future<void> _pedirLocalizacaoInicial() async {
    if (pediuLocalizacaoInicial) return;
    pediuLocalizacaoInicial = true;

    final permitido = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Deseja compartilhar sua localização?"),
          content: const Text(
            "Usamos sua localização real para mostrar prestadores próximos e verificar a área de atendimento.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Agora não"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Compartilhar"),
            ),
          ],
        );
      },
    );

    if (permitido != true) return;

    try {
      final localizacao = await LocationService.obterLocalizacaoAtual();
      AuthService.localizacao = localizacao.enderecoCurto;
    } catch (_) {
      // Se a pessoa negar, o app continua funcionando sem localização.
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Início",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}



