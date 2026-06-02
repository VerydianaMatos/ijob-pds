import 'dart:io';

import 'package:flutter/material.dart';

import '../models/prestador_model.dart';
import '../models/agendamento_model.dart';

import '../services/favorito_service.dart';
import '../services/agendamento_service.dart';

import 'chat_screen.dart';

class PerfilPrestadorScreen extends StatefulWidget {
  final Prestador prestador;

  const PerfilPrestadorScreen({
    super.key,
    required this.prestador,
  });

  @override
  State<PerfilPrestadorScreen> createState() =>
      _PerfilPrestadorScreenState();
}

class _PerfilPrestadorScreenState
    extends State<PerfilPrestadorScreen> {
  bool carregando = false;

  Future<void> contratarServico() async {
    setState(() {
      carregando = true;
    });

    final agendamento = Agendamento(
      nomePrestador: widget.prestador.nome,
      servico: widget.prestador.profissao,
      data: "Hoje • 14:00",
      concluido: false,
    );

    await AgendamentoService.adicionar(
      agendamento,
    );

    if (!mounted) return;

    setState(() {
      carregando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Serviço contratado com sucesso!",
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.prestador;

    final favorito =
    FavoritoService.isFavorito(
      p.nome,
    );

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor:
      Theme.of(context)
          .scaffoldBackgroundColor,

      body: CustomScrollView(
        slivers: [

          // APPBAR
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor:
            const Color(0xFF1E6FD9),

            flexibleSpace:
            FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [

                  Container(
                    decoration:
                    const BoxDecoration(
                      gradient:
                      LinearGradient(
                        begin:
                        Alignment.topCenter,
                        end:
                        Alignment.bottomCenter,
                        colors: [
                          Color(
                              0xFF1E6FD9),
                          Color(
                              0xFF3D8BFF),
                        ],
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(
                          22),

                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                        children: [

                          CircleAvatar(
                            radius: 56,
                            backgroundColor:
                            Colors.white,

                            backgroundImage:
                            p.fotoUrl
                                .isNotEmpty
                                ? FileImage(
                              File(
                                p.fotoUrl,
                              ),
                            )
                                : null,

                            child: p.fotoUrl
                                .isEmpty
                                ? Text(
                              _iniciais(
                                  p.nome),

                              style:
                              const TextStyle(
                                color:
                                Color(
                                    0xFF1E6FD9),

                                fontSize:
                                30,

                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            )
                                : null,
                          ),

                          const SizedBox(
                              height: 16),

                          Text(
                            p.nome,

                            style:
                            const TextStyle(
                              color:
                              Colors.white,

                              fontSize: 25,

                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),

                          const SizedBox(
                              height: 6),

                          Text(
                            p.profissao,

                            style:
                            const TextStyle(
                              color:
                              Colors.white70,

                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(
                              height: 14),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment:
                            WrapAlignment
                                .center,

                            children:
                            p.categorias
                                .map(
                                  (cat) =>
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal:
                                      12,
                                      vertical:
                                      7,
                                    ),

                                    decoration:
                                    BoxDecoration(
                                      color: Colors
                                          .white
                                          .withOpacity(
                                          0.18),

                                      borderRadius:
                                      BorderRadius.circular(
                                          20),
                                    ),

                                    child:
                                    Text(
                                      cat,

                                      style:
                                      const TextStyle(
                                        color:
                                        Colors.white,

                                        fontWeight:
                                        FontWeight.bold,

                                        fontSize:
                                        12,
                                      ),
                                    ),
                                  ),
                            )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            actions: [

              IconButton(
                onPressed: () async {
                  await FavoritoService
                      .alternarFavorito({
                    "nome": p.nome,
                    "profissao":
                    p.profissao,
                    "categoria":
                    p.categoria,
                    "categorias":
                    p.categorias,
                    "distancia":
                    p.distancia,
                    "rating":
                    p.rating,
                    "disponivel":
                    p.disponivel,
                    "descricao":
                    p.descricao,
                    "preco":
                    p.preco,
                    "resposta":
                    p.resposta,
                    "servicos":
                    p.servicos,
                    "fotoUrl":
                    p.fotoUrl,
                  });

                  if (!mounted) return;

                  setState(() {});
                },

                icon: Icon(
                  favorito
                      ? Icons.favorite
                      : Icons
                      .favorite_border,

                  color: favorito
                      ? Colors.red
                      : Colors.white,
                ),
              ),
            ],
          ),

          // CONTEUDO
          SliverToBoxAdapter(
            child: Padding(
              padding:
              const EdgeInsets.all(20),

              child: Column(
                children: [

                  // CARDS INFO
                  Row(
                    children: [

                      Expanded(
                        child:
                        _infoCard(
                          icon:
                          Icons.star,
                          titulo:
                          p.rating
                              .toString(),
                          subtitulo:
                          "Avaliação",
                        ),
                      ),

                      const SizedBox(
                          width: 10),

                      Expanded(
                        child:
                        _infoCard(
                          icon:
                          Icons.flash_on,
                          titulo:
                          p.resposta,
                          subtitulo:
                          "Resposta",
                        ),
                      ),

                      const SizedBox(
                          width: 10),

                      Expanded(
                        child:
                        _infoCard(
                          icon:
                          Icons.work,
                          titulo:
                          p.servicos,
                          subtitulo:
                          "Serviços",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 20),

                  // SOBRE
                  _card(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        const Text(
                          "Sobre o profissional",

                          style:
                          TextStyle(
                            fontWeight:
                            FontWeight
                                .bold,

                            fontSize:
                            17,
                          ),
                        ),

                        const SizedBox(
                            height: 12),

                        Text(
                          p.descricao,

                          style:
                          const TextStyle(
                            height: 1.5,
                            color:
                            Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 18),

                  // PRECO
                  _card(
                    child: Row(
                      children: [

                        Container(
                          width: 54,
                          height: 54,

                          decoration:
                          BoxDecoration(
                            color:
                            const Color(
                                0xFFEAF2FF),

                            borderRadius:
                            BorderRadius.circular(
                                18),
                          ),

                          child:
                          const Icon(
                            Icons
                                .attach_money,

                            color: Color(
                                0xFF1E6FD9),
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

                              const Text(
                                "Preço médio",

                                style:
                                TextStyle(
                                  color:
                                  Colors.grey,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                  4),

                              Text(
                                p.preco,

                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight.bold,

                                  fontSize:
                                  18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 20),

                  // STATUS
                  Container(
                    width:
                    double.infinity,

                    padding:
                    const EdgeInsets.all(
                        14),

                    decoration:
                    BoxDecoration(
                      color:
                      p.disponivel
                          ? Colors.green
                          .withOpacity(
                          0.12)
                          : Colors.orange
                          .withOpacity(
                          0.12),

                      borderRadius:
                      BorderRadius
                          .circular(
                          18),
                    ),

                    child: Row(
                      children: [

                        Icon(
                          p.disponivel
                              ? Icons
                              .check_circle
                              : Icons
                              .schedule,

                          color:
                          p.disponivel
                              ? Colors
                              .green
                              : Colors
                              .orange,
                        ),

                        const SizedBox(
                            width: 10),

                        Expanded(
                          child: Text(
                            p.disponivel
                                ? "Disponível para novos atendimentos"
                                : "Atualmente ocupado",

                            style:
                            TextStyle(
                              color: p
                                  .disponivel
                                  ? Colors
                                  .green
                                  : Colors
                                  .orange,

                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 24),

                  // BOTOES
                  Row(
                    children: [

                      Expanded(
                        child:
                        OutlinedButton
                            .icon(
                          onPressed:
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                const ChatScreen(),
                              ),
                            );
                          },

                          icon:
                          const Icon(
                            Icons.chat,
                          ),

                          label:
                          const Text(
                            "Chat",
                          ),
                        ),
                      ),

                      const SizedBox(
                          width: 12),

                      Expanded(
                        child:
                        ElevatedButton
                            .icon(
                          onPressed:
                          carregando
                              ? null
                              : contratarServico,

                          icon: carregando
                              ? const SizedBox(
                            width:
                            16,
                            height:
                            16,

                            child:
                            CircularProgressIndicator(
                              color:
                              Colors.white,

                              strokeWidth:
                              2,
                            ),
                          )
                              : const Icon(
                            Icons
                                .calendar_month,
                          ),

                          label: Text(
                            carregando
                                ? "Aguarde..."
                                : "Contratar",
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String titulo,
    required String subtitulo,
  }) {
    return _card(
      padding:
      const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 10,
      ),

      child: Column(
        children: [

          Icon(
            icon,
            color:
            const Color(0xFF1E6FD9),
          ),

          const SizedBox(height: 8),

          Text(
            titulo,

            style: const TextStyle(
              fontWeight:
              FontWeight.bold,
              fontSize: 17,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            subtitulo,

            textAlign:
            TextAlign.center,

            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding =
    const EdgeInsets.all(18),
  }) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Container(
      width: double.infinity,
      padding: padding,

      decoration: BoxDecoration(
        color:
        Theme.of(context).cardColor,

        borderRadius:
        BorderRadius.circular(24),

        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.04),

              blurRadius: 14,

              offset:
              const Offset(0, 6),
            ),
        ],
      ),

      child: child,
    );
  }

  String _iniciais(String nome) {
    final partes =
    nome.trim().split(" ");

    if (partes.length == 1) {
      return partes[0][0]
          .toUpperCase();
    }

    return "${partes[0][0]}${partes[1][0]}"
        .toUpperCase();
  }
}