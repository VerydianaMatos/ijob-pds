import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/agendamento_service.dart';

import 'home_screen.dart';
import 'solicitacoes_prestador_screen.dart';
import 'chat_screen.dart';

class PainelPrestadorScreen extends StatefulWidget {
  const PainelPrestadorScreen({super.key});

  @override
  State<PainelPrestadorScreen> createState() =>
      _PainelPrestadorScreenState();
}

class _PainelPrestadorScreenState
    extends State<PainelPrestadorScreen> {
  @override
  Widget build(BuildContext context) {
    final totalServicos =
        AgendamentoService.agendamentos.length;

    final concluidos =
        AgendamentoService.agendamentos
            .where((a) => a.concluido)
            .length;

    final pendentes =
        AgendamentoService.agendamentos
            .where((a) => !a.concluido)
            .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // TOPO
              Container(
                width: double.infinity,

                padding: const EdgeInsets.fromLTRB(
                  20,
                  22,
                  20,
                  30,
                ),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1E6FD9),
                      Color(0xFF3D8BFF),
                    ],
                  ),

                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),

                child: Column(
                  children: [

                    Row(
                      children: [

                        IconButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const HomeScreen(),
                              ),
                                  (route) => false,
                            );
                          },

                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),

                        const Spacer(),

                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),

                          decoration: BoxDecoration(
                            color:
                            Colors.white.withOpacity(0.16),

                            borderRadius:
                            BorderRadius.circular(20),
                          ),

                          child: const Row(
                            children: [
                              Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 16,
                              ),

                              SizedBox(width: 5),

                              Text(
                                "Prestador",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                  FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white,

                      child: Icon(
                        Icons.work,
                        size: 42,
                        color: Color(0xFF1E6FD9),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      AuthService.nome.isEmpty
                          ? "Prestador"
                          : AuthService.nome,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      AuthService.localizacao,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [

                        Expanded(
                          child: _resumoCard(
                            titulo: "Serviços",
                            valor:
                            totalServicos.toString(),
                            icon:
                            Icons.calendar_month,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _resumoCard(
                            titulo: "Pendentes",
                            valor: pendentes.toString(),
                            icon:
                            Icons.pending_actions,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _resumoCard(
                            titulo: "Concluídos",
                            valor:
                            concluidos.toString(),
                            icon:
                            Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // STATUS
              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(24),
                  ),

                  child: Row(
                    children: [

                      Container(
                        width: 58,
                        height: 58,

                        decoration: BoxDecoration(
                          color:
                          const Color(0xFFEAF2FF),

                          borderRadius:
                          BorderRadius.circular(18),
                        ),

                        child: const Icon(
                          Icons.trending_up,
                          color: Color(0xFF1E6FD9),
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(
                              "Seu perfil está ativo",
                              style: TextStyle(
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              "Clientes podem encontrar seus serviços normalmente.",
                              style: TextStyle(
                                color: Colors.grey,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // OPCOES
              _opcaoPainel(
                icon: Icons.assignment,
                titulo: "Solicitações recebidas",
                subtitulo:
                "Aceite ou recuse pedidos de clientes",

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const SolicitacoesPrestadorScreen(),
                    ),
                  );
                },
              ),

              _opcaoPainel(
                icon: Icons.chat,
                titulo: "Mensagens",
                subtitulo:
                "Converse com seus clientes",

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const ChatScreen(),
                    ),
                  );
                },
              ),

              _opcaoPainel(
                icon: Icons.handyman,
                titulo: "Meus serviços",
                subtitulo:
                "Gerencie os serviços que você oferece",

                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Área em desenvolvimento 👷",
                      ),
                    ),
                  );
                },
              ),

              _opcaoPainel(
                icon: Icons.edit,
                titulo:
                "Editar perfil profissional",

                subtitulo:
                "Atualize descrição, preço e categoria",

                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Editor de perfil em breve ✨",
                      ),
                    ),
                  );
                },
              ),

              _opcaoPainel(
                icon: Icons.bar_chart,
                titulo: "Estatísticas",
                subtitulo:
                "Veja seu desempenho no app",

                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Dashboard em breve 📊",
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // BOTAO SAIR
              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor:
                      Colors.white,

                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 15,
                      ),

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                            18),
                      ),
                    ),

                    onPressed: () {
                      AuthService.logout();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const HomeScreen(),
                        ),
                            (route) => false,
                      );
                    },

                    icon: const Icon(Icons.logout),

                    label:
                    const Text("Sair da conta"),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resumoCard({
    required String titulo,
    required String valor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),

          const SizedBox(height: 8),

          Text(
            valor,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            titulo,

            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _opcaoPainel({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: ListTile(
        onTap: onTap,

        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),

        leading: Container(
          width: 48,
          height: 48,

          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius:
            BorderRadius.circular(16),
          ),

          child: Icon(
            icon,
            color: const Color(0xFF1E6FD9),
          ),
        ),

        title: Text(
          titulo,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          subtitulo,

          style: const TextStyle(
            fontSize: 12,
            height: 1.4,
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}