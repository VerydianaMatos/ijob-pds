import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'avaliacao_screen.dart';

class MeusServicosScreen extends StatefulWidget {
  const MeusServicosScreen({super.key});

  @override
  State<MeusServicosScreen> createState() => _MeusServicosScreenState();
}

class _MeusServicosScreenState extends State<MeusServicosScreen> {

  final List<Map<String, dynamic>> servicos = [
    {
      "nome": "Carlos Martins",
      "servico": "Instalação elétrica",
      "data": "10/04",
      "concluido": false
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Meus serviços"),
        backgroundColor: const Color(0xFF1E6FD9),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: servicos.length,
        itemBuilder: (context, index) {

          final item = servicos[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  item["nome"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "${item["servico"]} • ${item["data"]}",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 12),

                if (!item["concluido"])
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

                      const SizedBox(width: 8),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E6FD9),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              item["concluido"] = true;
                            });
                          },
                          child: const Text("Concluir"),
                        ),
                      ),
                    ],
                  ),

                if (item["concluido"])
                  Row(
                    children: [

                      const Expanded(
                        child: Text(
                          "✔ Serviço concluído",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E6FD9),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AvaliacaoScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.star),
                        label: const Text("Avaliar"),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}