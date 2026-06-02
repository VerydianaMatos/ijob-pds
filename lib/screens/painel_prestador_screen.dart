import 'package:flutter/material.dart';

import '../services/prestador_service.dart';
import '../services/agendamento_service.dart';

class PainelPrestadorScreen extends StatefulWidget {
  const PainelPrestadorScreen({super.key});

  @override
  State<PainelPrestadorScreen> createState() =>
      _PainelPrestadorScreenState();
}

class _PainelPrestadorScreenState
    extends State<PainelPrestadorScreen> {
  bool disponivel = true;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final totalPrestadores =
        PrestadorService.prestadores.length;

    final totalAgendamentos =
        AgendamentoService.agendamentos.length;

    final concluidos =
        AgendamentoService.agendamentos
            .where((a) => a.concluido)
            .length;

    return Scaffold(
      backgroundColor:
      Theme.of(context)
          .scaffoldBackgroundColor,

      appBar: AppBar(
        title:
        const Text("Painel do prestador"),
      ),

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          children: [

            // TOPO
            Container(
              width: double.infinity,

              padding:
              const EdgeInsets.all(24),

              decoration:
              const BoxDecoration(
                gradient:
                LinearGradient(
                  colors: [
                    Color(0xFF1E6FD9),
                    Color(0xFF3D8BFF),
                  ],
                ),

                borderRadius:
                BorderRadius.all(
                  Radius.circular(28),
                ),
              ),

              child: Column(
                children: [

                  const CircleAvatar(
                    radius: 42,
                    backgroundColor:
                    Colors.white,

                    child: Icon(
                      Icons.work,
                      size: 40,
                      color: Color(
                          0xFF1E6FD9),
                    ),
                  ),

                  const SizedBox(
                      height: 14),

                  const Text(
                    "Painel profissional",

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),

                  const SizedBox(
                      height: 4),

                  const Text(
                    "Gerencie seus serviços e atendimentos",

                    textAlign:
                    TextAlign.center,

                    style: TextStyle(
                      color:
                      Colors.white70,
                    ),
                  ),

                  const SizedBox(
                      height: 18),

                  Row(
                    children: [

                      Expanded(
                        child:
                        _resumoCard(
                          icon:
                          Icons.people,
                          valor:
                          totalPrestadores
                              .toString(),
                          titulo:
                          "Clientes",
                        ),
                      ),

                      const SizedBox(
                          width: 10),

                      Expanded(
                        child:
                        _resumoCard(
                          icon: Icons
                              .calendar_month,
                          valor:
                          totalAgendamentos
                              .toString(),
                          titulo:
                          "Serviços",
                        ),
                      ),

                      const SizedBox(
                          width: 10),

                      Expanded(
                        child:
                        _resumoCard(
                          icon:
                          Icons
                              .check_circle,
                          valor:
                          concluidos
                              .toString(),
                          titulo:
                          "Finalizados",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
                height: 24),

            // STATUS
            Container(
              width: double.infinity,

              padding:
              const EdgeInsets.all(
                  18),

              decoration:
              BoxDecoration(
                color:
                Theme.of(context)
                    .cardColor,

                borderRadius:
                BorderRadius
                    .circular(24),

                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors
                          .black
                          .withOpacity(
                          0.04),

                      blurRadius: 14,

                      offset:
                      const Offset(
                          0, 6),
                    ),
                ],
              ),

              child: Column(
                children: [

                  Row(
                    children: [

                      Container(
                        width: 52,
                        height: 52,

                        decoration:
                        BoxDecoration(
                          color: disponivel
                              ? Colors.green
                              .withOpacity(
                              0.12)
                              : Colors
                              .orange
                              .withOpacity(
                              0.12),

                          borderRadius:
                          BorderRadius.circular(
                              18),
                        ),

                        child: Icon(
                          disponivel
                              ? Icons
                              .check_circle
                              : Icons
                              .schedule,

                          color: disponivel
                              ? Colors
                              .green
                              : Colors
                              .orange,
                        ),
                      ),

                      const SizedBox(
                          width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Text(
                              disponivel
                                  ? "Disponível"
                                  : "Indisponível",

                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight
                                    .bold,

                                fontSize:
                                17,
                              ),
                            ),

                            const SizedBox(
                                height: 4),

                            Text(
                              disponivel
                                  ? "Você pode receber novos serviços"
                                  : "Você não está recebendo serviços",

                              style:
                              const TextStyle(
                                color:
                                Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Switch(
                        value:
                        disponivel,

                        activeColor:
                        const Color(
                            0xFF1E6FD9),

                        onChanged:
                            (value) {
                          setState(() {
                            disponivel =
                                value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
                height: 22),

            // OPCOES
            _opcao(
              icon:
              Icons.calendar_month,
              titulo:
              "Meus atendimentos",
              subtitulo:
              "Veja serviços agendados",
            ),

            _opcao(
              icon:
              Icons.attach_money,
              titulo:
              "Ganhos",
              subtitulo:
              "Acompanhe seus recebimentos",
            ),

            _opcao(
              icon: Icons.star,
              titulo:
              "Avaliações",
              subtitulo:
              "Veja feedbacks dos clientes",
            ),

            _opcao(
              icon:
              Icons.settings,
              titulo:
              "Configurações",
              subtitulo:
              "Personalize sua conta",
            ),

            const SizedBox(
                height: 28),

            // BOTAO
            SizedBox(
              width: double.infinity,

              child:
              ElevatedButton.icon(
                onPressed: () {},

                icon:
                const Icon(Icons.edit),

                label: const Text(
                  "Editar perfil",
                ),
              ),
            ),

            const SizedBox(
                height: 30),
          ],
        ),
      ),
    );
  }

  Widget _resumoCard({
    required IconData icon,
    required String valor,
    required String titulo,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 10,
      ),

      decoration: BoxDecoration(
        color:
        Colors.white.withOpacity(
            0.16),

        borderRadius:
        BorderRadius.circular(18),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            color: Colors.white,
          ),

          const SizedBox(height: 8),

          Text(
            valor,

            style: const TextStyle(
              color: Colors.white,
              fontWeight:
              FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            titulo,

            textAlign:
            TextAlign.center,

            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _opcao({
    required IconData icon,
    required String titulo,
    required String subtitulo,
  }) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Container(
      margin:
      const EdgeInsets.only(
          bottom: 12),

      decoration: BoxDecoration(
        color:
        Theme.of(context)
            .cardColor,

        borderRadius:
        BorderRadius.circular(22),

        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.04),

              blurRadius: 12,

              offset:
              const Offset(0, 5),
            ),
        ],
      ),

      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),

        leading: Container(
          width: 44,
          height: 44,

          decoration: BoxDecoration(
            color:
            const Color(0xFFEAF2FF),

            borderRadius:
            BorderRadius.circular(
                14),
          ),

          child: Icon(
            icon,
            color:
            const Color(0xFF1E6FD9),
          ),
        ),

        title: Text(
          titulo,

          style: const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),

        subtitle: Text(
          subtitulo,

          style: const TextStyle(
            fontSize: 12,
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