import 'package:flutter/material.dart';

import '../models/agendamento_model.dart';
import '../models/prestador_model.dart';
import '../services/agendamento_service.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/prestador_service.dart';
import 'chat_screen.dart';
import 'detalhe_agendamento_screen.dart';

class SolicitacoesPrestadorScreen extends StatefulWidget {
  const SolicitacoesPrestadorScreen({super.key});

  @override
  State<SolicitacoesPrestadorScreen> createState() =>
      _SolicitacoesPrestadorScreenState();
}

class _SolicitacoesPrestadorScreenState
    extends State<SolicitacoesPrestadorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Solicitações recebidas")),
      body: StreamBuilder<Prestador?>(
        stream: PrestadorService.observarPrestadorPorEmail(AuthService.email),
        builder: (context, prestadorSnapshot) {
          final nomePrestador = prestadorSnapshot.data?.nome ?? AuthService.nome;

          return StreamBuilder<List<Agendamento>>(
            stream: AgendamentoService.streamPorPrestadorConta(
              nomePrestador: nomePrestador,
              emailPrestador: AuthService.email,
            ),
            builder: (context, snapshot) {
              final lista = snapshot.hasData
                  ? [...snapshot.data!]
                  : AgendamentoService.porPrestadorConta(
                      nomePrestador: nomePrestador,
                      emailPrestador: AuthService.email,
                    );

              lista.sort(_compararAgendamento);

              if (lista.isEmpty) return _estadoVazio();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lista.length,
                itemBuilder: (context, index) => _cardSolicitacao(lista[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _estadoVazio() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.35),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: colorScheme.primary.withOpacity(0.12),
                child: Icon(
                  Icons.assignment_outlined,
                  color: colorScheme.primary,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Nenhuma solicitação",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                "Quando um cliente solicitar um serviço, o pedido aparecerá aqui.",
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardSolicitacao(Agendamento item) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(item.status);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _abrirDetalhes(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primary.withOpacity(0.12),
                child: Icon(Icons.person, color: colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nomeCliente,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      item.servico,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _statusBadge(item.statusTexto, statusColor),
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
          const SizedBox(height: 16),
          if (item.justificativaPrestador.trim().isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes, color: statusColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.justificativaPrestador,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (item.pendente) _acoesPendente(item),
          if (item.aceito) _acoesAceito(item),
          if (item.emAtendimento) _acoesEmAtendimento(item),
          if (item.recusado)
            Text(
              "Você recusou este pedido. O cliente verá a atualização em Meus serviços.",
              style: TextStyle(color: colorScheme.onSurfaceVariant),
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
        builder: (_) => DetalheAgendamentoScreen(
          agendamento: item,
          prestador: true,
        ),
      ),
    );
  }

  Widget _acoesPendente(Agendamento item) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pedirJustificativa(item: item, aceitar: false),
            icon: const Icon(Icons.close),
            label: const Text("Recusar"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pedirJustificativa(item: item, aceitar: true),
            icon: const Icon(Icons.check),
            label: const Text("Aceitar"),
          ),
        ),
      ],
    );
  }

  Widget _acoesAceito(Agendamento item) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    contato: item.nomeCliente,
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
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _iniciar(item),
            icon: const Icon(Icons.play_arrow),
            label: const Text("Iniciar"),
          ),
        ),
      ],
    );
  }

  Widget _acoesEmAtendimento(Agendamento item) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    contato: item.nomeCliente,
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
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _concluir(item),
            icon: const Icon(Icons.done_all),
            label: const Text("Concluir"),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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

  int _compararAgendamento(Agendamento a, Agendamento b) {
    if (a.pendente && !b.pendente) return -1;
    if (!a.pendente && b.pendente) return 1;

    final dataA = DateTime.tryParse(a.dataAtendimento);
    final dataB = DateTime.tryParse(b.dataAtendimento);

    if (dataA == null && dataB == null) return a.data.compareTo(b.data);
    if (dataA == null) return 1;
    if (dataB == null) return -1;

    final comparacaoData = dataA.compareTo(dataB);
    if (comparacaoData != 0) return comparacaoData;
    return a.horario.compareTo(b.horario);
  }

  Future<void> _pedirJustificativa({
    required Agendamento item,
    required bool aceitar,
  }) async {
    final texto = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        var justificativa = "";
        final titulo = aceitar ? "Aceitar solicitação" : "Recusar solicitação";
        final label = aceitar
            ? "Mensagem para o cliente (opcional)"
            : "Motivo da recusa";

        return AlertDialog(
          title: Text(titulo),
          content: TextField(
            autofocus: true,
            maxLines: 4,
            onChanged: (value) => justificativa = value,
            decoration: InputDecoration(
              labelText: label,
              alignLabelWithHint: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final valor = justificativa.trim();
                if (!aceitar && valor.isEmpty) return;
                Navigator.pop(dialogContext, valor);
              },
              child: Text(aceitar ? "Aceitar" : "Recusar"),
            ),
          ],
        );
      },
    );

    if (texto == null || !mounted) return;

    if (aceitar) {
      await _aceitar(item, texto);
    } else {
      await _recusar(item, texto);
    }
  }

  Future<void> _aceitar(Agendamento item, String justificativa) async {
    final salvo = await AgendamentoService.aceitar(
      item,
      justificativa: justificativa,
    );
    if (!mounted) return;
    setState(() {});

    if (!salvo) {
      _snack("Não foi possível salvar o aceite no banco.", Colors.red);
      return;
    }

    _snack("Solicitação aceita. O cliente já pode ver o status.", Colors.green);
  }

  Future<void> _recusar(Agendamento item, String justificativa) async {
    final salvo = await AgendamentoService.recusar(
      item,
      justificativa: justificativa,
    );
    if (!mounted) return;
    setState(() {});

    if (!salvo) {
      _snack("Não foi possível salvar a recusa no banco.", Colors.red);
      return;
    }

    _snack("Solicitação recusada. O cliente verá a atualização.", Colors.red);
  }

  Future<void> _iniciar(Agendamento item) async {
    final salvo = await AgendamentoService.iniciarAtendimento(item);
    if (!mounted) return;
    setState(() {});

    if (!salvo) {
      _snack("Não foi possível iniciar no banco.", Colors.red);
      return;
    }

    _snack("Atendimento iniciado. O cliente verá a atualização.", Colors.green);
  }

  Future<void> _concluir(Agendamento item) async {
    final salvo = await AgendamentoService.concluir(item);
    if (!mounted) return;
    setState(() {});

    if (!salvo) {
      _snack("Não foi possível concluir no banco.", Colors.red);
      return;
    }

    _snack("Serviço marcado como concluído.", Colors.blue);
  }

  void _snack(String text, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
  }
}



