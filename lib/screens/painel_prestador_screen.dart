import 'dart:io';

import 'package:flutter/material.dart';

import '../models/agendamento_model.dart';
import '../models/prestador_model.dart';
import '../services/agendamento_service.dart';
import '../services/auth_service.dart';
import '../services/prestador_service.dart';
import 'chat_screen.dart';
import 'editar_prestador_screen.dart';
import 'home_screen.dart';
import 'perfil_prestador_screen.dart';
import 'solicitacoes_prestador_screen.dart';

class PainelPrestadorScreen extends StatefulWidget {
  const PainelPrestadorScreen({super.key});

  @override
  State<PainelPrestadorScreen> createState() => _PainelPrestadorScreenState();
}

class _PainelPrestadorScreenState extends State<PainelPrestadorScreen> {
  @override
  Widget build(BuildContext context) {
    final nome = AuthService.nome.isEmpty ? "Prestador" : AuthService.nome;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel do prestador"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: StreamBuilder<Prestador?>(
        stream: PrestadorService.observarPrestadorPorEmail(AuthService.email),
        builder: (context, prestadorSnapshot) {
          final prestador = prestadorSnapshot.data;
          final nomePrestador = prestador?.nome ?? nome;

          return StreamBuilder<List<Agendamento>>(
            stream: AgendamentoService.streamPorPrestadorConta(
              nomePrestador: nomePrestador,
              emailPrestador: AuthService.email,
            ),
            builder: (context, snapshot) {
              final solicitacoes = snapshot.hasData
                  ? snapshot.data!
                  : AgendamentoService.porPrestadorConta(
                      nomePrestador: nomePrestador,
                      emailPrestador: AuthService.email,
                    );

              return _conteudo(nomePrestador, prestador, solicitacoes);
            },
          );
        },
      ),
    );
  }

  Widget _conteudo(
    String nome,
    Prestador? prestador,
    List<Agendamento> solicitacoes,
  ) {
    final pendentes = solicitacoes.where((item) => item.pendente).length;
    final aceitos =
        solicitacoes.where((item) => item.aceito || item.emAtendimento).length;
    final concluidos = solicitacoes.where((item) => item.concluido).length;
    final proximos = solicitacoes
        .where((item) => item.pendente || item.aceito || item.emAtendimento)
        .toList()
      ..sort(_compararAgendamento);
    final proximosResumo = proximos
        .take(3)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        children: [
          _hero(nome, prestador),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: _ResumoCard(
                    titulo: "Pendentes",
                    valor: pendentes.toString(),
                    icon: Icons.assignment,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ResumoCard(
                    titulo: "Aceitos",
                    valor: aceitos.toString(),
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ResumoCard(
                    titulo: "Concluídos",
                    valor: concluidos.toString(),
                    icon: Icons.done_all,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _agendaSemana(proximos),
          const SizedBox(height: 12),
          _agendaResumo(proximosResumo),
          const SizedBox(height: 10),
          _OpcaoPainel(
            icon: Icons.assignment,
            titulo: "Solicitações recebidas",
            subtitulo: "Aceite, recuse e conclua atendimentos",
            badge: pendentes > 0 ? pendentes.toString() : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SolicitacoesPrestadorScreen(),
                ),
              ).then((_) => setState(() {}));
            },
          ),
          _OpcaoPainel(
            icon: Icons.handyman,
            titulo: "Meu perfil público",
            subtitulo: "Veja como os clientes enxergam seu perfil",
            onTap: prestador == null
                ? () => _mensagem("Perfil profissional não encontrado.")
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PerfilPrestadorScreen(
                          prestador: prestador,
                        ),
                      ),
                    );
                  },
          ),
          _OpcaoPainel(
            icon: Icons.chat,
            titulo: "Mensagens",
            subtitulo: "Converse com clientes",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatScreen(contato: "Clientes"),
                ),
              );
            },
          ),
          _OpcaoPainel(
            icon: Icons.edit,
            titulo: "Editar perfil profissional",
            subtitulo: "Foto, agenda, preço e disponibilidade",
            onTap: prestador == null
                ? () => _mensagem("Perfil profissional não encontrado.")
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditarPrestadorScreen(
                          prestador: prestador,
                        ),
                      ),
                    );
                  },
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  AuthService.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Sair"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(String nome, Prestador? prestador) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white,
            backgroundImage: _fotoProvider(prestador),
            child: _fotoProvider(prestador) == null
                ? const Icon(Icons.work, size: 38, color: Color(0xFF1E6FD9))
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            nome,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Gerencie sua agenda, solicitações e perfil",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _agendaResumo(List<Agendamento> proximos) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.today),
              SizedBox(width: 8),
              Text(
                "Próximos atendimentos",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (proximos.isEmpty)
            Text(
              "Nenhum atendimento pendente, aceito ou em andamento.",
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            )
          else
            ...proximos.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primary.withOpacity(0.12),
                  child: Icon(Icons.person, color: colorScheme.primary),
                ),
                title: Text(item.nomeCliente),
                subtitle: Text("${item.data} • ${item.statusTexto}"),
                trailing: IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(contato: item.nomeCliente),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _agendaSemana(List<Agendamento> proximos) {
    final colorScheme = Theme.of(context).colorScheme;
    final semana = _servicosDaSemana(proximos);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18),
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
              Icon(Icons.calendar_view_week, color: colorScheme.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Agenda da semana",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (semana.isEmpty)
            Text(
              "Nenhum serviço aceito ou pendente para esta semana.",
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            )
          else
            ...semana.map((item) => _itemAgendaSemana(item)),
        ],
      ),
    );
  }

  Widget _itemAgendaSemana(Agendamento item) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = item.pendente
        ? Colors.orange
        : item.aceito
            ? Colors.green
            : item.emAtendimento
                ? Colors.deepPurple
            : colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _diaCurto(item),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _diaMes(item),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nomeCliente,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  "${item.servico} • ${item.horario.isEmpty ? item.data : item.horario}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.statusTexto,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Agendamento> _servicosDaSemana(List<Agendamento> origem) {
    final hoje = DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final fimSemana = inicioHoje.add(const Duration(days: 7));

    return origem.where((item) {
      final data = _dataAgendamento(item);
      if (data == null) return true;
      return !data.isBefore(inicioHoje) && data.isBefore(fimSemana);
    }).toList();
  }

  int _compararAgendamento(Agendamento a, Agendamento b) {
    final dataA = _dataAgendamento(a);
    final dataB = _dataAgendamento(b);

    if (dataA == null && dataB == null) return a.data.compareTo(b.data);
    if (dataA == null) return 1;
    if (dataB == null) return -1;

    final comparacaoData = dataA.compareTo(dataB);
    if (comparacaoData != 0) return comparacaoData;
    return a.horario.compareTo(b.horario);
  }

  DateTime? _dataAgendamento(Agendamento item) {
    if (item.dataAtendimento.isEmpty) return null;
    return DateTime.tryParse(item.dataAtendimento);
  }

  String _diaCurto(Agendamento item) {
    final data = _dataAgendamento(item);
    if (data == null) return "Dia";

    const dias = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"];
    return dias[data.weekday - 1];
  }

  String _diaMes(Agendamento item) {
    final data = _dataAgendamento(item);
    if (data == null) return "--";
    return data.day.toString().padLeft(2, "0");
  }

  ImageProvider? _fotoProvider(Prestador? prestador) {
    final fotoPath = prestador?.fotoPath ?? "";
    if (fotoPath.isEmpty) return null;

    if (fotoPath.startsWith("http")) {
      return NetworkImage(fotoPath);
    }

    final arquivo = File(fotoPath);
    if (!arquivo.existsSync()) return null;

    return FileImage(arquivo);
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icon;

  const _ResumoCard({
    required this.titulo,
    required this.valor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 104,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _OpcaoPainel extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final String? badge;
  final VoidCallback onTap;

  const _OpcaoPainel({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary.withOpacity(0.12),
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}



