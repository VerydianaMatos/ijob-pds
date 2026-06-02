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

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;

        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E6FD9),

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

                  SizedBox(height: 2),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.greenAccent,
                      ),

                      SizedBox(width: 5),

                      Text(
                        "Online agora",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
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

          // TOPO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            color: const Color(0xFFEAF2FF),

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

          // MENSAGENS
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: mensagens.length,
              itemBuilder: (context, index) {
                final msg = mensagens[index];

                final minha = msg["minha"] as bool;

                return Align(
                  alignment:
                  minha
                      ? Alignment.centerRight
                      : Alignment.centerLeft,

                  child: Column(
                    crossAxisAlignment:
                    minha
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,

                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),

                        constraints: BoxConstraints(
                          maxWidth:
                          MediaQuery.of(context).size.width * 0.75,
                        ),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),

                        decoration: BoxDecoration(
                          color:
                          minha
                              ? const Color(0xFF1E6FD9)
                              : Colors.white,

                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft:
                            Radius.circular(minha ? 18 : 5),
                            bottomRight:
                            Radius.circular(minha ? 5 : 18),
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: Text(
                          msg["texto"],
                          style: TextStyle(
                            color:
                            minha
                                ? Colors.white
                                : Colors.black87,

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
                              style: TextStyle(
                                color:
                                minha
                                    ? Colors.grey
                                    : Colors.grey,

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

          // CAMPO
          Container(
            padding: const EdgeInsets.fromLTRB(
              12,
              10,
              12,
              14,
            ),

            decoration: const BoxDecoration(
              color: Colors.white,
            ),

            child: SafeArea(
              top: false,
              child: Row(
                children: [

                  // INPUT
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(30),
                      ),

                      child: Row(
                        children: [
                          const SizedBox(width: 14),

                          const Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: TextField(
                              controller: mensagemController,

                              minLines: 1,
                              maxLines: 5,

                              decoration: const InputDecoration(
                                hintText: "Digite sua mensagem...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.attach_file,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ENVIAR
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

                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF1E6FD9,
                            ).withOpacity(0.3),

                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
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