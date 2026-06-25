import 'package:flutter/material.dart';

import '../models/prestador_model.dart';
import '../services/auth_service.dart';
import '../services/favorito_service.dart';
import '../services/location_service.dart';
import '../services/prestador_service.dart';
import '../widgets/prestador_card.dart';
import 'cadastro_prestador_screen.dart';
import 'cadastro_screen.dart';
import 'login_screen.dart';
import 'perfil_prestador_screen.dart';

class PrestadorScreen extends StatefulWidget {
  const PrestadorScreen({super.key});

  @override
  State<PrestadorScreen> createState() => _PrestadorScreenState();
}

class _PrestadorScreenState extends State<PrestadorScreen> {
  String categoriaSelecionada = "Todos";
  bool localizacaoAtiva = false;
  bool apenasPrestadoresProximos = false;
  bool carregandoLocalizacao = false;
  bool pediuLocalizacaoInicial = false;
  LocalizacaoAtual? localizacaoAtual;

  final TextEditingController buscaController = TextEditingController();

  final List<String> categorias = const [
    "Todos",
    "Elétrica",
    "Limpeza",
    "Hidráulica",
    "Faxina",
    "Cuidadora",
    "Babá",
    "Cozinha",
    "Pintura",
    "Frete",
    "Jardinagem",
    "Beleza",
    "Manicure",
    "Pet care",
    "Informática",
    "Aulas particulares",
    "Manutenção",
    "Outro",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!pediuLocalizacaoInicial && mounted) {
        pediuLocalizacaoInicial = true;
        carregarLocalizacao(silencioso: true);
      }
    });
  }

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  Future<void> carregarLocalizacao({bool silencioso = false}) async {
    setState(() {
      carregandoLocalizacao = true;
    });

    try {
      final localizacao = await LocationService.obterLocalizacaoAtual();

      if (!mounted) return;

      setState(() {
        localizacaoAtual = localizacao;
        localizacaoAtiva = true;
        carregandoLocalizacao = false;
      });

      if (!silencioso) {
        _mostrarMensagem(
          "Localização ativada em ${localizacao.enderecoCurto}.",
          Colors.green,
        );
      }
    } on LocationException catch (erro) {
      if (!mounted) return;
      _finalizarLocalizacaoComErro(erro.message, silencioso: silencioso);
    } catch (_) {
      if (!mounted) return;
      _finalizarLocalizacaoComErro(
        "Não foi possível acessar sua localização agora.",
        silencioso: silencioso,
      );
    }
  }

  void _finalizarLocalizacaoComErro(
    String mensagem, {
    bool silencioso = false,
  }) {
    setState(() {
      carregandoLocalizacao = false;
    });

    if (!silencioso) {
      _mostrarMensagem(mensagem, Colors.red);
    }
  }

  void _mostrarMensagem(String mensagem, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: cor),
    );
  }

  double? distanciaEmKmDoPrestador(Prestador prestador) {
    final localizacao = localizacaoAtual;

    if (localizacao == null) {
      return null;
    }

    return LocationService.calcularDistanciaEmKm(
      origemLatitude: localizacao.latitude,
      origemLongitude: localizacao.longitude,
      destinoLatitude: prestador.latitude,
      destinoLongitude: prestador.longitude,
    );
  }

  bool prestadorAtendeMinhaRegiao(Prestador prestador) {
    final distancia = distanciaEmKmDoPrestador(prestador);

    if (distancia == null) {
      return true;
    }

    return distancia <= prestador.raioAtendimentoKm;
  }

  Future<void> alternarFiltroPrestadoresProximos() async {
    if (apenasPrestadoresProximos) {
      setState(() {
        apenasPrestadoresProximos = false;
      });
      return;
    }

    if (!localizacaoAtiva || localizacaoAtual == null) {
      await carregarLocalizacao();
    }

    if (!mounted || localizacaoAtual == null) return;

    setState(() {
      apenasPrestadoresProximos = true;
    });
  }

  String distanciaDoPrestador(Prestador prestador) {
    final distancia = distanciaEmKmDoPrestador(prestador);

    if (distancia == null) {
      return "${prestador.distancia} de distância";
    }

    return "${LocationService.formatarDistancia(distancia)} de distância";
  }

  List<Prestador> ordenarPorDistancia(List<Prestador> prestadores) {
    final localizacao = localizacaoAtual;

    if (localizacao == null) {
      return prestadores;
    }

    final lista = [...prestadores];

    lista.sort((a, b) {
      final distanciaA = distanciaEmKmDoPrestador(a) ?? double.infinity;
      final distanciaB = distanciaEmKmDoPrestador(b) ?? double.infinity;

      return distanciaA.compareTo(distanciaB);
    });

    return lista;
  }

  List<Prestador> prestadoresFiltrados(List<Prestador> origem) {
    final textoBusca = buscaController.text.trim().toLowerCase();

    final filtrados = origem.where((p) {
      final combinaCategoria =
          categoriaSelecionada == "Todos" || p.categoria == categoriaSelecionada;

      final combinaBusca = textoBusca.isEmpty ||
          p.nome.toLowerCase().contains(textoBusca) ||
          p.profissao.toLowerCase().contains(textoBusca) ||
          p.categoria.toLowerCase().contains(textoBusca);

      final combinaRegiao =
          !apenasPrestadoresProximos || prestadorAtendeMinhaRegiao(p);

      return combinaCategoria && combinaBusca && combinaRegiao;
    }).toList();

    return ordenarPorDistancia(filtrados);
  }

  void favoritarPrestador(Prestador prestador) {
    setState(() {
      FavoritoService.alternarFavorito({
        "nome": prestador.nome,
        "profissao": prestador.profissao,
        "distancia": distanciaDoPrestador(prestador),
        "rating": prestador.rating,
        "disponivel": prestador.disponivel,
      });
    });
  }

  void limparBusca() {
    setState(() {
      buscaController.clear();
      categoriaSelecionada = "Todos";
    });
  }

  String get textoLocalizacao {
    final localizacao = localizacaoAtual;
    return localizacaoAtiva && localizacao != null
        ? localizacao.enderecoCurto
        : "Permitir localização";
  }

  String get mensagemLocalizacao {
    final localizacao = localizacaoAtual;

    if (localizacao == null) {
      return "Compartilhe sua localização para ver profissionais mais próximos.";
    }

    final precisao = localizacao.precisaoEmMetros.round();
    return "${localizacao.resumo} • precisão de $precisao m";
  }

  String get statusLocalizacao {
    if (carregandoLocalizacao) return "Buscando";
    return localizacaoAtiva ? "Ativa" : "Ativar";
  }

  Widget get iconeLocalizacao {
    if (carregandoLocalizacao) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }

    return Icon(
      localizacaoAtiva ? Icons.my_location : Icons.near_me,
      color: Colors.white,
      size: 20,
    );
  }

  VoidCallback? get acaoLocalizacao {
    if (carregandoLocalizacao) return null;
    return carregarLocalizacao;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Prestador>>(
          stream: PrestadorService.observarPrestadores(),
          builder: (context, snapshot) {
            final origem = snapshot.hasData && snapshot.data!.isNotEmpty
                ? snapshot.data!
                : PrestadorService.prestadores;
            final prestadores = prestadoresFiltrados(origem);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topo(),
                  const SizedBox(height: 18),
                  _cardLocalizacao(),
                  const SizedBox(height: 10),
                  _botaoPrestadoresProximos(),
                  const SizedBox(height: 18),
                  _campoBusca(),
                  const SizedBox(height: 18),
                  _listaCategorias(),
                  const SizedBox(height: 20),
                  _cabecalhoLista(snapshot.connectionState),
                  const SizedBox(height: 10),
                  if (prestadores.isEmpty) _estadoVazio(),
                  ...prestadores.map(_cardPrestador),
                  const SizedBox(height: 24),
                  if (!AuthService.isLogged) _cardConta(),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _topo() {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.handyman, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "IJob",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      textoLocalizacao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: acaoLocalizacao,
                icon: iconeLocalizacao,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            "Encontre profissionais perto de você",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Agende serviços, acompanhe solicitações e fale com prestadores reais.",
            style: TextStyle(color: Colors.white70, height: 1.35),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _topoInfo(Icons.verified, "Perfis", "verificados"),
              const SizedBox(width: 10),
              _topoInfo(Icons.schedule, "Agenda", "por horário"),
              const SizedBox(width: 10),
              _topoInfo(Icons.map, "Mapa", "real"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topoInfo(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 7),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avisoBancoOffline() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange.withOpacity(0.35)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Banco indisponível agora. Mostrando dados salvos.",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardLocalizacao() {
    final cardAtivo = localizacaoAtiva;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: acaoLocalizacao,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardAtivo
                ? colorScheme.primary.withOpacity(0.1)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: cardAtivo
                  ? colorScheme.primary.withOpacity(0.24)
                  : colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(
                cardAtivo ? Icons.location_on : Icons.near_me_outlined,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mensagemLocalizacao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        cardAtivo ? colorScheme.primary : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cardAtivo ? colorScheme.surface : colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLocalizacao,
                  style: TextStyle(
                    color:
                        cardAtivo ? colorScheme.primary : colorScheme.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botaoPrestadoresProximos() {
    final colorScheme = Theme.of(context).colorScheme;
    final ativo = apenasPrestadoresProximos;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: carregandoLocalizacao ? null : alternarFiltroPrestadoresProximos,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: ativo ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ativo
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withOpacity(0.6),
            ),
          ),
          child: Row(
            children: [
              Icon(
                ativo ? Icons.filter_alt_off : Icons.near_me,
                color: ativo ? colorScheme.onPrimary : colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ativo ? "Mostrar todos os prestadores" : "Prestadores próximos de você",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ativo ? colorScheme.onPrimary : colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (carregandoLocalizacao)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ativo ? colorScheme.onPrimary : colorScheme.primary,
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: ativo
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
            ],
          ),
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

  Widget _listaCategorias() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: categorias.map(_categoria).toList(),
      ),
    );
  }

  Widget _cabecalhoLista(ConnectionState connectionState) {
    final carregandoBanco = connectionState == ConnectionState.waiting;
    final titulo = apenasPrestadoresProximos
        ? "Atendem sua região"
        : "Prestadores perto de você";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (carregandoBanco) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
          if (localizacaoAtiva)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                "mais próximos",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          if (buscaController.text.isNotEmpty || categoriaSelecionada != "Todos")
            TextButton(onPressed: limparBusca, child: const Text("Limpar")),
        ],
      ),
    );
  }

  Widget _estadoVazio() {
    final titulo = apenasPrestadoresProximos
        ? "Nenhum prestador atende sua região"
        : "Nenhum prestador encontrado";
    final mensagem = apenasPrestadoresProximos
        ? "Mostre todos ou aumente a busca por categoria."
        : "Tente buscar por outro serviço ou categoria.";

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 45, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardPrestador(Prestador prestador) {
    final atendeRegiao = prestadorAtendeMinhaRegiao(prestador);

    return PrestadorCard(
      nome: prestador.nome,
      profissao: prestador.profissao,
      distancia: distanciaDoPrestador(prestador),
      rating: prestador.rating,
      disponivel: prestador.disponivel,
      atendeRegiao: atendeRegiao,
      raioAtendimentoKm: prestador.raioAtendimentoKm,
      fotoPath: prestador.fotoPath,
      favorito: FavoritoService.isFavorito(prestador.nome),
      onFavoritoTap: () => favoritarPrestador(prestador),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PerfilPrestadorScreen(prestador: prestador),
          ),
        );
      },
    );
  }

  Widget _categoria(String nome) {
    final selecionada = categoriaSelecionada == nome;
    final colorScheme = Theme.of(context).colorScheme;

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
          color: selecionada ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selecionada
                ? colorScheme.primary
                : colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          nome,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selecionada ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _cardConta() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            const Text(
              "Entre para aproveitar melhor o IJob",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              "Salve favoritos, acompanhe serviços e fale com prestadores.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
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



