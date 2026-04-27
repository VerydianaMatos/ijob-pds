import 'package:flutter/material.dart';

class CategoriaList extends StatelessWidget {
  const CategoriaList({super.key});

  @override
  Widget build(BuildContext context) {
    final categorias = [
      "Limpeza",
      "Elétrica",
      "Pintura",
      "Frete",
      "Encanador"
    ];

    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(categorias[index]),
          );
        },
      ),
    );
  }
}