import 'package:flutter/material.dart';
import '../models/agendamento_model.dart';
import '../services/agendamento_service.dart';

class AgendamentoScreen extends StatefulWidget {
  const AgendamentoScreen({super.key});

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  int selectedDay = 1;
  String selectedHour = "";

  final List<String> dias = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"];
  final List<int> datas = [12, 13, 14, 15, 16, 17];

  final List<String> horarios = [
    "08:00",
    "10:00",
    "14:00",
    "16:00",
    "18:00"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Agendar serviço"),
        backgroundColor: const Color(0xFF1E6FD9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Escolha a data",
                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dias.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedDay == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = index;
                      });
                    },
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E6FD9)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dias[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            datas[index].toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text("Horários disponíveis",
                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: horarios.map((hora) {
                final isSelected = selectedHour == hora;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedHour = hora;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E6FD9)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      hora,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E6FD9),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: selectedHour.isEmpty
                    ? null
                    : () {
                  AgendamentoService.adicionar(
                    Agendamento(
                      nomePrestador: "Carlos Martins",
                      servico: "Eletricista",
                      data:
                      "${dias[selectedDay]}, ${datas[selectedDay]} às $selectedHour",
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Agendamento realizado!"),
                    ),
                  );

                  Navigator.pop(context);
                },
                child: const Text("Confirmar agendamento"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}