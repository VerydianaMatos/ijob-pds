import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/notificacao_service.dart';
import 'home_screen.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool ocultarSenha = true;
  bool salvando = false;

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
    final email = emailController.text.trim().toLowerCase();
    final telefone = telefoneController.text.trim();
    final senha = senhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || telefone.isEmpty || senha.isEmpty) {
      _mensagem("Preencha todos os campos para criar sua conta.", Colors.red);
      return;
    }

    if (senha.length < 6) {
      _mensagem("A senha precisa ter pelo menos 6 caracteres.", Colors.red);
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      await AuthService.cadastrarCliente(
        nomeUser: nome,
        emailUser: email,
        telefoneUser: telefone,
        senha: senha,
      );
      await NotificacaoService.salvarToken();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        salvando = false;
      });
      _mensagem(
        "Não foi possível criar a conta. Verifique o e-mail e a senha.",
        Colors.red,
      );
      return;
    }

    if (!mounted) return;

    _mensagem("Conta criada com sucesso!", Colors.green);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _mensagem(String texto, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: cor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Criar conta")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
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
                        Icons.person_add,
                        size: 38,
                        color: Color(0xFF1E6FD9),
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      "Cadastro de cliente",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Crie sua conta para agendar serviços e salvar favoritos.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _campo("Nome completo", Icons.person, nomeController),
              const SizedBox(height: 12),
              _campo("Email", Icons.email, emailController),
              const SizedBox(height: 12),
              _campo("Telefone", Icons.phone, telefoneController),
              const SizedBox(height: 12),
              TextField(
                controller: senhaController,
                obscureText: ocultarSenha,
                decoration: InputDecoration(
                  labelText: "Senha",
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
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: salvando ? null : cadastrar,
                icon: salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(salvando ? "Criando conta..." : "Cadastrar cliente"),
              ),
            ],
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



