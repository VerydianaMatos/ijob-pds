import 'package:flutter/material.dart';
import '../models/agendamento_model.dart';
import '../models/prestador_model.dart';
import '../services/agendamento_service.dart';

class AgendamentoScreen extends StatefulWidget {
  final Prestador prestador;

  const AgendamentoScreen({
    super.key,
    required this.prestador,
  });

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  DateTime? dataSelecionada;
  String? horarioSelecionado;
  bool salvando = false;

  final List<String> horarios = [
    "08:00",
    "09:00",
    "10:00",
    "11:00",
    "14:00",
    "15:00",
    "16:00",
  ];

  Future<void> selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        dataSelecionada = picked;
      });
    }
  }

  Future<void> confirmarAgendamento() async {
    if (dataSelecionada == null || horarioSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Escolha uma data e um horário."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      salvando = true;
    });

    await AgendamentoService.adicionar(
      Agendamento(
        nomePrestador: widget.prestador.nome,
        servico: widget.prestador.profissao,
        data:
        "${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year} às $horarioSelecionado",
      ),
    );

    if (!mounted) return;

    setState(() {
      salvando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Agendamento confirmado com sucesso!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  String get textoData {
    if (dataSelecionada == null) return "Selecionar data";
    return "${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year}";
  }

  @override
  Widget build(BuildContext context) {
    final prestador = widget.prestador;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Agendar serviço"),
        backgroundColor: const Color(0xFF1E6FD9),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF1E6FD9),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    prestador.nome.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF1E6FD9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prestador.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      prestador.profissao,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Escolha a data",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: selecionarData,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: Color(0xFF1E6FD9),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(textoData)),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    "Escolha o horário",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: horarios.map((h) {
                      final selecionado = horarioSelecionado == h;

                      return ChoiceChip(
                        label: Text(h),
                        selected: selecionado,
                        selectedColor: const Color(0xFF1E6FD9),
                        labelStyle: TextStyle(
                          color: selecionado ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) {
                          setState(() {
                            horarioSelecionado = h;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E6FD9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: salvando ? null : confirmarAgendamento,
                icon: salvando
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.check),
                label: Text(salvando ? "Salvando..." : "Confirmar agendamento"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}