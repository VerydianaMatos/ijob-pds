import 'package:flutter/material.dart';

import '../models/agendamento_model.dart';
import '../models/avaliacao_model.dart';
import '../services/auth_service.dart';
import '../services/avaliacao_service.dart';

class AvaliacaoScreen extends StatefulWidget {
  final Agendamento? agendamento;

  const AvaliacaoScreen({
    super.key,
    this.agendamento,
  });

  @override
  State<AvaliacaoScreen> createState() => _AvaliacaoScreenState();
}

class _AvaliacaoScreenState extends State<AvaliacaoScreen> {
  int estrelas = 0;
  bool enviando = false;
  final TextEditingController comentarioController = TextEditingController();

  final List<String> tags = [
    "Pontual",
    "Educado",
    "Preço justo",
    "Rápido",
    "Organizado",
  ];

  final List<String> selecionadas = [];

  Future<void> enviarAvaliacao() async {
    if (estrelas == 0) {
      _mensagem("Selecione uma nota em estrelas.", Colors.red);
      return;
    }

    final agendamento = widget.agendamento;
    if (agendamento == null) {
      _mensagem("Atendimento não encontrado para avaliação.", Colors.red);
      return;
    }

    setState(() {
      enviando = true;
    });

    try {
      await AvaliacaoService.adicionar(
        Avaliacao(
          nomePrestador: agendamento.nomePrestador,
          nomeCliente: AuthService.nome.isEmpty
              ? agendamento.nomeCliente
              : AuthService.nome,
          servico: agendamento.servico,
          estrelas: estrelas,
          comentario: comentarioController.text.trim(),
          tags: selecionadas,
          criadoEm: DateTime.now(),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        enviando = false;
      });
      _mensagem("Não foi possível enviar a avaliação agora.", Colors.red);
      return;
    }

    if (!mounted) return;

    _mensagem("Avaliação enviada com sucesso!", Colors.green);
    Navigator.pop(context);
  }

  void _mensagem(String texto, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: cor),
    );
  }

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final agendamento = widget.agendamento;
    final nome = agendamento?.nomePrestador ?? "Prestador";
    final servico = agendamento?.servico ?? "Serviço";

    return Scaffold(
      appBar: AppBar(title: const Text("Avaliar serviço")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.35),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: colorScheme.primary.withOpacity(0.12),
                    child: Text(
                      _iniciais(nome),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    servico,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Como foi o serviço?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final ativo = index < estrelas;

                      return IconButton(
                        onPressed: () {
                          setState(() {
                            estrelas = index + 1;
                          });
                        },
                        icon: Icon(
                          Icons.star,
                          size: 34,
                          color: ativo ? Colors.orange : Colors.grey[300],
                        ),
                      );
                    }),
                  ),
                  Text(
                    estrelas == 0
                        ? "Toque nas estrelas para avaliar"
                        : "$estrelas de 5 estrelas",
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Destaques do atendimento",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                final selecionada = selecionadas.contains(tag);

                return FilterChip(
                  label: Text(tag),
                  selected: selecionada,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        selecionadas.add(tag);
                      } else {
                        selecionadas.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Comentário",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: comentarioController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Conte como foi sua experiência...",
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: enviando ? null : enviarAvaliacao,
              icon: enviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(enviando ? "Enviando..." : "Enviar avaliação"),
            ),
          ],
        ),
      ),
    );
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(" ");

    if (partes.isEmpty || partes.first.isEmpty) return "P";
    if (partes.length == 1) return partes.first[0].toUpperCase();

    return "${partes[0][0]}${partes[1][0]}".toUpperCase();
  }
}



