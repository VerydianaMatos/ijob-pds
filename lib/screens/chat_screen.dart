import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController mensagemController = TextEditingController();
  final ScrollController scrollController = ScrollController();

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
        "hora": _horaAtual(),
      });

      mensagemController.clear();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        mensagens.add({
          "texto": "Perfeito! Já estou analisando seu pedido 👌",
          "minha": false,
          "hora": _horaAtual(),
        });
      });
    });
  }

  String _horaAtual() {
    final now = DateTime.now();
    final hora = now.hour.toString().padLeft(2, '0');
    final minuto = now.minute.toString().padLeft(2, '0');
    return "$hora:$minuto";
  }

  @override
  void dispose() {
    mensagemController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Text(
                "CM",
                style: TextStyle(
                  color: Color(0xFF1E6FD9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Carlos Martins",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Online agora",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEAF2FF),
            child: const Row(
              children: [
                Icon(
                  Icons.security,
                  color: Color(0xFF1E6FD9),
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Conversa protegida e segura pelo IJob",
                    style: TextStyle(
                      color: Color(0xFF1E6FD9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: mensagens.length,
              itemBuilder: (context, index) {
                final msg = mensagens[index];
                final minha = msg["minha"] as bool;

                return Align(
                  alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment:
                    minha ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: minha
                              ? const Color(0xFF1E6FD9)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(minha ? 18 : 5),
                            bottomRight: Radius.circular(minha ? 5 : 18),
                          ),
                        ),
                        child: Text(
                          msg["texto"],
                          style: TextStyle(
                            color: minha ? Colors.white : null,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 14,
                          left: 4,
                          right: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg["hora"],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            if (minha) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.done_all,
                                size: 15,
                                color: Color(0xFF1E6FD9),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            color: Theme.of(context).cardColor,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: mensagemController,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: "Digite sua mensagem...",
                        prefixIcon: Icon(Icons.emoji_emotions_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: enviarMensagem,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1E6FD9),
                            Color(0xFF3D8BFF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}