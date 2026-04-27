import 'package:flutter/material.dart';
import '../services/favorito_service.dart';
import '../widgets/prestador_card.dart';
import 'perfil_prestador_screen.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  @override
  Widget build(BuildContext context) {
    final favoritos = FavoritoService.favoritos;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Favoritos"),
        backgroundColor: const Color(0xFF1E6FD9),
      ),
      body: favoritos.isEmpty
          ? const Center(child: Text("Nenhum favorito ainda"))
          : ListView.builder(
        itemCount: favoritos.length,
        itemBuilder: (context, index) {
          final p = favoritos[index];

          return PrestadorCard(
            nome: p["nome"],
            profissao: p["profissao"],
            distancia: "${p["distancia"]} de distância",
            rating: p["rating"],
            disponivel: p["disponivel"],
            favorito: true,
            onFavoritoTap: () {
              setState(() {
                FavoritoService.alternarFavorito(p);
              });
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PerfilPrestadorScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}