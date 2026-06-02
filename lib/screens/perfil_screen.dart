import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/favorito_service.dart';
import '../services/agendamento_service.dart';

import 'login_screen.dart';
import 'cadastro_screen.dart';
import 'cadastro_prestador_screen.dart';
import 'meus_servicos_screen.dart';
import 'painel_prestador_screen.dart';
import 'favoritos_screen.dart';
import 'configuracoes_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDadosPerfil();
  }

  Future<void> carregarDadosPerfil() async {
    setState(() {
      carregando = true;
    });

    await FavoritoService.carregarFavoritos();
    await AgendamentoService.carregarAgendamentos();

    if (!mounted) return;

    setState(() {
      carregando = false;
    });
  }

  String get nomeUsuario {
    if (AuthService.nome.isNotEmpty) return AuthService.nome;

    if (AuthService.usuario?.email != null) {
      return AuthService.usuario!.email!.split("@").first;
    }

    return "Usuário";
  }

  String get emailUsuario {
    if (AuthService.email.isNotEmpty) return AuthService.email;

    if (AuthService.usuario?.email != null) {
      return AuthService.usuario!.email!;
    }

    return "email@exemplo.com";
  }

  Future<void> sair() async {
    await AuthService.logout();

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Você saiu da conta."),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logado = AuthService.isLogged;

    if (carregando) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1E6FD9),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: carregarDadosPerfil,
          child: logado ? _perfilLogado(context) : _perfilDeslogado(context),
        ),
      ),
    );
  }

  Widget _perfilDeslogado(BuildContext context) {
    return ListView(
      children: [
        _topoDeslogado(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(20),
          child: _card(
            child: Column(
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 70,
                  color: Color(0xFF1E6FD9),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Você ainda não está logado",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Entre ou crie uma conta para acessar seus serviços, favoritos e agendamentos.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                      carregarDadosPerfil();
                    },
                    icon: const Icon(Icons.login),
                    label: const Text("Entrar"),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CadastroScreen(),
                        ),
                      );
                      carregarDadosPerfil();
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text("Criar conta"),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CadastroPrestadorScreen(),
                        ),
                      );
                      carregarDadosPerfil();
                    },
                    icon: const Icon(Icons.work),
                    label: const Text("Seja um prestador"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _perfilLogado(BuildContext context) {
    final totalFavoritos = FavoritoService.favoritos.length;
    final totalAgendamentos = AgendamentoService.agendamentos.length;
    final totalConcluidos =
        AgendamentoService.agendamentos.where((a) => a.concluido).length;

    return ListView(
      children: [
        _topoLogado(),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _resumoCard(
                  icon: Icons.favorite,
                  valor: totalFavoritos.toString(),
                  label: "Favoritos",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _resumoCard(
                  icon: Icons.calendar_month,
                  valor: totalAgendamentos.toString(),
                  label: "Serviços",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _resumoCard(
                  icon: Icons.check_circle,
                  valor: totalConcluidos.toString(),
                  label: "Concluídos",
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _opcao(
                icon: Icons.favorite,
                title: "Favoritos",
                subtitle: "Veja seus profissionais salvos",
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FavoritosScreen(),
                    ),
                  );
                  carregarDadosPerfil();
                },
              ),
              if (AuthService.isPrestador)
                _opcao(
                  icon: Icons.dashboard,
                  title: "Painel do prestador",
                  subtitle: "Gerencie seus serviços e atendimentos",
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
                  subtitle: "Acompanhe seus agendamentos",
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MeusServicosScreen(),
                      ),
                    );
                    carregarDadosPerfil();
                  },
                ),
              _opcao(
                icon: Icons.settings,
                title: "Configurações",
                subtitle: "Preferências da sua conta",
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConfiguracoesScreen(),
                    ),
                  );
                  carregarDadosPerfil();
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: sair,
                  icon: const Icon(Icons.logout),
                  label: const Text("Sair da conta"),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _topoDeslogado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E6FD9),
            Color(0xFF3D8BFF),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person_outline,
              size: 45,
              color: Color(0xFF1E6FD9),
            ),
          ),
          SizedBox(height: 14),
          Text(
            "Meu perfil",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 23,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Entre para acessar sua conta",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _topoLogado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E6FD9),
            Color(0xFF3D8BFF),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white,
            child: Icon(
              AuthService.isPrestador ? Icons.work : Icons.person,
              size: 44,
              color: const Color(0xFF1E6FD9),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            nomeUsuario,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            emailUsuario,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 4),
              Text(
                AuthService.localizacao,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Text(
              AuthService.isPrestador ? "Conta prestador" : "Conta cliente",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumoCard({
    required IconData icon,
    required String valor,
    required String label,
  }) {
    return _card(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF1E6FD9),
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: _card(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
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
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(24),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: padding,
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
}