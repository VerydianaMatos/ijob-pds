import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final senhaController = TextEditingController();

  bool carregando = false;

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> cadastrar() async {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final telefone = telefoneController.text.trim();
    final senha = senhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || telefone.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha todos os campos."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (senha.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A senha precisa ter pelo menos 6 caracteres."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => carregando = true);

    final erro = await AuthService.cadastrarCliente(
      nomeUser: nome,
      emailUser: email,
      senha: senha,
    );

    if (!mounted) return;

    setState(() => carregando = false);

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Criar conta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.person_add,
                    size: 70,
                    color: Color(0xFF1E6FD9),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Cadastro de cliente",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  _campo("Nome completo", Icons.person, nomeController),
                  const SizedBox(height: 12),
                  _campo("Email", Icons.email, emailController),
                  const SizedBox(height: 12),
                  _campo("Telefone", Icons.phone, telefoneController),
                  const SizedBox(height: 12),
                  _campo("Senha", Icons.lock, senhaController, senha: true),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: carregando ? null : cadastrar,
                      icon: carregando
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
                        carregando ? "Cadastrando..." : "Cadastrar cliente",
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              isDark ? "Modo escuro ativo 🌙" : "Modo claro ativo ☀️",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(
      String label,
      IconData icon,
      TextEditingController controller, {
        bool senha = false,
      }) {
    return TextField(
      controller: controller,
      obscureText: senha,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}