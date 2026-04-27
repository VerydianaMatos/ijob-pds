import 'package:flutter/material.dart';
import 'painel_prestador_screen.dart';

class CadastroPrestadorScreen extends StatelessWidget {
  const CadastroPrestadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categorias = [
      "Elétrica",
      "Hidráulica",
      "Limpeza",
      "Pintura",
      "Frete",
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Seja um prestador"),
        backgroundColor: const Color(0xFF1E6FD9),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F0FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(Icons.work, size: 60, color: Color(0xFF1E6FD9)),
                  SizedBox(height: 10),
                  Text(
                    "Cadastre seu serviço",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Receba pedidos de clientes próximos a você.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _campo("Nome completo", Icons.person),
            const SizedBox(height: 12),
            _campo("Email", Icons.email),
            const SizedBox(height: 12),
            _campo("Telefone", Icons.phone),
            const SizedBox(height: 12),
            _campo("Cidade", Icons.location_on),
            const SizedBox(height: 12),
            _campo("Profissão / Serviço", Icons.handyman),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Categoria",
                prefixIcon: const Icon(Icons.category),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: categorias.map((categoria) {
                return DropdownMenuItem(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
              onChanged: (value) {},
            ),

            const SizedBox(height: 12),

            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Descrição dos serviços",
                prefixIcon: const Icon(Icons.description),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 22),

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
                    const SnackBar(
                      content: Text("Cadastro de prestador criado!"),
                    ),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PainelPrestadorScreen(),
                    ),
                  );
                },
                child: const Text("Cadastrar como prestador"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(String label, IconData icon) {
    return TextField(
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