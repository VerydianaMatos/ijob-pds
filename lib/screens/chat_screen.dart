import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> mensagens = [
    {"texto": "Olá! Posso ajudar?", "me": false},
    {"texto": "Preciso instalar 2 tomadas", "me": true},
  ];

  void enviarMensagem() {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      mensagens.add({
        "texto": controller.text,
        "me": true,
      });
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carlos Martins"),
        backgroundColor: const Color(0xFF1E6FD9),
      ),
      body: Column(
        children: [

          // 💬 MENSAGENS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mensagens.length,
              itemBuilder: (context, index) {
                final msg = mensagens[index];

                return Align(
                  alignment:
                  msg["me"] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg["me"]
                          ? const Color(0xFF1E6FD9)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["texto"],
                      style: TextStyle(
                        color: msg["me"] ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ✏️ INPUT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Digite uma mensagem...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF1E6FD9)),
                  onPressed: enviarMensagem,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}