import 'package:flutter/material.dart';

import '../models/agendamento_model.dart';
import '../services/agendamento_service.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import 'avaliacao_screen.dart';
import 'chat_screen.dart';
import 'detalhe_agendamento_screen.dart';

class MeusServicosScreen extends StatefulWidget {
  const MeusServicosScreen({super.key});

  @override
  State<MeusServicosScreen> createState() => _MeusServicosScreenState();
}

class _MeusServicosScreenState extends State<MeusServicosScreen> {
  String abaSelecionada = "Ativos";

  @override
  Widget build(BuildContext context) {
    final nomeCliente = AuthService.nome;

    return Scaffold(
      appBar: AppBar(title: const Text("Meus serviços")),
      body: StreamBuilder<List<Agendamento>>(
        stream: nomeCliente.isEmpty
            ? null
            : AgendamentoService.streamPorCliente(nomeCliente),
        builder: (context, snapshot) {
          final lista = snapshot.hasData
              ? snapshot.data!
              : nomeCliente.isEmpty
              ? AgendamentoService.agendamentos
              : AgendamentoService.porCliente(nomeCliente);

          return _conteudo(lista);
        },
      ),
    );
  }

  Widget _conteudo(List<Agendamento> lista) {
    final colorScheme = Theme.of(context).colorScheme;
    final atualizados = lista
        .where((item) => item.aceito || item.recusado)
        .length;
    final filtrados = lista.where((item) {
      if (abaSelecionada == "Ativos") {
        return item.pendente || item.aceito || item.emAtendimento;
      }
      if (abaSelecionada == "Concluídos") return item.concluido;
      return true;
    }).toList();

    return Column(
      children: [
        if (atualizados > 0)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.primary.withOpacity(0.18)),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_active, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Você tem atualização em $atualizados agendamento(s).",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              _aba("Ativos"),
              const SizedBox(width: 8),
              _aba("Todos"),
              const SizedBox(width: 8),
              _aba("Concluídos"),
            ],
          ),
        ),
        Expanded(
          child: filtrados.isEmpty
              ? Center(
                  child: Text(
                    "Nenhum serviço em $abaSelecionada.",
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtrados.length,
                  itemBuilder: (context, index) {
                    return _servicoCard(filtrados[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _aba(String titulo) {
    final colorScheme = Theme.of(context).colorScheme;
    final selecionada = abaSelecionada == titulo;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => abaSelecionada = titulo),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selecionada ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selecionada
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            titulo,
            style: TextStyle(
              color: selecionada ? Colors.white : colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _servicoCard(Agendamento item) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _abrirDetalhes(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary.withOpacity(0.12),
                  child: Icon(Icons.handyman, color: colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _status(item.status),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.data,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _mensagemStatus(item),
              style: TextStyle(
                color: _statusColor(item.status),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (item.justificativaPrestador.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusColor(item.status).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes,
                      size: 18,
                      color: _statusColor(item.status),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.recusado
                                ? "Justificativa da recusa"
                                : "Mensagem do prestador",
                            style: TextStyle(
                              color: _statusColor(item.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.justificativaPrestador,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: item.recusado
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  contato: item.nomePrestador,
                                  chatId: ChatService.chatId(
                                    item.nomeCliente,
                                    item.nomePrestador,
                                  ),
                                ),
                              ),
                            );
                          },
                    icon: const Icon(Icons.chat),
                    label: const Text("Chat"),
                  ),
                ),
                if (item.concluido) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AvaliacaoScreen(agendamento: item),
                          ),
                        );
                      },
                      icon: const Icon(Icons.star),
                      label: const Text("Avaliar"),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _abrirDetalhes(Agendamento item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalheAgendamentoScreen(agendamento: item),
      ),
    );
  }

  String _mensagemStatus(Agendamento item) {
    switch (item.status) {
      case StatusAgendamento.pendente:
        return "Aguardando o prestador aceitar.";
      case StatusAgendamento.aceito:
        return "Agendamento aceito pelo prestador.";
      case StatusAgendamento.emAtendimento:
        return "O atendimento está em andamento.";
      case StatusAgendamento.recusado:
        return "O prestador recusou este agendamento.";
      case StatusAgendamento.concluido:
        return "Serviço concluído. Você já pode avaliar.";
    }
  }

  Widget _status(StatusAgendamento status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 14, color: _statusColor(status)),
          const SizedBox(width: 4),
          Text(
            _statusTexto(status),
            style: TextStyle(
              color: _statusColor(status),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(StatusAgendamento status) {
    switch (status) {
      case StatusAgendamento.pendente:
        return Icons.schedule;
      case StatusAgendamento.aceito:
        return Icons.check_circle;
      case StatusAgendamento.emAtendimento:
        return Icons.handyman;
      case StatusAgendamento.recusado:
        return Icons.cancel;
      case StatusAgendamento.concluido:
        return Icons.done_all;
    }
  }

  String _statusTexto(StatusAgendamento status) {
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

  Color _statusColor(StatusAgendamento status) {
    switch (status) {
      case StatusAgendamento.aceito:
        return Colors.green;
      case StatusAgendamento.emAtendimento:
        return Colors.deepPurple;
      case StatusAgendamento.recusado:
        return Colors.red;
      case StatusAgendamento.concluido:
        return Colors.blue;
      case StatusAgendamento.pendente:
        return Colors.orange;
    }
  }
}
