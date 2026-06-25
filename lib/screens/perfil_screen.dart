import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import 'cadastro_prestador_screen.dart';
import 'cadastro_screen.dart';
import 'configuracoes_screen.dart';
import 'favoritos_screen.dart';
import 'login_screen.dart';
import 'meus_servicos_screen.dart';
import 'painel_prestador_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ImagePicker imagePicker = ImagePicker();
  bool salvandoFoto = false;

  Future<void> escolherFoto(ImageSource origem) async {
    final imagem = await imagePicker.pickImage(
      source: origem,
      imageQuality: 78,
      maxWidth: 1200,
    );

    if (imagem == null || !mounted) return;

    setState(() {
      salvandoFoto = true;
      AuthService.fotoPath = imagem.path;
    });

    final fotoFinal = await AuthService.salvarFotoPerfil(imagem.path);

    if (!mounted) return;

    setState(() {
      AuthService.fotoPath = fotoFinal;
      salvandoFoto = false;
    });

    final mensagem = fotoFinal == imagem.path
        ? "Foto salva neste aparelho."
        : "Foto de perfil atualizada.";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  void abrirOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text("Tirar foto"),
                  onTap: () {
                    Navigator.pop(context);
                    escolherFoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Escolher da galeria"),
                  onTap: () {
                    Navigator.pop(context);
                    escolherFoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: AuthService.isLogged ? _perfilLogado() : _perfilDeslogado(),
    );
  }

  Widget _perfilDeslogado() {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.35),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: colorScheme.primary.withOpacity(0.12),
                  child: Icon(
                    Icons.person_outline,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Você ainda não está logado",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Entre ou crie uma conta para acessar serviços, favoritos e agendamentos.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ).then((_) => setState(() {}));
            },
            icon: const Icon(Icons.login),
            label: const Text("Entrar"),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CadastroScreen()),
              ).then((_) => setState(() {}));
            },
            icon: const Icon(Icons.person_add),
            label: const Text("Criar conta"),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CadastroPrestadorScreen(),
                ),
              ).then((_) => setState(() {}));
            },
            icon: const Icon(Icons.work),
            label: const Text("Seja um prestador"),
          ),
        ],
      ),
    );
  }

  Widget _perfilLogado() {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: salvandoFoto ? null : abrirOpcoesFoto,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.white,
                        backgroundImage: _fotoProvider(),
                        child: _fotoProvider() == null
                            ? Icon(
                                AuthService.isPrestador
                                    ? Icons.work
                                    : Icons.person,
                                size: 42,
                                color: colorScheme.primary,
                              )
                            : null,
                      ),
                      Container(
                        width: 31,
                        height: 31,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: salvandoFoto
                            ? Padding(
                                padding: const EdgeInsets.all(7),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                            : Icon(
                                Icons.photo_camera,
                                size: 17,
                                color: colorScheme.primary,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: salvandoFoto ? null : abrirOpcoesFoto,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text("Adicionar foto"),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  AuthService.nome.isEmpty ? "Usuário" : AuthService.nome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AuthService.email.isEmpty
                      ? "email@exemplo.com"
                      : AuthService.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                if (AuthService.telefone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    AuthService.telefone,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  AuthService.localizacao,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _opcao(
            icon: Icons.favorite,
            title: "Favoritos",
            subtitle: "Profissionais que você salvou",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritosScreen()),
              );
            },
          ),
          if (AuthService.isPrestador)
            _opcao(
              icon: Icons.dashboard,
              title: "Painel do prestador",
              subtitle: "Solicitações, agenda e atendimentos",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PainelPrestadorScreen(),
                  ),
                );
              },
            ),
          if (!AuthService.isPrestador)
            _opcao(
              icon: Icons.work,
              title: "Meus serviços",
              subtitle: "Agendamentos e histórico",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MeusServicosScreen()),
                );
              },
            ),
          _opcao(
            icon: Icons.settings,
            title: "Configurações",
            subtitle: "Conta, tema e preferências",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConfiguracoesScreen()),
              ).then((_) => setState(() {}));
            },
          ),
          _opcao(
            icon: Icons.logout,
            title: "Sair",
            subtitle: "Encerrar sessão neste aparelho",
            onTap: () {
              AuthService.logout();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _opcao({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.14 : 0.035,
            ),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  ImageProvider? _fotoProvider() {
    final foto = AuthService.fotoPath;
    if (foto.isEmpty) return null;

    if (foto.startsWith("http")) {
      return NetworkImage(foto);
    }

    final arquivo = File(foto);
    if (!arquivo.existsSync()) return null;

    return FileImage(arquivo);
  }
}



