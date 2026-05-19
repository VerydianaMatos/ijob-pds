import 'package:flutter/material.dart';
import '../models/agendamento_model.dart';
import '../services/agendamento_service.dart';

class AgendamentoScreen extends StatefulWidget {
  const AgendamentoScreen({super.key});

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  DateTime? dataSelecionada;
  String? horarioSelecionado;

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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1E6FD9),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E6FD9),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dataSelecionada = picked;
      });
    }
  }

  void confirmarAgendamento() {
    if (dataSelecionada == null || horarioSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Escolha uma data e um horário."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    AgendamentoService.adicionar(
      Agendamento(
        nomePrestador: "Carlos Martins",
        servico: "Serviço agendado",
        data:
        "${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year} às $horarioSelecionado",
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Agendamento confirmado com sucesso!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  String get textoData {
    if (dataSelecionada == null) {
      return "Selecionar data";
    }

    return "${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E6FD9),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Agendar serviço",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Escolha a data",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    const SizedBox(height: 12),

                    InkWell(
                      onTap: selecionarData,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: Color(0xFF1E6FD9),
                              size: 28,
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Text(
                                textoData,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: dataSelecionada == null
                                      ? Colors.grey[700]
                                      : Colors.black,
                                  fontWeight: dataSelecionada == null
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                            ),

                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Color(0xFF1E6FD9),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Escolha o horário",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: horarios.map((horario) {
                        final selecionado =
                            horarioSelecionado == horario;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              horarioSelecionado = horario;
                            });
                          },
                          child: Container(
                            width: 92,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: selecionado
                                  ? const Color(0xFF1E6FD9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selecionado
                                    ? const Color(0xFF1E6FD9)
                                    : const Color(0xFFBFD6F6),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.025),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              horario,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selecionado
                                    ? Colors.white
                                    : const Color(0xFF1E6FD9),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E6FD9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: confirmarAgendamento,
                  icon: const Icon(Icons.calendar_month),
                  label: const Text(
                    "Confirmar agendamento",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}