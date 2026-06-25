import 'package:flutter/material.dart';

import '../models/prestador_model.dart';
import '../services/favorito_service.dart';
import '../services/prestador_service.dart';
import '../widgets/prestador_card.dart';
import 'perfil_prestador_screen.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  Prestador? _buscarPrestador(String nome) {
    try {
      return PrestadorService.prestadores.firstWhere((p) => p.nome == nome);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritos = FavoritoService.favoritos;

    return Scaffold(
      appBar: AppBar(title: const Text("Favoritos")),
      body: favoritos.isEmpty
          ? _estadoVazio()
          : ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 20),
              itemCount: favoritos.length,
              itemBuilder: (context, index) {
                final p = favoritos[index];

                return PrestadorCard(
                  nome: p["nome"],
                  profissao: p["profissao"],
                  distancia: p["distancia"],
                  rating: p["rating"],
                  disponivel: p["disponivel"],
                  favorito: true,
                  onFavoritoTap: () {
                    setState(() {
                      FavoritoService.alternarFavorito(p);
                    });
                  },
                  onTap: () {
                    final prestador = _buscarPrestador(p["nome"]);
                    if (prestador == null) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PerfilPrestadorScreen(
                          prestador: prestador,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _estadoVazio() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.35),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: colorScheme.primary.withOpacity(0.12),
                child: Icon(
                  Icons.favorite_border,
                  size: 38,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Nenhum favorito ainda",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                "Toque no coração de um profissional para encontrá-lo aqui depois.",
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



