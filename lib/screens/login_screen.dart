import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/notificacao_service.dart';
import '../services/prestador_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool ocultarSenha = true;
  bool carregandoCliente = false;
  bool carregandoPrestador = false;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> entrarCliente() async {
    final email = emailController.text.trim().toLowerCase();
    final senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      _mensagem("Informe e-mail e senha.", Colors.red);
      return;
    }

    setState(() => carregandoCliente = true);

    try {
      await AuthService.entrarCliente(emailUser: email, senha: senha);
      await _salvarTokenSemBloquearLogin();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (erro) {
      if (!mounted) return;
      setState(() => carregandoCliente = false);
      _mensagem(_mensagemErroAuth(erro), Colors.red);
    } catch (_) {
      if (!mounted) return;
      setState(() => carregandoCliente = false);
      _mensagem(
        "Não foi possível entrar agora. Verifique a internet e tente novamente.",
        Colors.red,
      );
    }
  }

  Future<void> entrarPrestador() async {
    final email = emailController.text.trim().toLowerCase();
    final senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      _mensagem("Informe e-mail e senha.", Colors.red);
      return;
    }

    setState(() => carregandoPrestador = true);

    try {
      await AuthService.entrarCliente(emailUser: email, senha: senha);

      final prestador = await PrestadorService.buscarPrestadorPorEmail(email);

      if (!mounted) return;

      if (prestador == null) {
        AuthService.logout();
        setState(() => carregandoPrestador = false);
        _mensagem(
          "Esse login existe, mas não há perfil de prestador para este e-mail.",
          Colors.red,
        );
        return;
      }

      AuthService.loginPrestador(
        prestador.nome,
        prestador.email.isEmpty ? email : prestador.email,
        prestador.endereco,
      );
      await _salvarTokenSemBloquearLogin();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (erro) {
      if (!mounted) return;
      setState(() => carregandoPrestador = false);
      _mensagem(_mensagemErroAuth(erro), Colors.red);
    } catch (_) {
      if (!mounted) return;
      setState(() => carregandoPrestador = false);
      _mensagem(
        "Não consegui confirmar o cadastro de prestador. Confira internet e Firestore.",
        Colors.red,
      );
    }
  }

  Future<void> _salvarTokenSemBloquearLogin() async {
    try {
      await NotificacaoService.salvarToken();
    } catch (_) {
      // Notificações não podem impedir login.
    }
  }

  Future<void> recuperarSenha() async {
    final email = emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      _mensagem("Digite seu e-mail para recuperar a senha.", Colors.red);
      return;
    }

    try {
      await AuthService.enviarRecuperacaoSenha(email);
      if (!mounted) return;
      _mensagem(
        "Enviamos um link de recuperacao para seu e-mail.",
        Colors.green,
      );
    } on FirebaseAuthException catch (erro) {
      if (!mounted) return;
      _mensagem(_mensagemErroAuth(erro), Colors.red);
    } catch (_) {
      if (!mounted) return;
      _mensagem("Não foi possível enviar o link agora.", Colors.red);
    }
  }

  String _mensagemErroAuth(FirebaseAuthException erro) {
    switch (erro.code) {
      case "invalid-email":
        return "E-mail inválido.";
      case "user-not-found":
        return "Esse e-mail ainda não tem cadastro.";
      case "wrong-password":
      case "invalid-credential":
        return "E-mail ou senha incorretos.";
      case "network-request-failed":
        return "Sem conexão com a internet.";
      case "too-many-requests":
        return "Muitas tentativas. Aguarde um pouco e tente novamente.";
      case "user-disabled":
        return "Essa conta foi desativada.";
      default:
        return "Não foi possível entrar. Verifique seus dados e tente novamente.";
    }
  }

  void _mensagem(String texto, Color cor) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(texto), backgroundColor: cor));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset("assets/imagens/logo.png"),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Entrar no IJob",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Acesse como cliente ou prestador usando seu e-mail cadastrado.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _painelLogin(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _painelLogin() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: senhaController,
            obscureText: ocultarSenha,
            decoration: InputDecoration(
              labelText: "Senha",
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => ocultarSenha = !ocultarSenha);
                },
                icon: Icon(
                  ocultarSenha ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: carregandoCliente || carregandoPrestador
                  ? null
                  : recuperarSenha,
              child: const Text("Esqueci minha senha"),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: carregandoCliente || carregandoPrestador
                ? null
                : entrarCliente,
            icon: carregandoCliente
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.person),
            label: Text(
              carregandoCliente ? "Entrando..." : "Entrar como cliente",
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: carregandoCliente || carregandoPrestador
                ? null
                : entrarPrestador,
            icon: carregandoPrestador
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.work),
            label: Text(
              carregandoPrestador
                  ? "Verificando cadastro..."
                  : "Entrar como prestador",
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Cliente agenda serviços. Prestador gerencia solicitações e agenda.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
