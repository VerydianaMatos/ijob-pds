import 'package:flutter/material.dart';

import '../models/mensagem_model.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String contato;
  final String? chatId;

  const ChatScreen({
    super.key,
    this.contato = "Atendimento",
    this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController mensagemController = TextEditingController();

  String get meuNome => AuthService.nome.isEmpty ? "Usuário" : AuthService.nome;

  String get idConversa {
    return widget.chatId ?? ChatService.chatId(meuNome, widget.contato);
  }

  Future<void> enviarMensagem() async {
    final texto = mensagemController.text.trim();
    if (texto.isEmpty) return;

    mensagemController.clear();

    await ChatService.enviar(
      Mensagem(
        chatId: idConversa,
        texto: texto,
        autor: meuNome,
        criadoEm: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    mensagemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _iniciais(widget.contato),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.contato, style: const TextStyle(fontSize: 16)),
                  const Text(
                    "Conversa salva",
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Mensagem>>(
              stream: ChatService.mensagens(idConversa),
              builder: (context, snapshot) {
                final mensagens = snapshot.data ?? [];

                if (mensagens.isEmpty) {
                  return Center(
                    child: Text(
                      "Nenhuma mensagem ainda.",
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    final msg = mensagens[index];
                    final minha = msg.autor == meuNome;

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
                          color: minha ? colorScheme.primary : colorScheme.surface,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(minha ? 16 : 4),
                            bottomRight: Radius.circular(minha ? 4 : 16),
                          ),
                          border: minha
                              ? null
                              : Border.all(
                                  color: colorScheme.outlineVariant
                                      .withOpacity(0.35),
                                ),
                        ),
                        child: Column(
                          crossAxisAlignment: minha
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.texto,
                              style: TextStyle(
                                color: minha
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _hora(msg.criadoEm),
                              style: TextStyle(
                                color: minha
                                    ? colorScheme.onPrimary.withOpacity(0.72)
                                    : colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.35),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: mensagemController,
                      decoration: const InputDecoration(
                        hintText: "Digite sua mensagem...",
                        prefixIcon: Icon(Icons.message),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: enviarMensagem,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _hora(DateTime data) {
    final hora = data.hour.toString().padLeft(2, "0");
    final minuto = data.minute.toString().padLeft(2, "0");
    return "$hora:$minuto";
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(" ");
    if (partes.isEmpty || partes.first.isEmpty) return "A";
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return "${partes[0][0]}${partes[1][0]}".toUpperCase();
  }
}



