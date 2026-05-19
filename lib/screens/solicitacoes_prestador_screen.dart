import 'package:flutter/material.dart';

class SolicitacoesPrestadorScreen extends StatefulWidget {
  const SolicitacoesPrestadorScreen({super.key});

  @override
  State<SolicitacoesPrestadorScreen> createState() =>
      _SolicitacoesPrestadorScreenState();
}

class _SolicitacoesPrestadorScreenState
    extends State<SolicitacoesPrestadorScreen> {
  final List<Map<String, String>> solicitacoes = [
    {
      "cliente": "João da Silva",
      "servico": "Instalação de tomada",
      "data": "Hoje às 14:00",
      "status": "Pendente",
    },
    {
      "cliente": "Mariana Costa",
      "servico": "Troca de disjuntor",
      "data": "Amanhã às 10:00",
      "status": "Pendente",
    },
  ];

  Color _statusColor(String status) {
    if (status == "Aceito") return Colors.green;
    if (status == "Recusado") return Colors.red;
    if (status == "Concluído") return Colors.blue;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Solicitações recebidas"),
        backgroundColor: const Color(0xFF1E6FD9),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: solicitacoes.length,
        itemBuilder: (context, index) {
          final item = solicitacoes[index];
          final status = item["status"]!;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFE3F0FF),
                      child: Icon(Icons.person, color: Color(0xFF1E6FD9)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item["cliente"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: _statusColor(status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(Icons.handyman, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(item["servico"]!),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.calendar_month,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(item["data"]!),
                  ],
                ),

                const SizedBox(height: 16),

                if (status == "Pendente")
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              item["status"] = "Recusado";
                            });
                          },
                          child: const Text("Recusar"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E6FD9),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              item["status"] = "Aceito";
                            });
                          },
                          child: const Text("Aceitar"),
                        ),
                      ),
                    ],
                  ),

                if (status == "Aceito")
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          item["status"] = "Concluído";
                        });
                      },
                      icon: const Icon(Icons.check),
                      label: const Text("Marcar como concluído"),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}