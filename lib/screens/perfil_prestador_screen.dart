import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/agendamento_model.dart';
import '../models/prestador_model.dart';
import '../services/agendamento_service.dart';
import '../services/auth_service.dart';
import '../services/avaliacao_service.dart';
import '../services/chat_service.dart';
import '../services/favorito_service.dart';
import '../services/location_service.dart';
import 'agendamento_screen.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

class PerfilPrestadorScreen extends StatefulWidget {
  final Prestador prestador;

  const PerfilPrestadorScreen({super.key, required this.prestador});

  @override
  State<PerfilPrestadorScreen> createState() => _PerfilPrestadorScreenState();
}

class _PerfilPrestadorScreenState extends State<PerfilPrestadorScreen> {
  GoogleMapController? mapController;
  LocalizacaoAtual? minhaLocalizacao;
  bool carregandoMinhaLocalizacao = false;

  bool get jaAgendou {
    return AgendamentoService.agendamentos.any(
      (a) => a.nomePrestador == widget.prestador.nome,
    );
  }

  bool get podeAvaliar {
    return AgendamentoService.agendamentos.any(
      (a) => a.nomePrestador == widget.prestador.nome && a.concluido,
    );
  }

  int get atendimentosConcluidos {
    return AgendamentoService.agendamentos
        .where((a) => a.nomePrestador == widget.prestador.nome && a.concluido)
        .length;
  }

  Agendamento? get atendimentoConcluidoParaAvaliar {
    try {
      return AgendamentoService.agendamentos.firstWhere(
        (a) => a.nomePrestador == widget.prestador.nome && a.concluido,
      );
    } catch (_) {
      return null;
    }
  }

  double? get distanciaAtePrestadorKm {
    final minhaPosicao = minhaLocalizacao;
    if (minhaPosicao == null) return null;

    return LocationService.calcularDistanciaEmKm(
      origemLatitude: minhaPosicao.latitude,
      origemLongitude: minhaPosicao.longitude,
      destinoLatitude: widget.prestador.latitude,
      destinoLongitude: widget.prestador.longitude,
    );
  }

  bool get estaDentroDaArea {
    final distancia = distanciaAtePrestadorKm;
    if (distancia == null) return true;
    return distancia <= widget.prestador.raioAtendimentoKm;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      carregarMinhaLocalizacao();
    });
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<void> carregarMinhaLocalizacao() async {
    if (carregandoMinhaLocalizacao) return;

    setState(() {
      carregandoMinhaLocalizacao = true;
    });

    try {
      final localizacao = await LocationService.obterLocalizacaoAtual();

      if (!mounted) return;

      setState(() {
        minhaLocalizacao = localizacao;
        carregandoMinhaLocalizacao = false;
      });

      await _enquadrarMapa();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        carregandoMinhaLocalizacao = false;
      });
    }
  }

  Future<void> _enquadrarMapa() async {
    final controller = mapController;
    final minhaPosicao = minhaLocalizacao;

    if (controller == null || minhaPosicao == null) return;

    final prestador = widget.prestador;
    final prestadorPoint = LatLng(prestador.latitude, prestador.longitude);
    final meuPoint = LatLng(minhaPosicao.latitude, minhaPosicao.longitude);

    final bounds = LatLngBounds(
      southwest: LatLng(
        math.min(prestadorPoint.latitude, meuPoint.latitude),
        math.min(prestadorPoint.longitude, meuPoint.longitude),
      ),
      northeast: LatLng(
        math.max(prestadorPoint.latitude, meuPoint.latitude),
        math.max(prestadorPoint.longitude, meuPoint.longitude),
      ),
    );

    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 64));
  }

  @override
  Widget build(BuildContext context) {
    final prestador = widget.prestador;
    final favorito = FavoritoService.isFavorito(prestador.nome);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil do profissional"),
        actions: [
          IconButton(
            tooltip: favorito ? "Remover favorito" : "Favoritar",
            onPressed: () => _alternarFavorito(prestador),
            icon: Icon(
              favorito ? Icons.favorite : Icons.favorite_border,
              color: favorito ? Colors.redAccent : Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _hero(prestador),
              const SizedBox(height: 14),
              _metricas(prestador),
              const SizedBox(height: 14),
              _servicos(prestador),
              const SizedBox(height: 14),
              _destaques(prestador),
              const SizedBox(height: 14),
              _portfolio(prestador),
              const SizedBox(height: 14),
              _agenda(prestador),
              const SizedBox(height: 14),
              _sobre(prestador),
              const SizedBox(height: 14),
              _localizacao(prestador),
              const SizedBox(height: 14),
              _avaliacoes(),
              const SizedBox(height: 18),
              _acoesDoPerfil(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero(Prestador prestador) {
    final colorScheme = Theme.of(context).colorScheme;
    final disponivel = prestador.disponivel;
    final distancia = distanciaAtePrestadorKm;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white,
            backgroundImage: _fotoProvider(prestador),
            child: _fotoProvider(prestador) == null
                ? Text(
                    _iniciais(prestador.nome),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            prestador.nome,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            prestador.profissao,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(Icons.category, prestador.categoria),
              if (prestador.idade > 0)
                _pill(Icons.cake, "${prestador.idade} anos"),
              if (distancia != null)
                _pill(
                  Icons.near_me,
                  "${LocationService.formatarDistancia(distancia)} de você",
                ),
              StreamBuilder(
                stream: AvaliacaoService.porPrestador(prestador.nome),
                builder: (context, snapshot) {
                  final avaliacoes = snapshot.data ?? [];

                  if (avaliacoes.isEmpty) {
                    return _pill(Icons.star, "Sem avaliações");
                  }

                  final media =
                      avaliacoes
                          .map((avaliacao) => avaliacao.estrelas)
                          .reduce((total, estrelas) => total + estrelas) /
                      avaliacoes.length;

                  return _pill(Icons.star, media.toStringAsFixed(1));
                },
              ),
              _pill(Icons.location_on, _localizacaoCurta(prestador.endereco)),
              _pill(
                Icons.radar,
                "Até ${prestador.raioAtendimentoKm.round()} km",
              ),
              _pill(
                disponivel ? Icons.check_circle : Icons.schedule,
                disponivel ? "Disponível" : "Ocupado",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricas(Prestador prestador) {
    return Row(
      children: [
        Expanded(
          child: _infoCard(Icons.attach_money, prestador.preco, "Preço"),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _infoCard(Icons.flash_on, prestador.resposta, "Resposta"),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _infoCard(Icons.verified, prestador.servicos, "Experiência"),
        ),
      ],
    );
  }

  Widget _infoCard(IconData icon, String valor, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 98,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colorScheme.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _servicos(Prestador prestador) {
    return _section(
      "Serviços oferecidos",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.handyman,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    prestador.profissao,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _chipsPorCategoria(prestador.categoria),
          ),
        ],
      ),
    );
  }

  Widget _sobre(Prestador prestador) {
    return _section(
      "Sobre",
      Text(
        prestador.descricao.isEmpty
            ? "Profissional disponível para atendimento na sua região."
            : prestador.descricao,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _destaques(Prestador prestador) {
    final frases = prestador.frasesPerfil.isEmpty
        ? [
            "Atendimento com compromisso",
            "Orçamento claro antes do serviço",
            "Serviço feito com capricho",
          ]
        : prestador.frasesPerfil;

    return _section(
      "Destaques",
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: frases.map((frase) {
          return Chip(
            avatar: const Icon(Icons.check_circle, size: 18),
            label: Text(frase),
          );
        }).toList(),
      ),
    );
  }

  Widget _portfolio(Prestador prestador) {
    if (prestador.fotosServicos.isEmpty) {
      return _section(
        "Fotos dos serviços",
        Text(
          "Este prestador ainda não adicionou fotos de serviços realizados.",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return _section(
      "Fotos dos serviços",
      SizedBox(
        height: 132,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: prestador.fotosServicos.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final foto = prestador.fotosServicos[index];
            final provider = _imagemServicoProvider(foto);

            if (provider == null) return const SizedBox.shrink();

            return ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image(
                image: provider,
                width: 132,
                height: 132,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _agenda(Prestador prestador) {
    return _section(
      "Agenda",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_month, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  prestador.diasAtendimento.isEmpty
                      ? "Dias não informados"
                      : prestador.diasAtendimento.join(", "),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: prestador.horariosAtendimento.isEmpty
                ? [const Chip(label: Text("Sem horários cadastrados"))]
                : prestador.horariosAtendimento
                      .map((horario) => Chip(label: Text(horario)))
                      .toList(),
          ),
        ],
      ),
    );
  }

  Widget _localizacao(Prestador prestador) {
    final colorScheme = Theme.of(context).colorScheme;
    final prestadorPoint = LatLng(prestador.latitude, prestador.longitude);
    final minhaPosicao = minhaLocalizacao;
    final meuPoint = minhaPosicao == null
        ? null
        : LatLng(minhaPosicao.latitude, minhaPosicao.longitude);
    final markers = <Marker>{
      Marker(
        markerId: MarkerId(prestador.id ?? prestador.nome),
        position: prestadorPoint,
        infoWindow: InfoWindow(
          title: prestador.nome,
          snippet: prestador.endereco,
        ),
      ),
      if (meuPoint != null)
        Marker(
          markerId: const MarkerId("minha-localizacao"),
          position: meuPoint,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: "Você"),
        ),
    };

    return _section(
      "Localização",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 280,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: prestadorPoint,
                      zoom: 14,
                    ),
                    onTap: (_) => _abrirMapaExpandido(prestador),
                    mapType: MapType.normal,
                    markers: markers,
                    circles: {
                      Circle(
                        circleId: CircleId(
                          "raio-${prestador.id ?? prestador.nome}",
                        ),
                        center: prestadorPoint,
                        radius: prestador.raioAtendimentoKm * 1000,
                        fillColor: colorScheme.primary.withOpacity(0.12),
                        strokeColor: colorScheme.primary.withOpacity(0.55),
                        strokeWidth: 2,
                      ),
                    },
                    compassEnabled: true,
                    mapToolbarEnabled: true,
                    myLocationButtonEnabled: minhaPosicao != null,
                    myLocationEnabled: minhaPosicao != null,
                    zoomControlsEnabled: true,
                    onMapCreated: (controller) async {
                      mapController = controller;
                      await _enquadrarMapa();
                    },
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.94),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 5),
                          const Text(
                            "Google Maps",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Material(
                      color: colorScheme.surface.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(999),
                      elevation: 3,
                      child: IconButton(
                        tooltip: "Expandir mapa",
                        onPressed: () => _abrirMapaExpandido(prestador),
                        icon: Icon(
                          Icons.fullscreen,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _mapLegend(colorScheme),
          const SizedBox(height: 10),
          _areaAtendimentoInfo(prestador),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.near_me,
                size: 17,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  minhaPosicao == null
                      ? "Mapa mostrando o prestador. Permita a localização para ver onde você está."
                      : "Mapa mostrando você e ${prestador.nome}.",
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
              TextButton(
                onPressed: carregandoMinhaLocalizacao
                    ? null
                    : carregarMinhaLocalizacao,
                child: Text(
                  carregandoMinhaLocalizacao ? "Buscando" : "Atualizar",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _abrirMapaExpandido(Prestador prestador) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _MapaExpandidoScreen(
          prestador: prestador,
          minhaLocalizacao: minhaLocalizacao,
        ),
      ),
    );
  }

  Widget _mapLegend(ColorScheme colorScheme) {
    return Row(
      children: [
        _legendItem(Colors.red, "Prestador"),
        const SizedBox(width: 12),
        _legendItem(Colors.blue, "Você"),
      ],
    );
  }

  Widget _areaAtendimentoInfo(Prestador prestador) {
    final distancia = distanciaAtePrestadorKm;
    final dentro = estaDentroDaArea;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dentro
            ? Colors.green.withOpacity(0.10)
            : Colors.red.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            dentro ? Icons.check_circle : Icons.warning_amber,
            color: dentro ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              distancia == null
                  ? "Área de atendimento: até ${prestador.raioAtendimentoKm.round()} km do endereço do prestador."
                  : dentro
                  ? "Você está dentro da área de atendimento (${LocationService.formatarDistancia(distancia)})."
                  : "Você está fora da área de atendimento. Distância: ${LocationService.formatarDistancia(distancia)}.",
              style: TextStyle(
                color: dentro ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_pin, size: 18, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _avaliacoes() {
    return StreamBuilder(
      stream: AvaliacaoService.porPrestador(widget.prestador.nome),
      builder: (context, snapshot) {
        final avaliacoes = snapshot.data ?? [];

        if (avaliacoes.isEmpty) {
          return _section(
            "Avaliações",
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.star_border,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Este prestador ainda não possui avaliações. A primeira avaliação aparece após um atendimento concluído.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return _section(
          "Avaliações recentes",
          Column(
            children: avaliacoes.take(3).map((avaliacao) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _avaliacao(
                  "${avaliacao.estrelas}/5 - ${avaliacao.comentario.isEmpty ? avaliacao.nomeCliente : avaliacao.comentario}",
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _avaliacao(String texto) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        const Icon(Icons.star, color: Colors.orange, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  ImageProvider? _fotoProvider(Prestador prestador) {
    if (prestador.fotoPath.isEmpty) return null;

    if (prestador.fotoPath.startsWith("http")) {
      return NetworkImage(prestador.fotoPath);
    }

    final arquivo = File(prestador.fotoPath);
    if (!arquivo.existsSync()) return null;

    return FileImage(arquivo);
  }

  ImageProvider? _imagemServicoProvider(String foto) {
    if (foto.isEmpty) return null;

    if (foto.startsWith("http")) {
      return NetworkImage(foto);
    }

    final arquivo = File(foto);
    if (!arquivo.existsSync()) return null;

    return FileImage(arquivo);
  }

  Widget _section(String title, Widget child) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _acoesDoPerfil() {
    final colorScheme = Theme.of(context).colorScheme;
    final foraDaArea = !estaDentroDaArea;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: foraDaArea
                      ? Colors.red.withOpacity(0.10)
                      : colorScheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  foraDaArea ? Icons.location_off : Icons.calendar_month,
                  color: foraDaArea ? Colors.red : colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foraDaArea
                          ? "Prestador fora da sua região"
                          : "Solicitar atendimento",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      foraDaArea
                          ? "Procure profissionais mais próximos de você."
                          : "O prestador confirma ou recusa a solicitação.",
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: foraDaArea
                  ? () => Navigator.pop(context)
                  : _agendarServico,
              icon: Icon(foraDaArea ? Icons.search : Icons.send),
              label: Text(
                foraDaArea
                    ? "Buscar prestadores próximos"
                    : "Enviar solicitação",
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: _abrirWhatsApp,
              icon: const Icon(Icons.phone),
              label: const Text("Chamar no WhatsApp"),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF18A558),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          if (jaAgendou) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _abrirChat,
                icon: const Icon(Icons.chat),
                label: const Text("Conversar com prestador"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _abrirWhatsApp() async {
    final telefone = widget.prestador.telefone.replaceAll(
      RegExp(r"[^0-9]"),
      "",
    );
    if (telefone.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Este prestador ainda não cadastrou WhatsApp."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final numero = telefone.startsWith("55") ? telefone : "55$telefone";
    final texto = Uri.encodeComponent(
      "Olá, vi seu perfil no IJob e gostaria de solicitar um atendimento.",
    );
    final uri = Uri.parse("https://wa.me/$numero?text=$texto");

    final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!abriu && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não foi possível abrir o WhatsApp."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _abrirChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          contato: widget.prestador.nome,
          chatId: ChatService.chatId(AuthService.nome, widget.prestador.nome),
        ),
      ),
    );
  }

  Future<void> _agendarServico() async {
    if (!estaDentroDaArea) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Você está fora da área de atendimento deste prestador.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!AuthService.isLogged) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      setState(() {});
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgendamentoScreen(prestador: widget.prestador),
      ),
    );

    setState(() {});
  }

  void _alternarFavorito(Prestador prestador) {
    setState(() {
      FavoritoService.alternarFavorito({
        "nome": prestador.nome,
        "profissao": prestador.profissao,
        "distancia": prestador.distancia,
        "rating": prestador.rating,
        "disponivel": prestador.disponivel,
      });
    });
  }

  List<Widget> _chipsPorCategoria(String categoria) {
    final Map<String, List<String>> dados = {
      "Elétrica": [
        "Instalações",
        "Reparos",
        "Quadro elétrico",
        "Tomadas",
        "Iluminação",
      ],
      "Limpeza": [
        "Limpeza residencial",
        "Limpeza pesada",
        "Organização",
        "Faxina completa",
      ],
      "Faxina": [
        "Faxina residencial",
        "Faxina pesada",
        "Organização",
        "Limpeza pós-obra",
      ],
      "Cuidadora": ["Idosos", "Acompanhamento", "Cuidados diários", "Plantões"],
      "Babá": [
        "Cuidado infantil",
        "Acompanhamento escolar",
        "Horário noturno",
        "Recreação",
      ],
      "Cozinha": ["Comida caseira", "Marmitas", "Eventos", "Confeitaria"],
      "Hidráulica": ["Vazamentos", "Encanamento", "Torneiras", "Manutenção"],
      "Pintura": [
        "Pintura interna",
        "Pintura externa",
        "Acabamento",
        "Textura",
      ],
      "Frete": ["Mudanças", "Entregas", "Transporte", "Carretos"],
      "Jardinagem": [
        "Corte de grama",
        "Poda",
        "Paisagismo",
        "Manutenção de jardim",
      ],
      "Beleza": [
        "Maquiagem",
        "Cabelo",
        "Sobrancelha",
        "Atendimento domiciliar",
      ],
      "Manicure": ["Mão", "Pé", "Alongamento", "Esmaltação"],
      "Pet care": ["Passeio", "Banho", "Pet sitter", "Cuidados em casa"],
      "Informática": ["Formatação", "Instalação", "Suporte técnico", "Redes"],
      "Aulas particulares": [
        "Reforço escolar",
        "Idiomas",
        "Música",
        "Preparatório",
      ],
      "Manutenção": [
        "Pequenos reparos",
        "Montagem",
        "Instalações",
        "Consertos",
      ],
      "Outro": [
        "Serviço personalizado",
        "Atendimento sob consulta",
        "Orçamento",
      ],
    };

    final lista = dados[categoria] ?? ["Serviço geral"];

    return lista.map((item) => Chip(label: Text(item))).toList();
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(" ");

    if (partes.length == 1) {
      return partes.first[0].toUpperCase();
    }

    return "${partes[0][0]}${partes[1][0]}".toUpperCase();
  }

  String _localizacaoCurta(String endereco) {
    final partes = endereco.split(",");

    if (partes.length >= 2) {
      return partes[partes.length - 2].trim();
    }

    return endereco;
  }
}

class _MapaExpandidoScreen extends StatelessWidget {
  final Prestador prestador;
  final LocalizacaoAtual? minhaLocalizacao;

  const _MapaExpandidoScreen({
    required this.prestador,
    required this.minhaLocalizacao,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final prestadorPoint = LatLng(prestador.latitude, prestador.longitude);
    final meuPoint = minhaLocalizacao == null
        ? null
        : LatLng(minhaLocalizacao!.latitude, minhaLocalizacao!.longitude);

    final markers = <Marker>{
      Marker(
        markerId: MarkerId(prestador.id ?? prestador.nome),
        position: prestadorPoint,
        infoWindow: InfoWindow(title: prestador.nome, snippet: "Prestador"),
      ),
      if (meuPoint != null)
        Marker(
          markerId: const MarkerId("cliente"),
          position: meuPoint,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: "Você"),
        ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Mapa do atendimento")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: prestadorPoint,
              zoom: 14,
            ),
            markers: markers,
            circles: {
              Circle(
                circleId: CircleId("raio-${prestador.id ?? prestador.nome}"),
                center: prestadorPoint,
                radius: prestador.raioAtendimentoKm * 1000,
                fillColor: colorScheme.primary.withOpacity(0.12),
                strokeColor: colorScheme.primary.withOpacity(0.55),
                strokeWidth: 2,
              ),
            },
            myLocationEnabled: meuPoint != null,
            myLocationButtonEnabled: meuPoint != null,
            zoomControlsEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: true,
            onMapCreated: (controller) async {
              if (meuPoint == null) return;

              final bounds = LatLngBounds(
                southwest: LatLng(
                  math.min(prestadorPoint.latitude, meuPoint.latitude),
                  math.min(prestadorPoint.longitude, meuPoint.longitude),
                ),
                northeast: LatLng(
                  math.max(prestadorPoint.latitude, meuPoint.latitude),
                  math.max(prestadorPoint.longitude, meuPoint.longitude),
                ),
              );

              await controller.animateCamera(
                CameraUpdate.newLatLngBounds(bounds, 72),
              );
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _legendaMapa(Colors.red, "Prestador"),
                    const SizedBox(width: 14),
                    _legendaMapa(Colors.blue, "Você"),
                    const Spacer(),
                    Text(
                      "Atende até ${prestador.raioAtendimentoKm.round()} km",
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendaMapa(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_pin, color: color, size: 18),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
