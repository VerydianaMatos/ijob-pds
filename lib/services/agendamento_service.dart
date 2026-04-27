import '../models/agendamento_model.dart';

class AgendamentoService {
  static List<Agendamento> agendamentos = [];

  static void adicionar(Agendamento agendamento) {
    agendamentos.add(agendamento);
  }
}