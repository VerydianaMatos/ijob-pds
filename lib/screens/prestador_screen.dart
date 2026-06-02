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
  bool carregando = true;

  List<Prestador> prestadores = [];

  final TextEditingController buscaController = TextEditingController();

  final List<String> categorias = [
    "Todos",
    "Elétrica",
    "Hidráulica",
    "Limpeza",
    "Pintura",
    "Frete",
    "Montagem",
    "Jardinagem",
    "Ar-condicionado",
    "Diarista",
    "Pedreiro",
    "Marceneiro",
    "Chaveiro",
    "Informática",
    "Aulas",
    "Babá",
    "Mecânico",
    "Reformas",
  ];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  Future<void> carregarDados() async {
    setState(() {
      carregando = true;
    });

    final lista = await PrestadorService.carregarPrestadores();
    await FavoritoService.carregarFavoritos();

    if (!mounted) return;

    setState(() {
      prestadores = lista;
      carregando = false;
    });
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

    return prestadores.where((p) {
      final combinaCategoria =
          categoriaSelecionada == "Todos" ||
              p.categorias.contains(categoriaSelecionada);

      final combinaBusca =
          textoBusca.isEmpty ||
              p.nome.toLowerCase().contains(textoBusca) ||
              p.profissao.toLowerCase().contains(textoBusca) ||
              p.categoria.toLowerCase().contains(textoBusca) ||
              p.categorias.any(
                    (cat) => cat.toLowerCase().contains(textoBusca),
              );

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
    final listaFiltrada = prestadoresFiltrados;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: carregarDados,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topo(),

                const SizedBox(height: 18),

                if (localizacaoAtiva) _localizacaoCard(),

                if (localizacaoAtiva) const SizedBox(height: 18),

                _campoBusca(),

                const SizedBox(height: 18),

                _categorias(),

                const SizedBox(height: 20),

                _tituloSecao(listaFiltrada.length),

                const SizedBox(height: 10),

                if (carregando)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1E6FD9),
                      ),
                    ),
                  ),

                if (!carregando && listaFiltrada.isEmpty)
                  _nenhumEncontrado(),

                if (!carregando)
                  ...listaFiltrada.map(
                        (Prestador p) => PrestadorCard(
                      nome: p.nome,
                      profissao: p.profissao,
                      distancia: "${p.distancia} de distância",
                      rating: p.rating,
                      disponivel: p.disponivel,
                      favorito: FavoritoService.isFavorito(p.nome),
                      fotoUrl: p.fotoUrl,
                      onFavoritoTap: () async {
                        await FavoritoService.alternarFavorito({
                          "nome": p.nome,
                          "profissao": p.profissao,
                          "categoria": p.categoria,
                          "categorias": p.categorias,
                          "distancia": p.distancia,
                          "rating": p.rating,
                          "disponivel": p.disponivel,
                          "descricao": p.descricao,
                          "preco": p.preco,
                          "resposta": p.resposta,
                          "servicos": p.servicos,
                          "fotoUrl": p.fotoUrl,
                        });

                        if (!mounted) return;

                        setState(() {});
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
      ),
    );
  }

  Widget _topo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E6FD9),
            Color(0xFF3D8BFF),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 18,
              ),
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
                  Icons.my_location,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            "Encontre o profissional ideal",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Serviços rápidos, confiáveis e perto de você",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.verified,
                    color: Color(0xFF1E6FD9),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Profissionais verificados",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        "${prestadores.length} prestadores cadastrados no IJob",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _localizacaoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : const Color(0xFFE3F0FF),
          borderRadius: BorderRadius.circular(16),
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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Ativa",
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
    );
  }

  Widget _campoBusca() {
    return Padding(
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
        ),
      ),
    );
  }

  Widget _categorias() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          return _categoria(categorias[index]);
        },
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selecionada
              ? const Color(0xFF1E6FD9)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (selecionada)
              BoxShadow(
                color: const Color(0xFF1E6FD9).withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          nome,
          style: TextStyle(
            color: selecionada
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _tituloSecao(int quantidade) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              carregando
                  ? "Buscando profissionais..."
                  : "$quantidade profissional(is) encontrado(s)",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          IconButton(
            onPressed: carregarDados,
            icon: const Icon(
              Icons.sync,
              color: Color(0xFF1E6FD9),
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
    );
  }

  Widget _nenhumEncontrado() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
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
              "Cadastre um prestador ou tente outra categoria.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.account_circle,
              color: Color(0xFF1E6FD9),
              size: 42,
            ),

            const SizedBox(height: 8),

            const Text(
              "Entre para aproveitar melhor o IJob",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
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