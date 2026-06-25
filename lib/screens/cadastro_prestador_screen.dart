import 'package:flutter/material.dart';

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

class _CadastroPrestadorScreenState
    extends State<CadastroPrestadorScreen> {

  final TextEditingController nomeController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController telefoneController =
  TextEditingController();

  final TextEditingController cidadeController =
  TextEditingController();

  final TextEditingController profissaoController =
  TextEditingController();

  final TextEditingController precoController =
  TextEditingController();

  final TextEditingController experienciaController =
  TextEditingController();

  final TextEditingController descricaoController =
  TextEditingController();

  String categoriaSelecionada = "Elétrica";

  bool carregandoLocalizacao = false;

  final List<String> categorias = [
    "Elétrica",
    "Hidráulica",
    "Limpeza",
    "Pintura",
    "Frete",
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

  Future<void> usarMinhaLocalizacao() async {

    setState(() {
      carregandoLocalizacao = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    setState(() {
      carregandoLocalizacao = false;

      cidadeController.text =
      "Capão da Canoa - RS";
    });
  }

  void cadastrarPrestador() {

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
          content: Text(
            "Preencha todos os campos antes de cadastrar.",
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final nome =
    nomeController.text.trim();

    final email =
    emailController.text.trim();

    final cidade =
    cidadeController.text.trim();

    final profissao =
    profissaoController.text.trim();

    final preco =
    precoController.text.trim();

    final descricao =
    descricaoController.text.trim();

    PrestadorService.adicionarPrestador(
      Prestador(
        nome: nome,
        profissao: profissao,
        categoria: categoriaSelecionada,
        distancia: "0.5 km",
        rating: 5.0,
        disponivel: true,
        descricao: descricao,
        preco: preco,
        resposta: "~5 min",
        servicos: "Novo",
      ),
    );

    AuthService.loginPrestador(
      nome,
      email,
      cidade,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Prestador cadastrado com sucesso!",
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),

          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F7FA),

      appBar: AppBar(
        title:
        const Text("Seja um prestador"),

        backgroundColor:
        const Color(0xFF1E6FD9),

        foregroundColor: Colors.white,

        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          children: [

            Container(
              width: double.infinity,

              padding:
              const EdgeInsets.all(22),

              decoration: BoxDecoration(
                gradient:
                const LinearGradient(
                  colors: [
                    Color(0xFF1E6FD9),
                    Color(0xFF3D8BFF),
                  ],
                ),

                borderRadius:
                BorderRadius.circular(
                    24),
              ),

              child: const Column(
                children: [

                  CircleAvatar(
                    radius: 36,
                    backgroundColor:
                    Colors.white,

                    child: Icon(
                      Icons.work,
                      size: 38,
                      color:
                      Color(0xFF1E6FD9),
                    ),
                  ),

                  SizedBox(height: 14),

                  Text(
                    "Cadastre seu serviço",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "Seu perfil aparecerá para clientes próximos.",

                    textAlign:
                    TextAlign.center,

                    style: TextStyle(
                      color:
                      Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _secao("Dados pessoais"),

            _campo(
              "Nome completo",
              Icons.person,
              nomeController,
            ),

            const SizedBox(height: 14),

            _campo(
              "Email",
              Icons.email,
              emailController,
            ),

            const SizedBox(height: 14),

            _campo(
              "Telefone",
              Icons.phone,
              telefoneController,
            ),

            const SizedBox(height: 24),

            _secao("Dados profissionais"),

            _campo(
              "Profissão / Serviço",
              Icons.handyman,
              profissaoController,
            ),

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              value: categoriaSelecionada,

              decoration: InputDecoration(
                labelText: "Categoria",

                prefixIcon:
                const Icon(
                    Icons.category),

                filled: true,

                fillColor: Colors.white,

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                      16),
                ),
              ),

              items:
              categorias.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  categoriaSelecionada =
                  value!;
                });
              },
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
              controller:
              descricaoController,

              maxLines: 4,

              decoration: InputDecoration(
                labelText:
                "Descrição profissional",

                hintText:
                "Conte sobre sua experiência...",

                prefixIcon:
                const Icon(
                    Icons.description),

                alignLabelWithHint: true,

                filled: true,

                fillColor: Colors.white,

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                      16),
                ),
              ),
            ),

            const SizedBox(height: 24),

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
                onPressed:
                carregandoLocalizacao
                    ? null
                    : usarMinhaLocalizacao,

                icon:
                const Icon(
                    Icons.my_location),

                label: Text(
                  carregandoLocalizacao
                      ? "Buscando localização..."
                      : "Usar minha localização",
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                      0xFF1E6FD9),

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 15,
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                        16),
                  ),
                ),

                onPressed:
                cadastrarPrestador,

                icon:
                const Icon(Icons.check),

                label: const Text(
                  "Cadastrar como prestador",
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

    return Align(
      alignment: Alignment.centerLeft,

      child: Padding(
        padding:
        const EdgeInsets.only(
            bottom: 10),

        child: Text(
          titulo,

          style: const TextStyle(
            fontWeight:
            FontWeight.bold,
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

        filled: true,

        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
              16),
        ),
      ),
    );
  }
}