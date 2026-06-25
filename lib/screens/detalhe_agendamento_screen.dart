import 'package:flutter/material.dart';

import '../models/agendamento_model.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import 'avaliacao_screen.dart';
import 'chat_screen.dart';

class DetalheAgendamentoScreen extends StatelessWidget {
  final Agendamento agendamento;
  final bool prestador;

  const DetalheAgendamentoScreen({
    super.key,
    required this.agendamento,
    this.prestador = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Detalhes do serviço")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _hero(context),
            const SizedBox(height: 14),
            _timeline(context),
            const SizedBox(height: 14),
            _informacoes(context),
            const SizedBox(height: 14),
            if (agendamento.observacaoCliente.trim().isNotEmpty)
              _blocoTexto(
                context,
                icon: Icons.notes,
                titulo: "Observação do cliente",
                texto: agendamento.observacaoCliente,
              ),
            if (agendamento.justificativaPrestador.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              _blocoTexto(
                context,
                icon: Icons.assignment,
                titulo: agendamento.recusado
                    ? "Motivo da recusa"
                    : "Mensagem do prestador",
                texto: agendamento.justificativaPrestador,
              ),
            ],
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: agendamento.recusado
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            contato: prestador
                                ? agendamento.nomeCliente
                                : agendamento.nomePrestador,
                            chatId: ChatService.chatId(
                              agendamento.nomeCliente,
                              agendamento.nomePrestador,
                            ),
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.chat),
              label: const Text("Abrir chat"),
            ),
            if (!prestador && agendamento.concluido) ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AvaliacaoScreen(
                        agendamento: agendamento,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.star),
                label: const Text("Avaliar atendimento"),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              "Use esta tela para demonstrar o acompanhamento completo do serviço.",
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.handyman, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agendamento.servico,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      prestador
                          ? agendamento.nomeCliente
                          : agendamento.nomePrestador,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              _statusBadge(context),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  agendamento.data,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeline(BuildContext context) {
    final passos = [
      _Passo("Solicitado", Icons.send, true),
      _Passo("Aceito", Icons.check_circle, _aceitoOuDepois),
      _Passo("Em atendimento", Icons.build_circle, _emAtendimentoOuDepois),
      _Passo("Concluído", Icons.done_all, agendamento.concluido),
      _Passo("Avaliação", Icons.star, agendamento.concluido),
    ];

    return _card(
      context,
      titulo: "Acompanhamento",
      child: Column(
        children: passos.map((passo) {
          final index = passos.indexOf(passo);
          final ultimo = index == passos.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: passo.ativo
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      passo.icon,
                      size: 17,
                      color: passo.ativo
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (!ultimo)
                    Container(
                      width: 2,
                      height: 28,
                      color: passo.ativo
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    passo.titulo,
                    style: TextStyle(
                      fontWeight: passo.ativo ? FontWeight.w800 : FontWeight.w500,
                      color: passo.ativo
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _informacoes(BuildContext context) {
    return _card(
      context,
      titulo: "Informações",
      child: Column(
        children: [
          _linha(context, Icons.person, "Cliente", agendamento.nomeCliente),
          _linha(context, Icons.work, "Prestador", agendamento.nomePrestador),
          _linha(context, Icons.schedule, "Horário",
              agendamento.horario.isEmpty ? "A combinar" : agendamento.horario),
          _linha(context, Icons.payments, "Valor previsto",
              agendamento.valorPrevisto.isEmpty
                  ? "A combinar"
                  : agendamento.valorPrevisto),
        ],
      ),
    );
  }

  Widget _blocoTexto(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String texto,
  }) {
    return _card(
      context,
      titulo: titulo,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String titulo,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _linha(
    BuildContext context,
    IconData icon,
    String label,
    String valor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(BuildContext context) {
    final color = _statusColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        agendamento.statusTexto,
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12),
      ),
    );
  }

  bool get _aceitoOuDepois {
    return agendamento.aceito ||
        agendamento.emAtendimento ||
        agendamento.concluido;
  }

  bool get _emAtendimentoOuDepois {
    return agendamento.emAtendimento || agendamento.concluido;
  }

  Color get _statusColor {
    if (agendamento.recusado) return Colors.redAccent;
    if (agendamento.concluido) return Colors.lightBlueAccent;
    if (agendamento.emAtendimento) return Colors.amberAccent;
    if (agendamento.aceito) return Colors.greenAccent;
    return Colors.orangeAccent;
  }
}

class _Passo {
  final String titulo;
  final IconData icon;
  final bool ativo;

  const _Passo(this.titulo, this.icon, this.ativo);
}
