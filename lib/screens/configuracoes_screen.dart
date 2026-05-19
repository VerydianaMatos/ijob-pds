import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  late TextEditingController nomeController;
  late TextEditingController emailController;

  final TextEditingController senhaAtualController = TextEditingController();
  final TextEditingController novaSenhaController = TextEditingController();

  bool notificacoes = true;
  bool localizacao = true;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: AuthService.nome);
    emailController = TextEditingController(text: AuthService.email);
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaAtualController.dispose();
    novaSenhaController.dispose();
    super.dispose();
  }

  void salvarDados() {
    AuthService.nome = nomeController.text;
    AuthService.email = emailController.text;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dados atualizados com sucesso!")),
    );

    Navigator.pop(context);
  }

  void alterarSenha() {
    if (novaSenhaController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A nova senha deve ter pelo menos 6 caracteres."),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Senha alterada com sucesso!")),
    );

    senhaAtualController.clear();
    novaSenhaController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Configurações"),
        backgroundColor: const Color(0xFF1E6FD9),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _titulo("Dados da conta"),

            _campo(
              label: "Nome",
              icon: Icons.person,
              controller: nomeController,
            ),

            const SizedBox(height: 12),

            _campo(
              label: "Email",
              icon: Icons.email,
              controller: emailController,
            ),

            const SizedBox(height: 24),

            _titulo("Alterar senha"),

            _campo(
              label: "Senha atual",
              icon: Icons.lock,
              controller: senhaAtualController,
              senha: true,
            ),

            const SizedBox(height: 12),

            _campo(
              label: "Nova senha",
              icon: Icons.lock_outline,
              controller: novaSenhaController,
              senha: true,
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: alterarSenha,
                child: const Text("Alterar senha"),
              ),
            ),

            const SizedBox(height: 24),

            _titulo("Preferências"),

            _switchOpcao(
              icon: Icons.notifications,
              title: "Notificações",
              subtitle: "Receber alertas de serviços",
              value: notificacoes,
              onChanged: (value) {
                setState(() {
                  notificacoes = value;
                });
              },
            ),

            _switchOpcao(
              icon: Icons.location_on,
              title: "Localização",
              subtitle: "Usar localização para encontrar prestadores",
              value: localizacao,
              onChanged: (value) {
                setState(() {
                  localizacao = value;
                });
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E6FD9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: salvarDados,
                child: const Text("Salvar alterações"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titulo(String texto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          texto,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _campo({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool senha = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: senha,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _switchOpcao({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        value: value,
        activeColor: const Color(0xFF1E6FD9),
        onChanged: onChanged,
        secondary: Icon(icon, color: const Color(0xFF1E6FD9)),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}