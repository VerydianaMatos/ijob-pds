import 'package:flutter/material.dart';

class AvaliacaoScreen extends StatefulWidget {
  const AvaliacaoScreen({super.key});

  @override
  State<AvaliacaoScreen> createState() => _AvaliacaoScreenState();
}

class _AvaliacaoScreenState extends State<AvaliacaoScreen> {
  int estrelas = 0;

  final TextEditingController comentarioController =
  TextEditingController();

  final List<String> tags = [
    "Pontual",
    "Educado",
    "Preço justo",
    "Rápido",
    "Organizado",
    "Atencioso",
    "Profissional",
  ];

  final List<String> selecionadas = [];

  bool enviando = false;

  void enviarAvaliacao() async {
    if (estrelas == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecione uma nota em estrelas."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      enviando = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      enviando = false;
    });

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,

                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.check,
                  size: 42,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Avaliação enviada!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Obrigado pelo seu feedback ✨",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Fechar"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String get textoNota {
    switch (estrelas) {
      case 1:
        return "Muito ruim";
      case 2:
        return "Ruim";
      case 3:
        return "Bom";
      case 4:
        return "Muito bom";
      case 5:
        return "Excelente";
      default:
        return "Toque nas estrelas para avaliar";
    }
  }

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Avaliar serviço"),
        backgroundColor: const Color(0xFF1E6FD9),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // CARD PROFISSIONAL
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E6FD9),
                    Color(0xFF3D8BFF),
                  ],
                ),

                borderRadius: BorderRadius.circular(28),
              ),

              child: Column(
                children: [

                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white,

                    child: Text(
                      "CM",
                      style: TextStyle(
                        color: Color(0xFF1E6FD9),
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    "Carlos Martins",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Eletricista",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Como foi sua experiência?",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: List.generate(5, (index) {
                      final ativo = index < estrelas;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            estrelas = index + 1;
                          });
                        },

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),

                          margin: const EdgeInsets.symmetric(horizontal: 4),

                          child: Icon(
                            ativo
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,

                            size: 42,

                            color: ativo
                                ? Colors.orangeAccent
                                : Colors.white54,
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    textoNota,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TAGS
            Align(
              alignment: Alignment.centerLeft,

              child: const Text(
                "Destaques do atendimento",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,

              children: tags.map((tag) {
                final selecionada =
                selecionadas.contains(tag);

                return FilterChip(
                  label: Text(tag),

                  selected: selecionada,

                  backgroundColor: Colors.white,

                  selectedColor:
                  const Color(0xFFEAF2FF),

                  checkmarkColor:
                  const Color(0xFF1E6FD9),

                  labelStyle: TextStyle(
                    color: selecionada
                        ? const Color(0xFF1E6FD9)
                        : Colors.black87,

                    fontWeight: FontWeight.w600,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(24),
                  ),

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

            const SizedBox(height: 24),

            // COMENTARIO
            Align(
              alignment: Alignment.centerLeft,

              child: const Text(
                "Comentário",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),

              child: TextField(
                controller: comentarioController,

                maxLines: 5,

                decoration: const InputDecoration(
                  hintText:
                  "Conte como foi sua experiência com o profissional...",

                  border: InputBorder.none,

                  contentPadding: EdgeInsets.all(18),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // BOTAO
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed:
                enviando ? null : enviarAvaliacao,

                icon: enviando
                    ? const SizedBox(
                  width: 18,
                  height: 18,

                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.send),

                label: Text(
                  enviando
                      ? "Enviando..."
                      : "Enviar avaliação",
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}