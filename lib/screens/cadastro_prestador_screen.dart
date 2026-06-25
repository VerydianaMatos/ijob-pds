import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/prestador_model.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/notificacao_service.dart';
import '../services/prestador_service.dart';
import 'home_screen.dart';

class CadastroPrestadorScreen extends StatefulWidget {
  const CadastroPrestadorScreen({super.key});

  @override
  State<CadastroPrestadorScreen> createState() =>
      _CadastroPrestadorScreenState();
}

class _CadastroPrestadorScreenState extends State<CadastroPrestadorScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController idadeController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController profissaoController = TextEditingController();
  final TextEditingController precoController = TextEditingController();
  final TextEditingController horarioController = TextEditingController();
  final TextEditingController experienciaController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController fraseController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();

  String categoriaSelecionada = "Elétrica";
  bool carregandoLocalizacao = false;
  bool validandoEndereco = false;
  bool salvando = false;
  bool ocultarSenha = true;
  double? latitudeSelecionada;
  double? longitudeSelecionada;
  double raioAtendimentoKm = 10;
  String? enderecoConfirmado;
  String fotoPath = "";
  final List<String> fotosServicos = [];
  final List<String> frasesSelecionadas = [
    "Atendimento com compromisso",
    "Orçamento claro antes do serviço",
    "Servico feito com capricho",
  ];
  String? fraseProntaSelecionada;
  final List<String> diasAtendimento = [
    "Segunda",
    "Terça",
    "Quarta",
    "Quinta",
    "Sexta",
  ];
  final List<String> horariosAtendimento = [
    "08:00",
    "09:00",
    "10:00",
    "11:00",
    "14:00",
    "15:00",
    "16:00",
  ];

  final List<String> todosDias = [
    "Segunda",
    "Terça",
    "Quarta",
    "Quinta",
    "Sexta",
    "Sábado",
    "Domingo",
  ];

  final List<String> categorias = [
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

  final List<String> frasesDisponiveis = [
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
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    idadeController.dispose();
    senhaController.dispose();
    cidadeController.dispose();
    profissaoController.dispose();
    precoController.dispose();
    horarioController.dispose();
    experienciaController.dispose();
    descricaoController.dispose();
    fraseController.dispose();
    super.dispose();
  }

  Future<void> usarMinhaLocalizacao() async {
    setState(() {
      carregandoLocalizacao = true;
    });

    try {
      final localizacao = await LocationService.obterLocalizacaoAtual();

      if (!mounted) return;

      setState(() {
        carregandoLocalizacao = false;
        latitudeSelecionada = localizacao.latitude;
        longitudeSelecionada = localizacao.longitude;
        enderecoConfirmado = localizacao.resumo;
        cidadeController.text = localizacao.resumo;
      });

      _mostrarMensagem("Localização confirmada.", Colors.green);
    } on LocationException catch (erro) {
      if (!mounted) return;
      _mostrarErroLocalizacao(erro.message);
    } catch (_) {
      if (!mounted) return;
      _mostrarErroLocalizacao(
        "Não foi possível acessar sua localização agora.",
      );
    }
  }

  Future<void> escolherFoto(ImageSource origem) async {
    try {
      final imagem = await imagePicker.pickImage(
        source: origem,
        imageQuality: 78,
        maxWidth: 1200,
      );

      if (imagem == null || !mounted) return;

      setState(() {
        fotoPath = imagem.path;
      });
    } catch (_) {
      if (!mounted) return;
      _mostrarMensagem("Não foi possível abrir a câmera ou galeria.", Colors.red);
    }
  }

  Future<void> escolherFotosServicos() async {
    try {
      final imagens = await imagePicker.pickMultiImage(
        imageQuality: 76,
        maxWidth: 1200,
      );

      if (imagens.isEmpty || !mounted) return;

      setState(() {
        fotosServicos.addAll(imagens.map((imagem) => imagem.path));
      });
    } catch (_) {
      if (!mounted) return;
      _mostrarMensagem("Não foi possível abrir a galeria.", Colors.red);
    }
  }

  Future<void> tirarFotoServico() async {
    try {
      final imagem = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 76,
        maxWidth: 1200,
      );

      if (imagem == null || !mounted) return;

      setState(() {
        fotosServicos.add(imagem.path);
      });
    } catch (_) {
      if (!mounted) return;
      _mostrarMensagem("Não foi possível abrir a câmera.", Colors.red);
    }
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
      _mostrarMensagem("Digite o horário no formato HH:mm.", Colors.red);
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

  Future<bool> confirmarEnderecoDigitado() async {
    final endereco = cidadeController.text.trim();

    if (endereco.isEmpty) {
      _mostrarMensagem("Digite um endereço para confirmar.", Colors.red);
      return false;
    }

    setState(() {
      validandoEndereco = true;
    });

    try {
      final localizacao = await LocationService.obterLocalizacaoPorEndereco(
        endereco,
      );

      if (!mounted) return false;

      setState(() {
        validandoEndereco = false;
        latitudeSelecionada = localizacao.latitude;
        longitudeSelecionada = localizacao.longitude;
        enderecoConfirmado = localizacao.resumo;
        cidadeController.text = localizacao.resumo;
      });

      _mostrarMensagem("Endereço confirmado.", Colors.green);
      return true;
    } on LocationException catch (erro) {
      if (!mounted) return false;
      setState(() {
        validandoEndereco = false;
      });
      _mostrarMensagem(erro.message, Colors.red);
      return false;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        validandoEndereco = false;
      });
      _mostrarMensagem("Não foi possível confirmar esse endereço.", Colors.red);
      return false;
    }
  }

  void _mostrarErroLocalizacao(String mensagem) {
    setState(() {
      carregandoLocalizacao = false;
    });

    _mostrarMensagem(mensagem, Colors.red);
  }

  void _mostrarMensagem(String mensagem, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
      ),
    );
  }

  Future<void> _entrarOuCriarContaPrestador({
    required String nome,
    required String email,
    required String senha,
    required String cidade,
  }) async {
    try {
      await AuthService.cadastrarPrestador(
        nomeUser: nome,
        emailUser: email,
        senha: senha,
        localizacaoUser: cidade,
      );
    } on FirebaseAuthException catch (erro) {
      if (erro.code != "email-already-in-use") {
        rethrow;
      }

      await AuthService.entrarCliente(
        emailUser: email,
        senha: senha,
      );
      AuthService.loginPrestador(nome, email, cidade);
    }
  }

  Future<void> cadastrarPrestador() async {
    if (!_camposValidos()) {
      _mostrarMensagem("Preencha todos os campos antes de cadastrar.", Colors.red);
      return;
    }

    setState(() {
      salvando = true;
    });

    if (latitudeSelecionada == null || longitudeSelecionada == null) {
      final confirmado = await confirmarEnderecoDigitado();

      if (!confirmado) {
        if (mounted) {
          setState(() {
            salvando = false;
          });
        }
        return;
      }
    }

    final nome = nomeController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final telefone = telefoneController.text.trim();
    final senha = senhaController.text.trim();
    final cidade = enderecoConfirmado ?? cidadeController.text.trim();
    final profissao = profissaoController.text.trim();
    final preco = _precoFormatado(precoController.text.trim());
    final descricao = descricaoController.text.trim();
    final idade = int.tryParse(idadeController.text.trim()) ?? 0;

    try {
      await _entrarOuCriarContaPrestador(
        nome: nome,
        email: email,
        senha: senha,
        cidade: cidade,
      );

      try {
        await NotificacaoService.salvarToken();
      } catch (_) {
        // O cadastro nao pode falhar se o aparelho nao liberar notificacao.
      }

      final fotoFinal = await PrestadorService.enviarFotoPrestador(
        email,
        fotoPath,
      );
      if (fotoPath.isNotEmpty && fotoFinal == fotoPath) {
        _mostrarMensagem(
          "Foto salva neste aparelho. Ative o Firebase Storage para salvar na nuvem.",
          Colors.orange,
        );
      }

      await PrestadorService.adicionarPrestador(
        Prestador(
          nome: nome,
          email: email,
          telefone: telefone,
          profissao: profissao,
          categoria: categoriaSelecionada,
          distancia: "0.5 km",
          rating: 5.0,
          disponivel: true,
          descricao: descricao,
          preco: preco,
          resposta: "~5 min",
          servicos: "Novo",
          latitude: latitudeSelecionada!,
          longitude: longitudeSelecionada!,
          endereco: cidade,
          fotoPath: fotoFinal,
          idade: idade,
          fotosServicos: fotosServicos,
          frasesPerfil: frasesSelecionadas,
          raioAtendimentoKm: raioAtendimentoKm,
          diasAtendimento: diasAtendimento,
          horariosAtendimento: horariosAtendimento,
        ),
      );
    } on FirebaseAuthException catch (erro) {
      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      final mensagem = _mensagemErroCadastroPrestador(erro);
      _mostrarMensagem(mensagem, Colors.red);
      return;
    } on FirebaseException catch (erro) {
      if (!mounted) return;

      debugPrint(
        "Erro ao salvar prestador no Firestore: ${erro.code} - ${erro.message}",
      );
      AuthService.logout();

      setState(() {
        salvando = false;
      });

      final mensagem = erro.code == "permission-denied"
          ? "O banco bloqueou o salvamento. Confira as regras do Firestore."
          : "O banco recusou o cadastro agora. Tente novamente em instantes.";
      _mostrarMensagem(mensagem, Colors.red);
      return;
    } catch (_) {
      if (!mounted) return;

      AuthService.logout();

      setState(() {
        salvando = false;
      });

      _mostrarMensagem("Não foi possível salvar no banco agora.", Colors.red);
      return;
    }

    if (!mounted) return;

    _mostrarMensagem("Prestador cadastrado com sucesso!", Colors.green);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  bool _camposValidos() {
    return nomeController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        telefoneController.text.trim().isNotEmpty &&
        int.tryParse(idadeController.text.trim()) != null &&
        senhaController.text.trim().length >= 6 &&
        cidadeController.text.trim().isNotEmpty &&
        profissaoController.text.trim().isNotEmpty &&
        precoController.text.trim().isNotEmpty &&
        diasAtendimento.isNotEmpty &&
        horariosAtendimento.isNotEmpty &&
        experienciaController.text.trim().isNotEmpty &&
        descricaoController.text.trim().isNotEmpty;
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

  String _mensagemErroCadastroPrestador(FirebaseAuthException erro) {
    switch (erro.code) {
      case "email-already-in-use":
      case "wrong-password":
      case "invalid-credential":
        return "Esse e-mail ja existe. Use a senha correta desse cadastro ou entre como prestador.";
      case "invalid-email":
        return "Digite um e-mail valido.";
      case "weak-password":
        return "A senha precisa ter pelo menos 6 caracteres.";
      case "network-request-failed":
        return "Sem conexao com a internet para salvar o cadastro.";
      case "too-many-requests":
        return "Muitas tentativas. Aguarde um pouco e tente novamente.";
      default:
        return "Não foi possível autenticar: ${erro.code}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seja um prestador"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _hero(colorScheme),
            const SizedBox(height: 24),
            _secao("Dados pessoais"),
            _fotoPerfil(colorScheme),
            const SizedBox(height: 18),
            _campo("Nome completo", Icons.person, nomeController),
            const SizedBox(height: 14),
            _campo("Email", Icons.email, emailController),
            const SizedBox(height: 14),
            _campo("Telefone", Icons.phone, telefoneController),
            const SizedBox(height: 14),
            TextField(
              controller: idadeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Idade",
                prefixIcon: Icon(Icons.cake),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: senhaController,
              obscureText: ocultarSenha,
              decoration: InputDecoration(
                labelText: "Senha de acesso",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      ocultarSenha = !ocultarSenha;
                    });
                  },
                  icon: Icon(
                    ocultarSenha ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _secao("Dados profissionais"),
            _campo("Profissão / Serviço", Icons.handyman, profissaoController),
            const SizedBox(height: 14),
            _dropdownCategoria(),
            const SizedBox(height: 14),
            _campo("Preço médio Ex: R\$ 80", Icons.attach_money, precoController),
            const SizedBox(height: 14),
            _campo("Tempo de experiência", Icons.timeline, experienciaController),
            const SizedBox(height: 14),
            _campoDescricao(),
            const SizedBox(height: 18),
            _frasesPerfil(),
            const SizedBox(height: 18),
            _fotosServicos(),
            const SizedBox(height: 24),
            _secao("Agenda de atendimento"),
            _agendaAtendimento(),
            const SizedBox(height: 24),
            _secao("Localização"),
            _campo(
              "Endereço, bairro ou cidade",
              Icons.location_on,
              cidadeController,
            ),
            const SizedBox(height: 10),
            _statusEndereco(),
            const SizedBox(height: 12),
            _botoesLocalizacao(),
            const SizedBox(height: 18),
            _raioAtendimento(),
            const SizedBox(height: 30),
            _botaoCadastrar(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _hero(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.work,
              size: 38,
              color: Color(0xFF1E6FD9),
            ),
          ),
          SizedBox(height: 14),
          Text(
            "Cadastre seu serviço",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Clientes próximos encontrarão seu perfil pela localização.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _fotoPerfil(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            backgroundImage:
                fotoPath.isEmpty ? null : FileImage(File(fotoPath)),
            child: fotoPath.isEmpty
                ? Icon(Icons.person, size: 48, color: colorScheme.primary)
                : null,
          ),
          const SizedBox(height: 14),
          const Text(
            "Foto profissional",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            "Uma foto real passa mais confiança para o cliente.",
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
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

  Widget _dropdownCategoria() {
    return DropdownButtonFormField<String>(
      value: categoriaSelecionada,
      decoration: const InputDecoration(
        labelText: "Categoria",
        prefixIcon: Icon(Icons.category),
      ),
      items: categorias.map((c) {
        return DropdownMenuItem(
          value: c,
          child: Text(c),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          categoriaSelecionada = value!;
        });
      },
    );
  }

  Widget _campoDescricao() {
    return TextField(
      controller: descricaoController,
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: "Descrição profissional",
        hintText: "Conte sobre sua experiência...",
        prefixIcon: Icon(Icons.description),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _frasesPerfil() {
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
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.tips_and_updates, color: colorScheme.primary),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Destaques do perfil",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Adicione frases curtas para passar confiança ao cliente.",
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 4),
          Text(
            "Essas frases aparecem no perfil público do prestador.",
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fotosServicos() {
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
          const Text(
            "Fotos de serviços realizados",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            "Mostre trabalhos anteriores para passar mais confiança.",
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
                        child: Image.file(
                          File(foto),
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

  Widget _agendaAtendimento() {
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
          const Text(
            "Dias disponíveis",
            style: TextStyle(fontWeight: FontWeight.bold),
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
            style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _statusEndereco() {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmado = latitudeSelecionada != null && longitudeSelecionada != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: confirmado
            ? Colors.green.withOpacity(0.1)
            : colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            confirmado ? Icons.check_circle : Icons.info_outline,
            color: confirmado ? Colors.green : colorScheme.onSurfaceVariant,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              confirmado
                  ? "Endereço confirmado para cálculo de distância."
                  : "Confirme o endereço ou use o GPS antes de salvar.",
              style: TextStyle(
                color: confirmado ? Colors.green : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _raioAtendimento() {
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
              Icon(Icons.radar, color: colorScheme.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Área de atendimento",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Text(
                "${raioAtendimentoKm.round()} km",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Defina até onde você atende a partir do endereço confirmado.",
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

  Widget _botoesLocalizacao() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: carregandoLocalizacao ? null : usarMinhaLocalizacao,
            icon: carregandoLocalizacao
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(carregandoLocalizacao ? "Buscando..." : "Usar GPS"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: validandoEndereco ? null : confirmarEnderecoDigitado,
            icon: validandoEndereco
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.place),
            label: Text(validandoEndereco ? "Validando..." : "Confirmar"),
          ),
        ),
      ],
    );
  }

  Widget _botaoCadastrar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: salvando ? null : cadastrarPrestador,
        icon: salvando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check),
        label: Text(salvando ? "Salvando..." : "Cadastrar como prestador"),
      ),
    );
  }

  Widget _secao(String titulo) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  Widget _campo(
    String label,
    IconData icon,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}



