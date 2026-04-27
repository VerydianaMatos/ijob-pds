import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'cadastro_screen.dart';
import 'cadastro_prestador_screen.dart';
import 'meus_servicos_screen.dart';
import 'painel_prestador_screen.dart';
import 'favoritos_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: const Color(0xFF1E6FD9),
      ),
      body: AuthService.isLogged
          ? _perfilLogado(context)
          : _perfilDeslogado(context),
    );
  }

  Widget _perfilDeslogado(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),

          const Icon(
            Icons.person_outline,
            size: 85,
            color: Color(0xFF1E6FD9),
          ),

          const SizedBox(height: 20),

          const Text(
            "Você ainda não está logado",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          const Text(
            "Entre ou crie uma conta para acessar seus serviços.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E6FD9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                ).then((_) => setState(() {}));
              },
              child: const Text("Entrar"),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CadastroScreen()),
                ).then((_) => setState(() {}));
              },
              child: const Text("Criar conta"),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CadastroPrestadorScreen(),
                  ),
                ).then((_) => setState(() {}));
              },
              icon: const Icon(Icons.work),
              label: const Text("Seja um prestador"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _perfilLogado(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: const Color(0xFFE3F0FF),
            child: Icon(
              AuthService.isPrestador ? Icons.work : Icons.person,
              size: 40,
              color: const Color(0xFF1E6FD9),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            AuthService.nome,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          const SizedBox(height: 4),

          Text(
            AuthService.email,
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 30),

          _opcao(
            icon: Icons.favorite,
            title: "Favoritos",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoritosScreen(),
                ),
              );
            },
          ),

          if (AuthService.isPrestador)
            _opcao(
              icon: Icons.dashboard,
              title: "Painel do prestador",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PainelPrestadorScreen(),
                  ),
                );
              },
            ),

          if (!AuthService.isPrestador)
            _opcao(
              icon: Icons.work,
              title: "Meus serviços",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MeusServicosScreen(),
                  ),
                );
              },
            ),

          _opcao(
            icon: Icons.settings,
            title: "Configurações",
            onTap: () {},
          ),

          _opcao(
            icon: Icons.logout,
            title: "Sair",
            onTap: () {
              AuthService.logout();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _opcao({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1E6FD9)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}