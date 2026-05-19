import 'package:flutter/material.dart';

import '../models/prestador_model.dart';
import '../services/auth_service.dart';
import '../services/agendamento_service.dart';
import '../services/favorito_service.dart';

import 'login_screen.dart';
import 'agendamento_screen.dart';
import 'chat_screen.dart';
import 'avaliacao_screen.dart';

class PerfilPrestadorScreen extends StatefulWidget {
  final Prestador prestador;

  const PerfilPrestadorScreen({
    super.key,
    required this.prestador,
  });

  @override
  State<PerfilPrestadorScreen> createState() => _PerfilPrestadorScreenState();
}

class _PerfilPrestadorScreenState extends State<PerfilPrestadorScreen> {
  bool get jaAgendou {
    return AgendamentoService.agendamentos.any(
          (a) => a.nomePrestador == widget.prestador.nome,
    );
  }

  bool get podeAvaliar {
    return AgendamentoService.agendamentos.any(
          (a) => a.nomePrestador == widget.prestador.nome && a.concluido,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prestador = widget.prestador;
    final favorito = FavoritoService.isFavorito(prestador.nome);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E6FD9),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Perfil do profissional",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                FavoritoService.alternarFavorito({
                  "nome": prestador.nome,
                  "profissao": prestador.profissao,
                  "distancia": prestador.distancia,
                  "rating": prestador.rating,
                  "disponivel": prestador.disponivel,
                });
              });
            },
            icon: Icon(
              favorito ? Icons.favorite : Icons.favorite_border,
              color: favorito ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                color: Color(0xFF1E6FD9),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE3F0FF),
                      ),
                      child: Center(
                        child: Text(
                          _iniciais(prestador.nome),
                          style: const TextStyle(
                            fontSize: 24,
                            color: Color(0xFF1E6FD9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    prestador.nome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    prestador.profissao,
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 8),

                  const Row(
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

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        prestador.rating.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: prestador.disponivel ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      prestador.disponivel ? "Disponível" : "Ocupado",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _infoCard(
                          Icons.attach_money,
                          prestador.preco,
                          "Preço médio",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _infoCard(
                          Icons.flash_on,
                          prestador.resposta,
                          "Resposta",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _infoCard(
                          Icons.work,
                          prestador.servicos,
                          "Serviços",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Serviços oferecidos",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _chipsPorCategoria(prestador.categoria),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Sobre",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    prestador.descricao,
                    style: const TextStyle(
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Localização",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),

                  const SizedBox(height: 12),

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(18),
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

                  const SizedBox(height: 8),

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

                  const SizedBox(height: 24),

                  const Text(
                    "Avaliações recentes",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),

                  const SizedBox(height: 10),

                  _avaliacao("Muito rápido e eficiente!"),
                  _avaliacao("Excelente profissional, recomendo!"),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E6FD9),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                      icon: const Icon(Icons.calendar_month),
                      label: const Text("Agendar serviço"),
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

  Widget _infoCard(IconData icon, String valor, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF1E6FD9)),
          const SizedBox(height: 8),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  List<Widget> _chipsPorCategoria(String categoria) {
    final Map<String, List<String>> dados = {
      "Elétrica": [
        "Instalações",
        "Reparos",
        "Quadro elétrico",
        "Tomadas",
        "Iluminação",
      ],
      "Limpeza": [
        "Limpeza residencial",
        "Limpeza pesada",
        "Organização",
        "Faxina completa",
      ],
      "Hidráulica": [
        "Vazamentos",
        "Encanamento",
        "Torneiras",
        "Manutenção",
      ],
      "Pintura": [
        "Pintura interna",
        "Pintura externa",
        "Acabamento",
        "Textura",
      ],
      "Frete": [
        "Mudanças",
        "Entregas",
        "Transporte",
        "Carretos",
      ],
    };

    final lista = dados[categoria] ?? ["Serviço geral"];

    return lista.map((item) => Chip(label: Text(item))).toList();
  }

  Widget _avaliacao(String texto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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

  String _iniciais(String nome) {
    final partes = nome.trim().split(" ");

    if (partes.length == 1) {
      return partes.first[0].toUpperCase();
    }

    return "${partes[0][0]}${partes[1][0]}".toUpperCase();
  }
}