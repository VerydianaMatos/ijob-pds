import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/prestador_model.dart';
import '../services/auth_service.dart';
import '../services/prestador_service.dart';

import 'home_screen.dart';

class CadastroPrestadorScreen extends StatefulWidget {
  const CadastroPrestadorScreen({super.key});

  @override
  State<CadastroPrestadorScreen> createState() =>
      _CadastroPrestadorScreenState();
}

class _CadastroPrestadorScreenState extends State<CadastroPrestadorScreen> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final cidadeController = TextEditingController();
  final profissaoController = TextEditingController();
  final precoController = TextEditingController();
  final experienciaController = TextEditingController();
  final descricaoController = TextEditingController();

  List<String> categoriasSelecionadas = ["Elétrica"];

  bool carregandoLocalizacao = false;
  bool salvando = false;

  File? fotoSelecionada;

  final List<String> categorias = [
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
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    cidadeController.dispose();
    profissaoController.dispose();
    precoController.dispose();
    experienciaController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  Future<void> escolherFoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Foto do perfil",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _botaoFoto(
                        icon: Icons.camera_alt,
                        titulo: "Câmera",
                        onTap: () async {
                          Navigator.pop(context);

                          final imagem = await ImagePicker().pickImage(
                            source: ImageSource.camera,
                            imageQuality: 75,
                          );

                          if (imagem != null) {
                            setState(() {
                              fotoSelecionada = File(imagem.path);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _botaoFoto(
                        icon: Icons.photo_library,
                        titulo: "Galeria",
                        onTap: () async {
                          Navigator.pop(context);

                          final imagem = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 75,
                          );

                          if (imagem != null) {
                            setState(() {
                              fotoSelecionada = File(imagem.path);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> usarMinhaLocalizacao() async {
    setState(() {
      carregandoLocalizacao = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      carregandoLocalizacao = false;
      cidadeController.text = "Capão da Canoa - RS";
    });
  }

  Future<void> cadastrarPrestador() async {
    if (nomeController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        telefoneController.text.trim().isEmpty ||
        cidadeController.text.trim().isEmpty ||
        profissaoController.text.trim().isEmpty ||
        precoController.text.trim().isEmpty ||
        experienciaController.text.trim().isEmpty ||
        descricaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha todos os campos antes de cadastrar."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      salvando = true;
    });

    final prestador = Prestador(
      nome: nomeController.text.trim(),
      profissao: profissaoController.text.trim(),
      categoria: categoriasSelecionadas.first,
      categorias: categoriasSelecionadas,
      distancia: "0.5 km",
      rating: 5.0,
      disponivel: true,
      descricao: descricaoController.text.trim(),
      preco: precoController.text.trim(),
      resposta: "~5 min",
      servicos: "Novo",
      fotoUrl: fotoSelecionada?.path ?? "",
    );

    await PrestadorService.adicionarPrestador(prestador);

    AuthService.loginPrestador(
      nomeController.text.trim(),
      emailController.text.trim(),
      cidadeController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      salvando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Prestador cadastrado com sucesso!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Seja um prestador"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E6FD9),
                    Color(0xFF3D8BFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: escolherFoto,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      backgroundImage: fotoSelecionada != null
                          ? FileImage(fotoSelecionada!)
                          : null,
                      child: fotoSelecionada == null
                          ? const Icon(
                        Icons.add_a_photo,
                        size: 36,
                        color: Color(0xFF1E6FD9),
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Adicionar foto profissional",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Toque na imagem para tirar foto ou escolher da galeria",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _secao("Dados pessoais"),
                  _campo("Nome completo", Icons.person, nomeController),
                  const SizedBox(height: 14),
                  _campo("Email", Icons.email, emailController),
                  const SizedBox(height: 14),
                  _campo("Telefone", Icons.phone, telefoneController),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _secao("Dados profissionais"),
                  _campo(
                    "Profissão / Serviço",
                    Icons.handyman,
                    profissaoController,
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    "Categorias que você atende",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: categorias.map((categoria) {
                      final selecionada =
                      categoriasSelecionadas.contains(categoria);

                      return FilterChip(
                        label: Text(categoria),
                        selected: selecionada,
                        backgroundColor: isDark
                            ? const Color(0xFF0F172A)
                            : Colors.white,
                        selectedColor: const Color(0xFFEAF2FF),
                        checkmarkColor: const Color(0xFF1E6FD9),
                        labelStyle: TextStyle(
                          color: selecionada
                              ? const Color(0xFF1E6FD9)
                              : Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              categoriasSelecionadas.add(categoria);
                            } else {
                              if (categoriasSelecionadas.length > 1) {
                                categoriasSelecionadas.remove(categoria);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  _campo(
                    "Preço médio Ex: R\$ 80",
                    Icons.attach_money,
                    precoController,
                  ),

                  const SizedBox(height: 14),

                  _campo(
                    "Tempo de experiência",
                    Icons.timeline,
                    experienciaController,
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: descricaoController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Descrição profissional",
                      hintText: "Conte sobre sua experiência...",
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _secao("Localização"),
                  _campo(
                    "Cidade / Localização",
                    Icons.location_on,
                    cidadeController,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: carregandoLocalizacao
                          ? null
                          : usarMinhaLocalizacao,
                      icon: const Icon(Icons.my_location),
                      label: Text(
                        carregandoLocalizacao
                            ? "Buscando localização..."
                            : "Usar minha localização",
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: salvando ? null : cadastrarPrestador,
                icon: salvando
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.check),
                label: Text(
                  salvando ? "Salvando..." : "Cadastrar como prestador",
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _secao(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
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

  Widget _card({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: child,
    );
  }

  Widget _botaoFoto({
    required IconData icon,
    required String titulo,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 34,
              color: const Color(0xFF1E6FD9),
            ),
            const SizedBox(height: 10),
            Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}