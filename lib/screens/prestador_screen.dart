import 'package:flutter/material.dart';

import '../widgets/prestador_card.dart';
import '../services/prestador_service.dart';
import '../services/favorito_service.dart';
import '../models/prestador_model.dart';

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
  bool localizacaoAtiva = false;

  final TextEditingController buscaController = TextEditingController();

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  void carregarLocalizacao() {
    setState(() {
      localizacaoAtiva = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Localização ativada!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  String get textoLocalizacao {
    return localizacaoAtiva ? "Localização atual" : "Capão da Canoa - RS";
  }

  List<Prestador> get prestadoresFiltrados {
    final textoBusca = buscaController.text.trim().toLowerCase();

    return PrestadorService.prestadores.where((p) {
      final combinaCategoria =
          categoriaSelecionada == "Todos" || p.categoria == categoriaSelecionada;

      final combinaBusca = textoBusca.isEmpty ||
          p.nome.toLowerCase().contains(textoBusca) ||
          p.profissao.toLowerCase().contains(textoBusca) ||
          p.categoria.toLowerCase().contains(textoBusca);

      return combinaCategoria && combinaBusca;
    }).toList();
  }

  void limparBusca() {
    setState(() {
      buscaController.clear();
      categoriaSelecionada = "Todos";
    });
  }

  @override
  Widget build(BuildContext context) {
    final prestadores = prestadoresFiltrados;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOPO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E6FD9),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            textoLocalizacao,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        IconButton(
                          onPressed: carregarLocalizacao,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "Encontre o profissional ideal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Serviços rápidos e perto de você",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              if (localizacaoAtiva)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F0FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF1E6FD9),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Profissionais perto de você",
                            style: TextStyle(
                              color: Color(0xFF1E6FD9),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Localização ativa",
                            style: TextStyle(
                              color: Color(0xFF1E6FD9),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (localizacaoAtiva) const SizedBox(height: 18),

              // BUSCA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: buscaController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Buscar serviço ou profissional",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: buscaController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: limparBusca,
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // CATEGORIAS
              SizedBox(
                height: 82,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _categoria("Todos"),
                    _categoria("Elétrica"),
                    _categoria("Limpeza"),
                    _categoria("Hidráulica"),
                    _categoria("Pintura"),
                    _categoria("Frete"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Prestadores perto de você",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (buscaController.text.isNotEmpty ||
                        categoriaSelecionada != "Todos")
                      TextButton(
                        onPressed: limparBusca,
                        child: const Text("Limpar"),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              if (prestadores.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 45,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Nenhum prestador encontrado",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Tente buscar por outro serviço ou categoria.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),

              ...prestadores.map(
                    (Prestador p) => PrestadorCard(
                  nome: p.nome,
                  profissao: p.profissao,
                  distancia: "${p.distancia} de distância",
                  rating: p.rating,
                  disponivel: p.disponivel,
                  favorito: FavoritoService.isFavorito(p.nome),
                  onFavoritoTap: () {
                    setState(() {
                      FavoritoService.alternarFavorito({
                        "nome": p.nome,
                        "profissao": p.profissao,
                        "distancia": p.distancia,
                        "rating": p.rating,
                        "disponivel": p.disponivel,
                      });
                    });
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PerfilPrestadorScreen(
                          prestador: p,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              _cardConta(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoria(String nome) {
    final selecionada = categoriaSelecionada == nome;

    return GestureDetector(
      onTap: () {
        setState(() {
          categoriaSelecionada = nome;
        });
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: selecionada ? const Color(0xFF1E6FD9) : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          nome,
          style: TextStyle(
            color: selecionada ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _cardConta() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Text(
              "Entre para aproveitar melhor o IJob",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 6),

            const Text(
              "Salve favoritos, acompanhe serviços e fale com prestadores.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E6FD9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: const Text("Entrar"),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CadastroScreen(),
                        ),
                      );
                    },
                    child: const Text("Criar conta"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CadastroPrestadorScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.work),
                    label: const Text("Prestador"),
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