import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController mensagemController = TextEditingController();

  final List<Map<String, dynamic>> mensagens = [
    {
      "texto": "Olá! Tudo bem? Posso ajudar com seu serviço.",
      "minha": false,
      "hora": "14:05",
    },
    {
      "texto": "Olá! Preciso de uma instalação elétrica.",
      "minha": true,
      "hora": "14:06",
    },
    {
      "texto": "Claro! Você já pode me passar mais detalhes.",
      "minha": false,
      "hora": "14:07",
    },
  ];

  void enviarMensagem() {
    final texto = mensagemController.text.trim();

    if (texto.isEmpty) return;

    setState(() {
      mensagens.add({
        "texto": texto,
        "minha": true,
        "hora": "Agora",
      });

      mensagemController.clear();
    });
  }

  @override
  void dispose() {
    mensagemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E6FD9),
        title: Row(
          children: const [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                "CM",
                style: TextStyle(
                  color: Color(0xFF1E6FD9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Carlos Martins",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "Online agora",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mensagens.length,
              itemBuilder: (context, index) {
                final msg = mensagens[index];
                final minha = msg["minha"] as bool;

                return Align(
                  alignment:
                  minha ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: minha ? const Color(0xFF1E6FD9) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(minha ? 16 : 4),
                        bottomRight: Radius.circular(minha ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: minha
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg["texto"],
                          style: TextStyle(
                            color: minha ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          msg["hora"],
                          style: TextStyle(
                            color: minha ? Colors.white70 : Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: mensagemController,
                    decoration: InputDecoration(
                      hintText: "Digite sua mensagem...",
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                CircleAvatar(
                  backgroundColor: const Color(0xFF1E6FD9),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: enviarMensagem,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}