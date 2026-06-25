import 'package:flutter/material.dart';

class PrestadorCard extends StatelessWidget {
  final String nome;
  final String profissao;
  final String distancia;
  final double rating;
  final bool disponivel;
  final bool favorito;

  final VoidCallback onTap;
  final VoidCallback onFavoritoTap;

  const PrestadorCard({
    super.key,
    required this.nome,
    required this.profissao,
    required this.distancia,
    required this.rating,
    required this.disponivel,
    required this.favorito,
    required this.onTap,
    required this.onFavoritoTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withOpacity(0.05),

              blurRadius: 14,

              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Row(
          children: [

            // FOTO
            Stack(
              children: [

                CircleAvatar(
                  radius: 32,
                  backgroundColor:
                  const Color(0xFFE3F0FF),

                  child: Text(
                    _iniciais(nome),

                    style: const TextStyle(
                      color: Color(0xFF1E6FD9),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                Positioned(
                  right: 2,
                  bottom: 2,

                  child: Container(
                    width: 14,
                    height: 14,

                    decoration: BoxDecoration(
                      color: disponivel
                          ? Colors.green
                          : Colors.orange,

                      shape: BoxShape.circle,

                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // INFOS
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    nome,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    profissao,

                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [

                      const Icon(
                        Icons.location_on,
                        size: 15,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          distancia,

                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [

                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 17,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        rating.toString(),

                        style: const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),

                        decoration: BoxDecoration(
                          color: disponivel
                              ? Colors.green
                              .withOpacity(0.12)
                              : Colors.orange
                              .withOpacity(0.12),

                          borderRadius:
                          BorderRadius.circular(
                              20),
                        ),

                        child: Text(
                          disponivel
                              ? "Disponível"
                              : "Ocupado",

                          style: TextStyle(
                            color: disponivel
                                ? Colors.green
                                : Colors.orange,

                            fontWeight:
                            FontWeight.bold,

                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // FAVORITO
            IconButton(
              onPressed: onFavoritoTap,

              icon: Icon(
                favorito
                    ? Icons.favorite
                    : Icons.favorite_border,

                color: favorito
                    ? Colors.red
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _iniciais(String nome) {

    final partes = nome.split(" ");

    if (partes.length == 1) {
      return partes[0][0].toUpperCase();
    }

    return "${partes[0][0]}${partes[1][0]}"
        .toUpperCase();
  }
}