import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/prestador_model.dart';
import '../services/prestador_service.dart';

class EditarPrestadorScreen extends StatefulWidget {
  final Prestador prestador;

  const EditarPrestadorScreen({
    super.key,
    required this.prestador,
  });

  @override
  State<EditarPrestadorScreen> createState() => _EditarPrestadorScreenState();
}

class _EditarPrestadorScreenState extends State<EditarPrestadorScreen> {
  late final TextEditingController profissaoController;
  late final TextEditingController telefoneController;
  late final TextEditingController precoController;
  late final TextEditingController servicosController;
  late final TextEditingController respostaController;
  late final TextEditingController descricaoController;
  late final TextEditingController idadeController;
  final TextEditingController fraseController = TextEditingController();
  final TextEditingController horarioController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();

  late bool disponivel;
  late String categoriaSelecionada;
  late String fotoPath;
  late double raioAtendimentoKm;
  late List<String> diasAtendimento;
  late List<String> horariosAtendimento;
  late List<String> fotosServicos;
  late List<String> frasesSelecionadas;
  String? fraseProntaSelecionada;
  bool salvando = false;

  final List<String> categorias = const [
    "Elétrica",
    "Hidráulica",
    "Limpeza",
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

  final List<String> todosDias = const [
    "Segunda",
    "Terça",
    "Quarta",
    "Quinta",
    "Sexta",
    "Sábado",
    "Domingo",
  ];

  final List<String> frasesDisponiveis = const [
    "Atendimento com compromisso",
    "Orçamento claro antes do serviço",
    "Servico feito com capricho",
    "Pontualidade no atendimento",
    "Material e execucao de qualidade",
    "Experiencia com clientes residenciais",
    "Disponível para chamados próximos",
    "Organização e limpeza após o serviço",
  ];

  @override
  void initState() {
    super.initState();
    profissaoController = TextEditingController(text: widget.prestador.profissao);
    telefoneController = TextEditingController(text: widget.prestador.telefone);
    precoController = TextEditingController(text: widget.prestador.preco);
    servicosController = TextEditingController(text: widget.prestador.servicos);
    respostaController = TextEditingController(text: widget.prestador.resposta);
    descricaoController = TextEditingController(text: widget.prestador.descricao);
    idadeController = TextEditingController(
      text: widget.prestador.idade == 0 ? "" : widget.prestador.idade.toString(),
    );
    disponivel = widget.prestador.disponivel;
    categoriaSelecionada = categorias.contains(widget.prestador.categoria)
        ? widget.prestador.categoria
        : categorias.first;
    fotoPath = widget.prestador.fotoPath;
    raioAtendimentoKm = widget.prestador.raioAtendimentoKm;
    diasAtendimento = [...widget.prestador.diasAtendimento];
    horariosAtendimento = [...widget.prestador.horariosAtendimento];
    fotosServicos = [...widget.prestador.fotosServicos];
    frasesSelecionadas = widget.prestador.frasesPerfil.isEmpty
        ? [
            "Atendimento com compromisso",
            "Orçamento claro antes do serviço",
            "Servico feito com capricho",
          ]
        : [...widget.prestador.frasesPerfil];
  }

  @override
  void dispose() {
    profissaoController.dispose();
    telefoneController.dispose();
    precoController.dispose();
    servicosController.dispose();
    respostaController.dispose();
    descricaoController.dispose();
    idadeController.dispose();
    fraseController.dispose();
    horarioController.dispose();
    super.dispose();
  }

  Future<void> escolherFoto(ImageSource origem) async {
    final imagem = await imagePicker.pickImage(
      source: origem,
      imageQuality: 78,
      maxWidth: 1200,
    );

    if (imagem == null || !mounted) return;

    setState(() {
      fotoPath = imagem.path;
    });
  }

  Future<void> escolherFotosServicos() async {
    final imagens = await imagePicker.pickMultiImage(
      imageQuality: 76,
      maxWidth: 1200,
    );

    if (imagens.isEmpty || !mounted) return;

    setState(() {
      fotosServicos.addAll(imagens.map((imagem) => imagem.path));
    });
  }

  Future<void> tirarFotoServico() async {
    final imagem = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 76,
      maxWidth: 1200,
    );

    if (imagem == null || !mounted) return;

    setState(() {
      fotosServicos.add(imagem.path);
    });
  }

  void removerFotoServico(String caminho) {
    setState(() {
      fotosServicos.remove(caminho);
    });
  }

  void alternarFrase(String frase) {
    setState(() {
      if (frasesSelecionadas.contains(frase)) {
        frasesSelecionadas.remove(frase);
      } else {
        frasesSelecionadas.add(frase);
      }
    });
  }

  void adicionarFrasePronta(String? frase) {
    if (frase == null || frase.trim().isEmpty) return;

    setState(() {
      fraseProntaSelecionada = frase;
      if (!frasesSelecionadas.contains(frase)) {
        frasesSelecionadas.add(frase);
      }
    });
  }

  void adicionarFraseDigitada() {
    final frase = fraseController.text.trim();

    if (frase.isEmpty) return;

    setState(() {
      if (!frasesSelecionadas.contains(frase)) {
        frasesSelecionadas.add(frase);
      }
      fraseController.clear();
    });
  }

  void removerFrase(String frase) {
    setState(() {
      frasesSelecionadas.remove(frase);
    });
  }

  void alternarDia(String dia) {
    setState(() {
      if (diasAtendimento.contains(dia)) {
        diasAtendimento.remove(dia);
      } else {
        diasAtendimento.add(dia);
      }
    });
  }

  void adicionarHorario() {
    final horario = horarioController.text.trim();

    if (!RegExp(r"^\d{2}:\d{2}$").hasMatch(horario)) {
      _mensagem("Digite o horário no formato HH:mm.", Colors.red);
      return;
    }

    setState(() {
      if (!horariosAtendimento.contains(horario)) {
        horariosAtendimento.add(horario);
        horariosAtendimento.sort();
      }
      horarioController.clear();
    });
  }

  void removerHorario(String horario) {
    setState(() {
      horariosAtendimento.remove(horario);
    });
  }

  Future<void> salvar() async {
    final id = widget.prestador.id;
    final profissao = profissaoController.text.trim();

    if (id == null || id.isEmpty) {
      _mensagem("Não foi possível identificar este cadastro.", Colors.red);
      return;
    }

    if (profissao.isEmpty) {
      _mensagem("Informe sua profissão ou serviço principal.", Colors.red);
      return;
    }

    if (diasAtendimento.isEmpty || horariosAtendimento.isEmpty) {
      _mensagem("Defina pelo menos um dia e um horário.", Colors.red);
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final fotoFinal = await PrestadorService.enviarFotoPrestador(
        widget.prestador.email,
        fotoPath,
      );
      if (fotoPath.isNotEmpty && fotoFinal == fotoPath) {
        _mensagem(
          "Foto salva neste aparelho. Ative o Firebase Storage para salvar na nuvem.",
          Colors.orange,
        );
      }

      await PrestadorService.atualizarPrestador(id, {
        "profissao": profissao,
        "telefone": telefoneController.text.trim(),
        "categoria": categoriaSelecionada,
        "preco": _precoFormatado(precoController.text.trim()),
        "servicos": servicosController.text.trim().isEmpty
            ? "Novo"
            : servicosController.text.trim(),
        "resposta": respostaController.text.trim(),
        "descricao": descricaoController.text.trim(),
        "disponivel": disponivel,
        "fotoPath": fotoFinal,
        "idade": int.tryParse(idadeController.text.trim()) ?? 0,
        "fotosServicos": fotosServicos,
        "frasesPerfil": frasesSelecionadas,
        "raioAtendimentoKm": raioAtendimentoKm,
        "diasAtendimento": diasAtendimento,
        "horariosAtendimento": horariosAtendimento,
      });

      if (!mounted) return;

      _mensagem("Perfil atualizado com sucesso.", Colors.green);
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        salvando = false;
      });
      _mensagem("Não foi possível atualizar agora.", Colors.red);
    }
  }

  void _mensagem(String texto, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: cor),
    );
  }

  String _precoFormatado(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) return "A combinar";
    if (texto.toLowerCase().contains("combinar")) return "A combinar";
    if (texto.startsWith("R\$")) return texto;

    final somenteNumero = texto.replaceAll(",", ".").replaceAll(
          RegExp(r"[^0-9.]"),
          "",
        );
    final numero = double.tryParse(somenteNumero);

    if (numero == null) return texto;

    return "R\$ ${numero.toStringAsFixed(2).replaceAll(".", ",")}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar perfil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _fotoPerfil(),
            const SizedBox(height: 18),
            _dadosServico(),
            const SizedBox(height: 18),
            _frasesPerfil(),
            const SizedBox(height: 18),
            _fotosServicos(),
            const SizedBox(height: 18),
            _raioAtendimento(),
            const SizedBox(height: 18),
            _agendaAtendimento(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: salvando ? null : salvar,
              icon: salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(salvando ? "Salvando..." : "Salvar alterações"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fotoPerfil() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: colorScheme.primary.withOpacity(0.12),
            backgroundImage: _fotoProvider(),
            child: _fotoProvider() == null
                ? Icon(Icons.person, size: 46, color: colorScheme.primary)
                : null,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => escolherFoto(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text("Câmera"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => escolherFoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Galeria"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dadosServico() {
    final colorScheme = Theme.of(context).colorScheme;

    return _painel(
      icon: Icons.handyman,
      title: "Informações do serviço",
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: categoriaSelecionada,
            decoration: const InputDecoration(
              labelText: "Categoria",
              prefixIcon: Icon(Icons.category),
            ),
            items: categorias.map((categoria) {
              return DropdownMenuItem(
                value: categoria,
                child: Text(categoria),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                categoriaSelecionada = value;
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: profissaoController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: "Profissão / serviço principal",
              prefixIcon: Icon(Icons.work),
              hintText: "Ex: Eletricista residencial",
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: telefoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "WhatsApp / telefone",
              prefixIcon: Icon(Icons.phone),
              hintText: "Ex: 51999999999",
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: servicosController,
            decoration: const InputDecoration(
              labelText: "Serviços realizados ou experiência",
              prefixIcon: Icon(Icons.verified),
              hintText: "Ex: Novo, 20+ serviços, 5 anos",
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: idadeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Idade",
              prefixIcon: Icon(Icons.cake),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: disponivel,
            contentPadding: EdgeInsets.zero,
            activeColor: colorScheme.primary,
            onChanged: (value) => setState(() => disponivel = value),
            title: const Text("Disponível para atendimento"),
            subtitle: const Text("Clientes verão este status no seu perfil"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: precoController,
            decoration: const InputDecoration(
              labelText: "Preço médio",
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: respostaController,
            decoration: const InputDecoration(
              labelText: "Tempo médio de resposta",
              prefixIcon: Icon(Icons.flash_on),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descricaoController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: "Descrição profissional",
              prefixIcon: Icon(Icons.description),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _agendaAtendimento() {
    return _painel(
      icon: Icons.calendar_month,
      title: "Agenda de atendimento",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dias disponíveis",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: todosDias.map((dia) {
              final selecionado = diasAtendimento.contains(dia);

              return FilterChip(
                label: Text(dia),
                selected: selecionado,
                onSelected: (_) => alternarDia(dia),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          const Text(
            "Horários disponíveis",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: horarioController,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: "Ex: 18:30",
                    prefixIcon: Icon(Icons.schedule),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: adicionarHorario,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: horariosAtendimento.map((horario) {
              return InputChip(
                label: Text(horario),
                onDeleted: () => removerHorario(horario),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _frasesPerfil() {
    final colorScheme = Theme.of(context).colorScheme;

    return _painel(
      icon: Icons.tips_and_updates,
      title: "Destaques do perfil",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Escolha frases prontas ou escreva suas próprias.",
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: fraseProntaSelecionada,
            decoration: const InputDecoration(
              labelText: "Escolher frase pronta",
              prefixIcon: Icon(Icons.format_quote),
            ),
            items: frasesDisponiveis.map((frase) {
              return DropdownMenuItem(
                value: frase,
                child: Text(frase, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: adicionarFrasePronta,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: fraseController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: "Escrever frase própria",
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: adicionarFraseDigitada,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (frasesSelecionadas.isEmpty)
            Text(
              "Nenhuma frase adicionada.",
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            )
          else
            Column(
              children: frasesSelecionadas.map((frase) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          frase,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        onPressed: () => removerFrase(frase),
                        icon: const Icon(Icons.close),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _fotosServicos() {
    final colorScheme = Theme.of(context).colorScheme;

    return _painel(
      icon: Icons.collections,
      title: "Fotos dos serviços",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Adicione fotos de serviços já realizados.",
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: tirarFotoServico,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text("Câmera"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: escolherFotosServicos,
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Galeria"),
                ),
              ),
            ],
          ),
          if (fotosServicos.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: fotosServicos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final foto = fotosServicos[index];

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image(
                          image: _servicoFotoProvider(foto),
                          width: 92,
                          height: 92,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: InkWell(
                          onTap: () => removerFotoServico(foto),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.58),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _raioAtendimento() {
    final colorScheme = Theme.of(context).colorScheme;

    return _painel(
      icon: Icons.radar,
      title: "Área de atendimento",
      trailing: Text(
        "${raioAtendimentoKm.round()} km",
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Clientes fora deste raio verão que estão fora da sua área.",
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          Slider(
            value: raioAtendimentoKm,
            min: 1,
            max: 50,
            divisions: 49,
            label: "${raioAtendimentoKm.round()} km",
            onChanged: (value) {
              setState(() {
                raioAtendimentoKm = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _painel({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
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

  ImageProvider _servicoFotoProvider(String foto) {
    if (foto.startsWith("http")) {
      return NetworkImage(foto);
    }

    final arquivo = File(foto);
    if (arquivo.existsSync()) {
      return FileImage(arquivo);
    }

    return const AssetImage("assets/imagens/logo.png");
  }
}



