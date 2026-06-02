import 'package:flutter/material.dart';

import '../services/favorito_service.dart';
import '../services/prestador_service.dart';
import '../widgets/prestador_card.dart';
import '../models/prestador_model.dart';

import 'perfil_prestador_screen.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarFavoritos();
  }

  Future<void> carregarFavoritos() async {
    setState(() {
      carregando = true;
    });

    await FavoritoService.carregarFavoritos();

    if (!mounted) return;

    setState(() {
      carregando = false;
    });
  }

  Prestador? _buscarPrestador(String nome) {
    try {
      return PrestadorService.prestadores.firstWhere(
            (p) => p.nome == nome,
      );
    } catch (e) {
      return null;
    }
  }

  Prestador _prestadorDoFavorito(Map<String, dynamic> p) {
    return Prestador(
      nome: p["nome"] ?? "",
      profissao: p["profissao"] ?? "",
      categoria: p["categoria"] ?? "Serviço geral",
      distancia: p["distancia"] ?? "0.5 km",
      rating: (p["rating"] ?? 0).toDouble(),
      disponivel: p["disponivel"] ?? true,
      descricao: p["descricao"] ?? "Profissional salvo nos favoritos.",
      preco: p["preco"] ?? "A combinar",
      resposta: p["resposta"] ?? "~10 min",
      servicos: p["servicos"] ?? "Novo",
      fotoUrl: p["fotoUrl"] ?? "",
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritos = FavoritoService.favoritos;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Favoritos"),
        backgroundColor: const Color(0xFF1E6FD9),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: carregarFavoritos,
        child: carregando
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1E6FD9),
          ),
        )
            : favoritos.isEmpty
            ? ListView(
          children: const [
            SizedBox(height: 160),
            Icon(
              Icons.favorite_border,
              size: 70,
              color: Colors.grey,
            ),
            SizedBox(height: 14),
            Center(
              child: Text(
                "Nenhum favorito ainda",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            SizedBox(height: 6),
            Center(
              child: Text(
                "Salve profissionais para acessar depois.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 20),
          itemCount: favoritos.length,
          itemBuilder: (context, index) {
            final p = favoritos[index];

            return PrestadorCard(
              nome: p["nome"] ?? "",
              profissao: p["profissao"] ?? "",
              distancia: "${p["distancia"] ?? "0.5 km"} de distância",
              rating: (p["rating"] ?? 0).toDouble(),
              disponivel: p["disponivel"] ?? true,
              favorito: true,
              fotoUrl: p["fotoUrl"] ?? "",
              onFavoritoTap: () async {
                await FavoritoService.alternarFavorito(p);
                await carregarFavoritos();
              },
              onTap: () {
                final prestador =
                    _buscarPrestador(p["nome"] ?? "") ??
                        _prestadorDoFavorito(p);

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
      ),
    );
  }
}