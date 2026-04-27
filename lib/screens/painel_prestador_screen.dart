import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';

class PainelPrestadorScreen extends StatelessWidget {
  const PainelPrestadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // 🔵 APPBAR COM VOLTAR FUNCIONANDO
      appBar: AppBar(
        title: const Text("Painel do Prestador"),
        backgroundColor: const Color(0xFF1E6FD9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
            );
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // 👤 PERFIL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFFE3F0FF),
                    child: Icon(
                      Icons.work,
                      size: 40,
                      color: Color(0xFF1E6FD9),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    AuthService.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Prestador de serviços",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📊 OPÇÕES
            _cardOpcao(
              icon: Icons.assignment,
              title: "Serviços recebidos",
              subtitle: "Visualizar pedidos dos clientes",
              onTap: () {},
            ),

            _cardOpcao(
              icon: Icons.star,
              title: "Minhas avaliações",
              subtitle: "Veja o que os clientes dizem",
              onTap: () {},
            ),

            _cardOpcao(
              icon: Icons.settings,
              title: "Configurações",
              subtitle: "Ajustar perfil e preferências",
              onTap: () {},
            ),

            const Spacer(),

            // 🚪 SAIR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  AuthService.logout();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(),
                    ),
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Sair"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 CARD PADRÃO
  Widget _cardOpcao({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1E6FD9)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}