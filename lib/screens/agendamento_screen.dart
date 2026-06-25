import 'package:flutter/material.dart';

import '../models/agendamento_model.dart';
import '../models/prestador_model.dart';
import '../services/agendamento_service.dart';
import '../services/auth_service.dart';

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
  bool enviando = false;
  final TextEditingController observacaoController = TextEditingController();

  @override
  void dispose() {
    observacaoController.dispose();
    super.dispose();
  }

  List<String> get horarios {
    final lista = widget.prestador.horariosAtendimento;
    if (lista.isEmpty) return [];
    return [...lista]..sort();
  }

  Future<void> selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _proximaDataDisponivel(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 120)),
      selectableDayPredicate: _diaDisponivel,
    );

    if (picked != null) {
      setState(() {
        dataSelecionada = picked;
        horarioSelecionado = null;
      });
    }
  }

  DateTime _proximaDataDisponivel() {
    final hoje = DateTime.now();

    for (var i = 0; i < 30; i++) {
      final data = hoje.add(Duration(days: i));
      if (_diaDisponivel(data)) return data;
    }

    return hoje;
  }

  bool _diaDisponivel(DateTime data) {
    return widget.prestador.diasAtendimento.contains(_nomeDia(data.weekday));
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

    if (!_diaDisponivel(dataSelecionada!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Este prestador não atende nesse dia."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final dataKey = _dataKey(dataSelecionada!);
    final ocupado = await AgendamentoService.horarioOcupado(
      nomePrestador: widget.prestador.nome,
      dataAtendimento: dataKey,
      horario: horarioSelecionado!,
    );

    if (ocupado) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Esse horário já foi solicitado. Escolha outro."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data =
        "${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year} às $horarioSelecionado";

    setState(() {
      enviando = true;
    });

    final salvo = await AgendamentoService.adicionar(
      Agendamento(
        nomePrestador: widget.prestador.nome,
        prestadorEmail: widget.prestador.email,
        nomeCliente: AuthService.nome.isEmpty ? "Cliente" : AuthService.nome,
        servico: widget.prestador.profissao,
        data: data,
        dataAtendimento: dataKey,
        horario: horarioSelecionado!,
        valorPrevisto: widget.prestador.preco,
        observacaoCliente: observacaoController.text.trim(),
      ),
    );

    if (!mounted) return;

    setState(() {
      enviando = false;
    });

    if (!salvo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Não foi possível salvar a solicitação no banco. Verifique sua conexão e tente novamente.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Solicitação enviada ao prestador."),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  String _dataKey(DateTime data) {
    final mes = data.month.toString().padLeft(2, "0");
    final dia = data.day.toString().padLeft(2, "0");
    return "${data.year}-$mes-$dia";
  }

  String get textoData {
    if (dataSelecionada == null) {
      return "Selecionar data";
    }

    return "${_nomeDia(dataSelecionada!.weekday)}, ${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year}";
  }

  String _nomeDia(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return "Segunda";
      case DateTime.tuesday:
        return "Terça";
      case DateTime.wednesday:
        return "Quarta";
      case DateTime.thursday:
        return "Quinta";
      case DateTime.friday:
        return "Sexta";
      case DateTime.saturday:
        return "Sábado";
      case DateTime.sunday:
      default:
        return "Domingo";
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Agendar serviço"),
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
                    _prestadorResumo(colorScheme),
                    const SizedBox(height: 18),
                    _agendaResumo(colorScheme),
                    const SizedBox(height: 22),
                    const Text(
                      "Escolha a data",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _seletorData(colorScheme),
                    const SizedBox(height: 28),
                    const Text(
                      "Escolha o horário",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _gradeHorarios(colorScheme),
                    const SizedBox(height: 22),
                    TextField(
                      controller: observacaoController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Observação para o prestador",
                        hintText: "Ex: detalhe do serviço, endereço ou referência",
                        prefixIcon: Icon(Icons.notes),
                        alignLabelWithHint: true,
                      ),
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
                  onPressed:
                      horarios.isEmpty || enviando ? null : confirmarAgendamento,
                  icon: const Icon(Icons.send),
                  label: Text(enviando ? "Enviando..." : "Enviar solicitação"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _agendaResumo(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_available, color: colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                "Agenda do prestador",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.prestador.diasAtendimento.join(", "),
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            horarios.isEmpty
                ? "Nenhum horário cadastrado."
                : "Horários: ${horarios.join(", ")}",
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _seletorData(ColorScheme colorScheme) {
    return InkWell(
      onTap: selecionarData,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: colorScheme.primary, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                textoData,
                style: TextStyle(
                  fontSize: 15,
                  color: dataSelecionada == null
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                  fontWeight: dataSelecionada == null
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _gradeHorarios(ColorScheme colorScheme) {
    if (horarios.isEmpty) {
      return Text(
        "Este prestador ainda não cadastrou horários.",
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: horarios.map((horario) {
        final selecionado = horarioSelecionado == horario;

        return GestureDetector(
          onTap: () {
            setState(() {
              horarioSelecionado = horario;
            });
          },
          child: Container(
            width: 92,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: selecionado ? colorScheme.primary : colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    selecionado ? colorScheme.primary : colorScheme.outlineVariant,
              ),
            ),
            child: Text(
              horario,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selecionado ? colorScheme.onPrimary : colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _prestadorResumo(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary.withOpacity(0.12),
            child: Icon(Icons.work, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.prestador.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.prestador.profissao,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            "Pendente",
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}



