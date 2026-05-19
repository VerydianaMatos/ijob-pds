import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'solicitacoes_prestador_screen.dart';
import '../services/auth_service.dart';

class PainelPrestadorScreen extends StatelessWidget {
  const PainelPrestadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFF1E6FD9),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.work,
                      size: 38,
                      color: Color(0xFF1E6FD9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AuthService.nome.isEmpty
                        ? "Prestador"
                        : AuthService.nome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Profissional cadastrado no IJob",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Expanded(
                    child: _ResumoCard(
                      titulo: "Solicitações",
                      valor: "2",
                      icon: Icons.assignment,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _ResumoCard(
                      titulo: "Avaliação",
                      valor: "4.9",
                      icon: Icons.star,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _OpcaoPainel(
              icon: Icons.assignment,
              titulo: "Solicitações recebidas",
              subtitulo: "Aceite ou recuse pedidos de clientes",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SolicitacoesPrestadorScreen(),
                  ),
                );
              },
            ),

            _OpcaoPainel(
              icon: Icons.handyman,
              titulo: "Meus serviços",
              subtitulo: "Gerencie os serviços que você oferece",
              onTap: () {},
            ),

            _OpcaoPainel(
              icon: Icons.chat,
              titulo: "Mensagens",
              subtitulo: "Converse com seus clientes",
              onTap: () {},
            ),

            _OpcaoPainel(
              icon: Icons.edit,
              titulo: "Editar perfil profissional",
              subtitulo: "Atualize seus dados e descrição",
              onTap: () {},
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
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
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Sair"),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icon;

  const _ResumoCard({
    required this.titulo,
    required this.valor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF1E6FD9)),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(titulo, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _OpcaoPainel extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _OpcaoPainel({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 9,
          )
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE3F0FF),
          child: Icon(icon, color: const Color(0xFF1E6FD9)),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}