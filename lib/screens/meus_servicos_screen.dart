import 'package:flutter/material.dart';

import '../models/agendamento_model.dart';
import '../services/agendamento_service.dart';

import 'chat_screen.dart';
import 'avaliacao_screen.dart';

class MeusServicosScreen extends StatefulWidget {
  const MeusServicosScreen({super.key});

  @override
  State<MeusServicosScreen> createState() => _MeusServicosScreenState();
}

class _MeusServicosScreenState extends State<MeusServicosScreen> {
  String abaSelecionada = "Agendados";
  bool carregando = true;

  List<Agendamento> agendamentos = [];

  @override
  void initState() {
    super.initState();
    carregarAgendamentos();
  }

  Future<void> carregarAgendamentos() async {
    setState(() {
      carregando = true;
    });

    final lista = await AgendamentoService.carregarAgendamentos();

    if (!mounted) return;

    setState(() {
      agendamentos = lista;
      carregando = false;
    });
  }

  List<Agendamento> get filtrados {
    return agendamentos.where((item) {
      if (abaSelecionada == "Agendados") return !item.concluido;
      if (abaSelecionada == "Concluídos") return item.concluido;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lista = filtrados;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Meus serviços"),
        backgroundColor: const Color(0xFF1E6FD9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: RefreshIndicator(
        onRefresh: carregarAgendamentos,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _topo()),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    _aba("Agendados"),
                    const SizedBox(width: 8),
                    _aba("Todos"),
                    const SizedBox(width: 8),
                    _aba("Concluídos"),
                  ],
                ),
              ),
            ),

            if (carregando)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1E6FD9),
                  ),
                ),
              ),

            if (!carregando && lista.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _vazio(),
              ),

            if (!carregando && lista.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.builder(
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final item = lista[index];
                    return _cardServico(item);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _topo() {
    final total = agendamentos.length;
    final concluidos = agendamentos.where((a) => a.concluido).length;
    final pendentes = agendamentos.where((a) => !a.concluido).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E6FD9),
            Color(0xFF3D8BFF),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Acompanhe seus serviços",
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Veja seus agendamentos e acompanhe o andamento.",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _resumoCard(
                  titulo: "Total",
                  valor: total.toString(),
                  icon: Icons.calendar_month,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _resumoCard(
                  titulo: "Agendados",
                  valor: pendentes.toString(),
                  icon: Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _resumoCard(
                  titulo: "Concluídos",
                  valor: concluidos.toString(),
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resumoCard({
    required String titulo,
    required String valor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aba(String titulo) {
    final selecionada = abaSelecionada == titulo;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            abaSelecionada = titulo;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selecionada ? const Color(0xFF1E6FD9) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (selecionada)
                BoxShadow(
                  color: const Color(0xFF1E6FD9).withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            titulo,
            style: TextStyle(
              color: selecionada ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardServico(Agendamento item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFE3F0FF),
                child: Text(
                  item.nomePrestador.isNotEmpty
                      ? item.nomePrestador[0].toUpperCase()
                      : "?",
                  style: const TextStyle(
                    color: Color(0xFF1E6FD9),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),

              const SizedBox(width: 12),

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

                    const SizedBox(height: 3),

                    Text(
                      item.servico,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              _status(item.concluido),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 18,
                  color: Color(0xFF1E6FD9),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.data,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (!item.concluido)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatScreen(),
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
                    onPressed: () async {
                      await AgendamentoService.concluirAgendamento(item);
                      await carregarAgendamentos();

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Serviço concluído!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("Concluir"),
                  ),
                ),
              ],
            ),

          if (item.concluido)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatScreen(),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AvaliacaoScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.star),
                    label: const Text("Avaliar"),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _status(bool concluido) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: concluido
            ? Colors.green.withOpacity(0.12)
            : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        concluido ? "Concluído" : "Agendado",
        style: TextStyle(
          color: concluido ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _vazio() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: 68,
              color: Colors.grey,
            ),
            SizedBox(height: 14),
            Text(
              "Nenhum serviço encontrado",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Quando você agendar um serviço, ele aparecerá aqui.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}