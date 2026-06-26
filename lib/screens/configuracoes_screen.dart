import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/prestador_model.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/prestador_service.dart';
import '../theme/theme_controller.dart';
import 'editar_prestador_screen.dart';
import 'solicitacoes_prestador_screen.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  late TextEditingController nomeController;
  late TextEditingController emailController;
  late TextEditingController telefoneController;
  late TextEditingController localizacaoController;
  late TextEditingController novaSenhaController;
  late TextEditingController confirmarSenhaController;

  bool notificacoes = true;
  bool localizacao = true;
  bool atualizandoLocalizacao = false;
  bool ocultarSenha = true;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: AuthService.nome);
    emailController = TextEditingController(text: AuthService.email);
    telefoneController = TextEditingController(text: AuthService.telefone);
    localizacaoController = TextEditingController(text: AuthService.localizacao);
    novaSenhaController = TextEditingController();
    confirmarSenhaController = TextEditingController();
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    localizacaoController.dispose();
    novaSenhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> salvarDados() async {
    final nome = nomeController.text.trim();
    final telefone = telefoneController.text.trim();
    final localizacaoTexto = localizacaoController.text.trim();
    final novaSenha = novaSenhaController.text.trim();
    final confirmarSenha = confirmarSenhaController.text.trim();

    if (nome.isEmpty) {
      _mensagem("Informe seu nome.", Colors.red);
      return;
    }

    if (novaSenha.isNotEmpty || confirmarSenha.isNotEmpty) {
      if (novaSenha.length < 6) {
        _mensagem("A nova senha precisa ter pelo menos 6 caracteres.", Colors.red);
        return;
      }

      if (novaSenha != confirmarSenha) {
        _mensagem("As senhas não conferem.", Colors.red);
        return;
      }
    }

    setState(() {
      salvando = true;
    });

    try {
      await AuthService.atualizarPerfilCliente(
        nomeUser: nome,
        telefoneUser: telefone,
        localizacaoUser: localizacaoTexto,
      );

      if (novaSenha.isNotEmpty) {
        await AuthService.alterarSenha(novaSenha);
      }

      if (!mounted) return;

      setState(() {
        salvando = false;
        novaSenhaController.clear();
        confirmarSenhaController.clear();
      });

      _mensagem("Dados atualizados com sucesso.", Colors.green);
    } on FirebaseAuthException catch (erro) {
      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      final mensagem = erro.code == "requires-recent-login"
          ? "Para trocar a senha, saia e entre novamente antes de salvar."
          : "Não foi possível atualizar: ${erro.code}";
      _mensagem(mensagem, Colors.red);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        salvando = false;
      });
      _mensagem("Não foi possível atualizar agora.", Colors.red);
    }
  }

  Future<void> enviarRecuperacaoSenha() async {
    if (AuthService.email.isEmpty) {
      _mensagem("E-mail não encontrado para recuperação.", Colors.red);
      return;
    }

    try {
      await AuthService.enviarRecuperacaoSenha(AuthService.email);
      if (!mounted) return;
      _mensagem("Link de recuperação enviado para seu e-mail.", Colors.green);
    } catch (_) {
      if (!mounted) return;
      _mensagem("Não foi possível enviar o link agora.", Colors.red);
    }
  }

  Future<void> atualizarLocalizacaoPrestador(Prestador prestador) async {
    final id = prestador.id;

    if (id == null || id.isEmpty) {
      _mensagem("Perfil profissional não encontrado.", Colors.red);
      return;
    }

    setState(() {
      atualizandoLocalizacao = true;
    });

    try {
      final localizacao = await LocationService.obterLocalizacaoAtual();

      await PrestadorService.atualizarPrestador(id, {
        "latitude": localizacao.latitude,
        "longitude": localizacao.longitude,
        "endereco": localizacao.resumo,
        "localizacao": localizacao.resumo,
      });

      AuthService.localizacao = localizacao.enderecoCurto;

      if (!mounted) return;

      setState(() {
        atualizandoLocalizacao = false;
      });

      _mensagem("Localização profissional atualizada.", Colors.green);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        atualizandoLocalizacao = false;
      });

      _mensagem("Não foi possível acessar sua localização agora.", Colors.red);
    }
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
      appBar: AppBar(title: const Text("Configurações")),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.mode,
        builder: (context, themeMode, _) {
          final modoEscuro = ThemeController.isDark(context);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _perfilResumo(colorScheme),
                const SizedBox(height: 20),
                _painel(
                  title: "Dados da conta",
                  children: [
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
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    _campo(
                      label: "Telefone",
                      icon: Icons.phone,
                      controller: telefoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _campo(
                      label: "Localização",
                      icon: Icons.location_on,
                      controller: localizacaoController,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _painel(
                  title: "Segurança",
                  children: [
                    _campoSenha(
                      label: "Nova senha",
                      controller: novaSenhaController,
                    ),
                    const SizedBox(height: 12),
                    _campoSenha(
                      label: "Confirmar nova senha",
                      controller: confirmarSenhaController,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: enviarRecuperacaoSenha,
                        icon: const Icon(Icons.mark_email_read),
                        label: const Text("Enviar link de recuperação"),
                      ),
                    ),
                  ],
                ),
                if (AuthService.isPrestador) ...[
                  const SizedBox(height: 16),
                  _perfilProfissional(),
                ],
                const SizedBox(height: 16),
                _painel(
                  title: "Preferências",
                  children: [
                    _switchOpcao(
                      icon: modoEscuro ? Icons.dark_mode : Icons.light_mode,
                      title: "Modo escuro",
                      subtitle: "Alternar entre aparência clara e escura",
                      value: modoEscuro,
                      onChanged: (value) {
                        setState(() {
                          ThemeController.setDarkMode(value);
                        });
                      },
                    ),
                    _switchOpcao(
                      icon: Icons.notifications,
                      title: "Notificações",
                      subtitle: "Receber alertas sobre serviços",
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
                      subtitle: "Usar localização real no app",
                      value: localizacao,
                      onChanged: (value) {
                        setState(() {
                          localizacao = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: salvando ? null : salvarDados,
                    icon: salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(salvando ? "Salvando..." : "Salvar alterações"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _perfilResumo(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(
              AuthService.isPrestador ? Icons.work : Icons.person,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AuthService.nome.isEmpty ? "Usuário" : AuthService.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AuthService.email.isEmpty
                      ? "email@exemplo.com"
                      : AuthService.email,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _perfilProfissional() {
    return StreamBuilder<Prestador?>(
      stream: PrestadorService.observarPrestadorPorEmail(AuthService.email),
      builder: (context, snapshot) {
        final prestador = snapshot.data;
        final carregando = snapshot.connectionState == ConnectionState.waiting;

        return _painel(
          title: "Área do prestador",
          children: [
            _atalhoProfissional(
              icon: Icons.handyman,
              title: "Editar meu serviço",
              subtitle: prestador == null
                  ? "Categoria, preço, descrição e agenda"
                  : "${prestador.profissao} • ${prestador.categoria}",
              carregando: carregando,
              onTap: prestador == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditarPrestadorScreen(prestador: prestador),
                        ),
                      );
                    },
            ),
            const SizedBox(height: 10),
            _atalhoProfissional(
              icon: Icons.my_location,
              title: "Atualizar localização de atendimento",
              subtitle: prestador == null
                  ? "Use sua localização real no mapa"
                  : prestador.endereco,
              carregando: carregando || atualizandoLocalizacao,
              onTap: prestador == null || atualizandoLocalizacao
                  ? null
                  : () => atualizarLocalizacaoPrestador(prestador),
            ),
            const SizedBox(height: 10),
            _atalhoProfissional(
              icon: Icons.assignment,
              title: "Solicitações de serviço",
              subtitle: "Aceitar, recusar e justificar pedidos",
              carregando: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SolicitacoesPrestadorScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _atalhoProfissional({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool carregando,
    required VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primary.withOpacity(0.12),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (carregando)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _painel({
    required String title,
    required List<Widget> children,
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
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _campo({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _campoSenha({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: ocultarSenha,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              ocultarSenha = !ocultarSenha;
            });
          },
          icon: Icon(ocultarSenha ? Icons.visibility : Icons.visibility_off),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        value: value,
        activeColor: colorScheme.primary,
        onChanged: onChanged,
        secondary: Icon(icon, color: colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}



