import 'package:flutter/material.dart';
import 'home_screen.dart';

class CadastroScreen extends StatelessWidget {
  const CadastroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Criar conta"),
        backgroundColor: const Color(0xFF1E6FD9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 70, color: Color(0xFF1E6FD9)),
            const SizedBox(height: 12),
            const Text(
              "Cadastro de cliente",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),

            _campo("Nome completo", Icons.person),
            const SizedBox(height: 12),
            _campo("Email", Icons.email),
            const SizedBox(height: 12),
            _campo("Telefone", Icons.phone),
            const SizedBox(height: 12),
            _campo("Senha", Icons.lock, senha: true),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E6FD9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Conta criada com sucesso!")),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: const Text("Cadastrar cliente"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(String label, IconData icon, {bool senha = false}) {
    return TextField(
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
}