import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/theme_service.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() =>
      _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState
    extends State<ConfiguracoesScreen> {
  late TextEditingController nomeController;
  late TextEditingController emailController;

  final TextEditingController senhaAtualController =
  TextEditingController();

  final TextEditingController novaSenhaController =
  TextEditingController();

  bool notificacoes = true;
  bool localizacao = true;
  bool modoEscuro = ThemeService.isDark;

  @override
  void initState() {
    super.initState();

    nomeController =
        TextEditingController(text: AuthService.nome);

    emailController =
        TextEditingController(text: AuthService.email);
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
      const SnackBar(
        content: Text("Dados atualizados com sucesso!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  void alterarSenha() {
    if (novaSenhaController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "A nova senha deve ter pelo menos 6 caracteres.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Senha alterada com sucesso!"),
        backgroundColor: Colors.green,
      ),
    );

    senhaAtualController.clear();
    novaSenhaController.clear();
  }

  void mostrarSobre() {
    showModalBottomSheet(
      context: context,

      backgroundColor: Theme.of(context).cardColor,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),

      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 55,
                height: 5,

                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 22),

              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFEAF2FF),

                child: Icon(
                  Icons.work,
                  color: Color(0xFF1E6FD9),
                  size: 34,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "IJob",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Versão 1.0.0",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 18),

              const Text(
                "Conectando clientes e profissionais de forma rápida, moderna e segura.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text("Fechar"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness ==
        Brightness.dark;

    return Scaffold(
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              // TOPO
              Container(
                width: double.infinity,

                padding: const EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  28,
                ),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1E6FD9),
                      Color(0xFF3D8BFF),
                    ],
                  ),

                  borderRadius: BorderRadius.all(
                    Radius.circular(28),
                  ),
                ),

                child: Column(
                  children: [

                    const CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,

                      child: Icon(
                        Icons.settings,
                        size: 40,
                        color: Color(0xFF1E6FD9),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "Configurações",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Gerencie sua conta e preferências",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // CONTA
              _secao("Dados da conta"),

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

              const SizedBox(height: 28),

              // SENHA
              _secao("Segurança"),

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

                child: OutlinedButton.icon(
                  onPressed: alterarSenha,

                  icon: const Icon(Icons.password),

                  label: const Text("Alterar senha"),
                ),
              ),

              const SizedBox(height: 28),

              // PREFERENCIAS
              _secao("Preferências"),

              _switchOpcao(
                icon: Icons.notifications,
                title: "Notificações",
                subtitle:
                "Receber alertas de serviços",

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
                subtitle:
                "Encontrar profissionais próximos",

                value: localizacao,

                onChanged: (value) {
                  setState(() {
                    localizacao = value;
                  });
                },
              ),

              _switchOpcao(
                icon: Icons.dark_mode,
                title: "Modo escuro",
                subtitle:
                "Alternar aparência do aplicativo",

                value: modoEscuro,

                onChanged: (value) {
                  setState(() {
                    modoEscuro = value;
                  });

                  ThemeService.toggleTheme(value);
                },
              ),

              const SizedBox(height: 28),

              // SOBRE
              _secao("Sobre"),

              _opcao(
                icon: Icons.info,
                titulo: "Sobre o app",
                subtitulo:
                "Informações sobre o IJob",

                onTap: mostrarSobre,
              ),

              _opcao(
                icon: Icons.privacy_tip,
                titulo: "Privacidade",
                subtitulo:
                "Segurança e proteção de dados",

                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Política de privacidade em breve.",
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // BOTAO
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: salvarDados,

                  icon: const Icon(Icons.save),

                  label:
                  const Text("Salvar alterações"),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                isDark
                    ? "Modo escuro ativado 🌙"
                    : "Modo claro ativado ☀️",

                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _secao(String texto) {
    return Align(
      alignment: Alignment.centerLeft,

      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),

        child: Text(
          texto,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
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
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: TextField(
        controller: controller,
        obscureText: senha,

        decoration: InputDecoration(
          labelText: label,

          prefixIcon: Icon(icon),

          border: InputBorder.none,

          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
        ),
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
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: SwitchListTile(
        value: value,

        activeColor: const Color(0xFF1E6FD9),

        onChanged: onChanged,

        secondary: Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(14),
          ),

          child: Icon(
            icon,
            color: const Color(0xFF1E6FD9),
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _opcao({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: ListTile(
        onTap: onTap,

        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),

        leading: Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(14),
          ),

          child: Icon(
            icon,
            color: const Color(0xFF1E6FD9),
          ),
        ),

        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          subtitulo,
          style: const TextStyle(fontSize: 12),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}