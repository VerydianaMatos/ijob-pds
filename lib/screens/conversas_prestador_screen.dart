import 'package:flutter/material.dart';

import '../models/agendamento_model.dart';
import '../services/agendamento_service.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class ConversasPrestadorScreen extends StatelessWidget {
  const ConversasPrestadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nomePrestador = AuthService.nome;
    final emailPrestador = AuthService.email;

    return Scaffold(
      appBar: AppBar(title: const Text("Conversas")),
      body: StreamBuilder<List<Agendamento>>(
        stream: AgendamentoService.streamPorPrestadorConta(
          nomePrestador: nomePrestador,
          emailPrestador: emailPrestador,
        ),
        builder: (context, snapshot) {
          final agendamentos = snapshot.hasData
              ? snapshot.data!
              : AgendamentoService.porPrestadorConta(
                  nomePrestador: nomePrestador,
                  emailPrestador: emailPrestador,
                );
          final conversas = _conversasPorCliente(agendamentos);

          if (conversas.isEmpty) {
            return const _EstadoVazioConversas();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: conversas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final conversa = conversas[index];
              return _ConversaClienteCard(conversa: conversa);
            },
          );
        },
      ),
    );
  }

  List<_ConversaCliente> _conversasPorCliente(List<Agendamento> agendamentos) {
    final porCliente = <String, Agendamento>{};

    for (final item in agendamentos) {
      final nomeCliente = item.nomeCliente.trim();
      if (nomeCliente.isEmpty) continue;

      final atual = porCliente[nomeCliente];
      if (atual == null || _ordem(item).compareTo(_ordem(atual)) >= 0) {
        porCliente[nomeCliente] = item;
      }
    }

    final conversas = porCliente.values
        .map((item) => _ConversaCliente(agendamento: item))
        .toList();

    conversas.sort(
      (a, b) => _ordem(b.agendamento).compareTo(_ordem(a.agendamento)),
    );

    return conversas;
  }

  String _ordem(Agendamento item) {
    if (item.dataAtendimento.isNotEmpty) return item.dataAtendimento;
    return item.data;
  }
}

class _ConversaCliente {
  final Agendamento agendamento;

  const _ConversaCliente({required this.agendamento});

  String get nomeCliente => agendamento.nomeCliente;
  String get servico => agendamento.servico;
  String get status => agendamento.statusTexto;
  String get data => agendamento.horario.isEmpty
      ? agendamento.data
      : "${agendamento.data} • ${agendamento.horario}";
}

class _ConversaClienteCard extends StatelessWidget {
  final _ConversaCliente conversa;

  const _ConversaClienteCard({required this.conversa});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final agendamento = conversa.agendamento;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              contato: conversa.nomeCliente,
              chatId: ChatService.chatId(
                conversa.nomeCliente,
                AuthService.nome,
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.38),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: colorScheme.primary.withOpacity(0.12),
              child: Text(
                _iniciais(conversa.nomeCliente),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversa.nomeCliente,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _StatusConversa(status: agendamento.status),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    conversa.servico,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversa.data,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r"\s+"));
    if (partes.isEmpty || partes.first.isEmpty) return "C";
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return "${partes[0][0]}${partes[1][0]}".toUpperCase();
  }
}

class _StatusConversa extends StatelessWidget {
  final StatusAgendamento status;

  const _StatusConversa({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _cor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _texto,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String get _texto {
    switch (status) {
      case StatusAgendamento.pendente:
        return "Pendente";
      case StatusAgendamento.aceito:
        return "Aceito";
      case StatusAgendamento.emAtendimento:
        return "Em atendimento";
      case StatusAgendamento.recusado:
        return "Recusado";
      case StatusAgendamento.concluido:
        return "Concluído";
    }
  }

  Color get _cor {
    switch (status) {
      case StatusAgendamento.pendente:
        return Colors.orange;
      case StatusAgendamento.aceito:
        return Colors.green;
      case StatusAgendamento.emAtendimento:
        return Colors.deepPurple;
      case StatusAgendamento.recusado:
        return Colors.red;
      case StatusAgendamento.concluido:
        return Colors.blue;
    }
  }
}

class _EstadoVazioConversas extends StatelessWidget {
  const _EstadoVazioConversas();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mark_chat_unread_outlined,
              size: 52,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            const Text(
              "Nenhum cliente ainda",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Quando um cliente fizer uma solicitação, ele aparecerá aqui para você iniciar a conversa.",
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
