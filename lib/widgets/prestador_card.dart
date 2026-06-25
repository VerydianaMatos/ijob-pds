import 'dart:io';

import 'package:flutter/material.dart';

class PrestadorCard extends StatelessWidget {
  final String nome;
  final String profissao;
  final String distancia;
  final double rating;
  final bool disponivel;
  final bool favorito;
  final bool atendeRegiao;
  final double? raioAtendimentoKm;
  final String fotoPath;
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
    this.atendeRegiao = true,
    this.raioAtendimentoKm,
    this.fotoPath = "",
    required this.onTap,
    required this.onFavoritoTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = atendeRegiao
        ? (disponivel ? Colors.green : Colors.orange)
        : Colors.red;
    final statusTexto = atendeRegiao
        ? (disponivel ? "Disponível" : "Ocupado")
        : "Não atende sua região";
    final raioTexto = raioAtendimentoKm == null
        ? null
        : "Atende até ${raioAtendimentoKm!.round()} km";

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.18 : 0.045),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: colorScheme.primary.withOpacity(0.12),
                  backgroundImage: _fotoProvider(),
                  child: _fotoProvider() == null
                      ? Text(
                          _iniciais(nome),
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profissao,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Icon(
                        atendeRegiao ? Icons.location_on : Icons.location_off,
                        size: 15,
                        color: atendeRegiao
                            ? colorScheme.onSurfaceVariant
                            : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          distancia,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: atendeRegiao
                                ? colorScheme.onSurfaceVariant
                                : Colors.red,
                            fontSize: 12,
                            fontWeight: atendeRegiao
                                ? FontWeight.normal
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!atendeRegiao || raioTexto != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      atendeRegiao
                          ? raioTexto!
                          : "Prestador não atende na sua região",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: atendeRegiao
                            ? colorScheme.onSurfaceVariant
                            : Colors.red,
                        fontSize: 12,
                        fontWeight:
                            atendeRegiao ? FontWeight.w500 : FontWeight.w800,
                      ),
                    ),
                  ],
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 17),
                      const SizedBox(width: 4),
                      Text(
                        rating <= 0 ? "Novo" : rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusTexto,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onFavoritoTap,
              tooltip: favorito ? "Remover favorito" : "Favoritar",
              style: IconButton.styleFrom(
                backgroundColor: favorito
                    ? Colors.red.withOpacity(0.10)
                    : colorScheme.surfaceContainerHighest.withOpacity(0.65),
              ),
              icon: Icon(
                favorito ? Icons.favorite : Icons.favorite_border,
                color: favorito ? Colors.red : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(" ");

    if (partes.isEmpty || partes.first.isEmpty) return "P";
    if (partes.length == 1) return partes[0][0].toUpperCase();

    return "${partes[0][0]}${partes[1][0]}".toUpperCase();
  }

  ImageProvider? _fotoProvider() {
    if (fotoPath.isEmpty) return null;

    if (fotoPath.startsWith("http")) {
      return NetworkImage(fotoPath);
    }

    final arquivo = File(fotoPath);
    if (!arquivo.existsSync()) return null;

    return FileImage(arquivo);
  }
}



