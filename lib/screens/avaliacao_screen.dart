import 'package:flutter/material.dart';

class AvaliacaoScreen extends StatefulWidget {
  const AvaliacaoScreen({super.key});

  @override
  State<AvaliacaoScreen> createState() => _AvaliacaoScreenState();
}

class _AvaliacaoScreenState extends State<AvaliacaoScreen> {
  int estrelas = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Avaliar serviço"),
        backgroundColor: const Color(0xFF1E6FD9),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFE3F0FF),
              child: Text(
                "CM",
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF1E6FD9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Carlos Martins",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text(
              "Como foi o serviço?",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 10),

            // ⭐ ESTRELAS CLICÁVEIS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      estrelas = index + 1;
                    });
                  },
                  icon: Icon(
                    Icons.star,
                    size: 30,
                    color: index < estrelas
                        ? Colors.orange
                        : Colors.grey[300],
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // 💬 COMENTÁRIO
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Comentário",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TAGS
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text("Pontual")),
                Chip(label: Text("Educado")),
                Chip(label: Text("Preço justo")),
                Chip(label: Text("Rápido")),
              ],
            ),

            const Spacer(),

            // BOTÃO
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E6FD9),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Avaliação enviada!")),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Enviar avaliação"),
              ),
            )
          ],
        ),
      ),
    );
  }
}