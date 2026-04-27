import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/agendamento_service.dart';

import 'login_screen.dart';
import 'agendamento_screen.dart';
import 'chat_screen.dart';
import 'avaliacao_screen.dart';

class PerfilPrestadorScreen extends StatefulWidget {
  const PerfilPrestadorScreen({super.key});

  @override
  State<PerfilPrestadorScreen> createState() => _PerfilPrestadorScreenState();
}

class _PerfilPrestadorScreenState extends State<PerfilPrestadorScreen> {
  bool get jaAgendou {
    return AgendamentoService.agendamentos.any(
          (a) => a.nomePrestador == "Carlos Martins",
    );
  }

  bool get podeAvaliar {
    return AgendamentoService.agendamentos.any(
          (a) => a.nomePrestador == "Carlos Martins" && a.concluido,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Perfil do profissional"),
        backgroundColor: const Color(0xFF1E6FD9),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: const BoxDecoration(
                color: Color(0xFF1E6FD9),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      "CM",
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF1E6FD9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Carlos Martins",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Eletricista",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: Colors.white70, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "Capão da Canoa - RS",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      SizedBox(width: 6),
                      Text("4.9", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Serviços oferecidos",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      Chip(label: Text("Instalações")),
                      Chip(label: Text("Reparos")),
                      Chip(label: Text("Quadro elétrico")),
                      Chip(label: Text("Tomadas")),
                      Chip(label: Text("Iluminação")),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Sobre",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),

                  const Text(
                    "Eletricista com 8 anos de experiência, atendendo residências e comércios. Orçamento sem compromisso.",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Localização",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey[300],
                        ),
                        child: const Icon(
                          Icons.map,
                          size: 70,
                          color: Colors.grey,
                        ),
                      ),
                      const Icon(
                        Icons.location_pin,
                        size: 45,
                        color: Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  const Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        "Capão da Canoa - RS",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Avaliações recentes",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  _avaliacao("Serviço rápido e muito bem feito!"),
                  _avaliacao("Pontual e organizado, recomendo!"),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E6FD9),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        if (!AuthService.isLogged) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginScreen(),
                            ),
                          );
                          setState(() {});
                          return;
                        }

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AgendamentoScreen(),
                          ),
                        );

                        setState(() {});
                      },
                      child: const Text("Agendar serviço"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: jaAgendou
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChatScreen(),
                          ),
                        );
                      }
                          : null,
                      icon: const Icon(Icons.chat),
                      label: const Text("Enviar mensagem"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: podeAvaliar
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AvaliacaoScreen(),
                          ),
                        );
                      }
                          : null,
                      icon: const Icon(Icons.star),
                      label: const Text("Avaliar profissional"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _avaliacao(String texto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.orange, size: 16),
          const SizedBox(width: 6),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}