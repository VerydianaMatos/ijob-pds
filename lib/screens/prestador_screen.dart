import 'package:flutter/material.dart';
import '../widgets/prestador_card.dart';
import '../services/favorito_service.dart';
import 'perfil_prestador_screen.dart';
import 'login_screen.dart';
import 'cadastro_screen.dart';
import 'cadastro_prestador_screen.dart';

class PrestadorScreen extends StatefulWidget {
  const PrestadorScreen({super.key});

  @override
  State<PrestadorScreen> createState() => _PrestadorScreenState();
}

class _PrestadorScreenState extends State<PrestadorScreen> {
  String categoriaSelecionada = "Todos";

  final List<Map<String, dynamic>> prestadores = [
    {
      "nome": "Carlos Martins",
      "profissao": "Eletricista",
      "categoria": "Elétrica",
      "distancia": "1.2 km",
      "rating": 4.9,
      "disponivel": true,
    },
    {
      "nome": "Ana Silva",
      "profissao": "Faxineira",
      "categoria": "Limpeza",
      "distancia": "0.8 km",
      "rating": 4.7,
      "disponivel": true,
    },
    {
      "nome": "Roberto Prado",
      "profissao": "Encanador",
      "categoria": "Hidráulica",
      "distancia": "2.1 km",
      "rating": 4.5,
      "disponivel": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtrados = categoriaSelecionada == "Todos"
        ? prestadores
        : prestadores
        .where((p) => p["categoria"] == categoriaSelecionada)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 20),
          _busca(),
          const SizedBox(height: 20),
          _categorias(),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Prestadores perto de você",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          ...filtrados.map((p) {
            return PrestadorCard(
              nome: p["nome"],
              profissao: p["profissao"],
              distancia: "${p["distancia"]} de distância",
              rating: p["rating"],
              disponivel: p["disponivel"],
              favorito: FavoritoService.isFavorito(p["nome"]),
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
          }),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E6FD9),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white),
              SizedBox(width: 5),
              Text(
                "Capão da Canoa - RS",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "O que você precisa?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _busca() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Buscar serviço",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _categorias() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _categoria("Todos"),
          _categoria("Elétrica"),
          _categoria("Hidráulica"),
          _categoria("Limpeza"),
        ],
      ),
    );
  }

  Widget _categoria(String nome) {
    final selecionado = categoriaSelecionada == nome;

    return GestureDetector(
      onTap: () {
        setState(() {
          categoriaSelecionada = nome;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selecionado ? const Color(0xFF1E6FD9) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          nome,
          style: TextStyle(
            color: selecionado ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}