import 'package:flutter/material.dart';

class ServicoList extends StatelessWidget {
  const ServicoList({super.key});

  @override
  Widget build(BuildContext context) {
    final servicos = [
      {"nome": "Eletricista João", "categoria": "Elétrica"},
      {"nome": "Maria Limpeza", "categoria": "Limpeza"},
      {"nome": "Carlos Pintor", "categoria": "Pintura"},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: servicos.length,
      itemBuilder: (context, index) {
        final item = servicos[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const CircleAvatar(radius: 25, child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item["nome"]!,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(item["categoria"]!),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Contratar"),
              )
            ],
          ),
        );
      },
    );
  }
}