import 'package:flutter/material.dart';
import '../services/agendamento_service.dart';
import 'chat_screen.dart';
import 'avaliacao_screen.dart';

class MeusServicosScreen extends StatefulWidget {
  const MeusServicosScreen({super.key});

  @override
  State<MeusServicosScreen> createState() => _MeusServicosScreenState();
}

class _MeusServicosScreenState extends State<MeusServicosScreen> {
  String abaSelecionada = "Agendados";

  @override
  Widget build(BuildContext context) {
    final lista = AgendamentoService.agendamentos;

    final filtrados = lista.where((item) {
      if (abaSelecionada == "Agendados") return !item.concluido;
      if (abaSelecionada == "Concluídos") return item.concluido;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Meus serviços"),
        backgroundColor: const Color(0xFF1E6FD9),
      ),
      body: Column(
        children: [
          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _aba("Agendados"),
                const SizedBox(width: 8),
                _aba("Todos"),
                const SizedBox(width: 8),
                _aba("Concluídos"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: filtrados.isEmpty
                ? Center(
              child: Text(
                "Nenhum serviço em $abaSelecionada.",
                style: const TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtrados.length,
              itemBuilder: (context, index) {
                final item = filtrados[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFE3F0FF),
                            child: Icon(
                              Icons.handyman,
                              color: Color(0xFF1E6FD9),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.nomePrestador,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  item.servico,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _status(item.concluido),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.data,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      if (!item.concluido)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ChatScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat),
                                label: const Text("Chat"),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xFF1E6FD9),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    item.concluido = true;
                                  });

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content:
                                      Text("Serviço concluído!"),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check),
                                label: const Text("Concluir"),
                              ),
                            ),
                          ],
                        ),

                      if (item.concluido)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ChatScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat),
                                label: const Text("Chat"),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xFF1E6FD9),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const AvaliacaoScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.star),
                                label: const Text("Avaliar"),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _aba(String titulo) {
    final selecionada = abaSelecionada == titulo;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            abaSelecionada = titulo;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selecionada ? const Color(0xFF1E6FD9) : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            titulo,
            style: TextStyle(
              color: selecionada ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _status(bool concluido) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: concluido
            ? Colors.green.withOpacity(0.12)
            : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        concluido ? "Concluído" : "Agendado",
        style: TextStyle(
          color: concluido ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}