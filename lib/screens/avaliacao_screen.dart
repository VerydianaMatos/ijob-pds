import 'package:flutter/material.dart';

class AvaliacaoScreen extends StatefulWidget {
  const AvaliacaoScreen({super.key});

  @override
  State<AvaliacaoScreen> createState() => _AvaliacaoScreenState();
}

class _AvaliacaoScreenState extends State<AvaliacaoScreen> {
  int estrelas = 0;
  final TextEditingController comentarioController = TextEditingController();

  final List<String> tags = [
    "Pontual",
    "Educado",
    "Preço justo",
    "Rápido",
    "Organizado",
  ];

  final List<String> selecionadas = [];

  void enviarAvaliacao() {
    if (estrelas == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione uma nota em estrelas.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Avaliação enviada com sucesso!")),
    );

    Navigator.pop(context);
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: Color(0xFFE3F0FF),
                    child: Text(
                      "CM",
                      style: TextStyle(
                        color: Color(0xFF1E6FD9),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Carlos Martins",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Eletricista",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Como foi o serviço?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final ativo = index < estrelas;

                      return IconButton(
                        onPressed: () {
                          setState(() {
                            estrelas = index + 1;
                          });
                        },
                        icon: Icon(
                          Icons.star,
                          size: 34,
                          color: ativo ? Colors.orange : Colors.grey[300],
                        ),
                      );
                    }),
                  ),

                  Text(
                    estrelas == 0
                        ? "Toque nas estrelas para avaliar"
                        : "$estrelas de 5 estrelas",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Destaques do atendimento",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                final selecionada = selecionadas.contains(tag);

                return FilterChip(
                  label: Text(tag),
                  selected: selecionada,
                  selectedColor: const Color(0xFFE3F0FF),
                  checkmarkColor: const Color(0xFF1E6FD9),
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

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Comentário",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: comentarioController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Conte como foi sua experiência...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E6FD9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: enviarAvaliacao,
                icon: const Icon(Icons.send),
                label: const Text("Enviar avaliação"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}