import 'package:flutter/material.dart';

class PrestadorCard extends StatelessWidget {
  final String nome;
  final String profissao;
  final String distancia;
  final double rating;
  final bool disponivel;
  final bool favorito;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritoTap;

  const PrestadorCard({
    super.key,
    required this.nome,
    required this.profissao,
    required this.distancia,
    required this.rating,
    required this.disponivel,
    this.favorito = false,
    this.onTap,
    this.onFavoritoTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE3F0FF),
              child: Text(
                nome.substring(0, 2).toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF1E6FD9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    profissao,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        distancia,
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              children: [
                IconButton(
                  onPressed: onFavoritoTap,
                  icon: Icon(
                    favorito ? Icons.favorite : Icons.favorite_border,
                    color: favorito ? Colors.red : Colors.grey,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: disponivel
                        ? const Color(0xFFE3F0FF)
                        : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    disponivel ? "Disponível" : "Ocupado",
                    style: TextStyle(
                      color: disponivel
                          ? const Color(0xFF1E6FD9)
                          : Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}