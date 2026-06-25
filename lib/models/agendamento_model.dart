enum StatusAgendamento {
  pendente,
  aceito,
  emAtendimento,
  recusado,
  concluido,
}

class Agendamento {
  String? id;
  final String nomePrestador;
  final String prestadorEmail;
  final String nomeCliente;
  final String servico;
  final String data;
  final String dataAtendimento;
  final String horario;
  final String valorPrevisto;
  final String observacaoCliente;
  String justificativaPrestador;
  StatusAgendamento status;

  Agendamento({
    this.id,
    required this.nomePrestador,
    this.prestadorEmail = "",
    required this.nomeCliente,
    required this.servico,
    required this.data,
    this.dataAtendimento = "",
    this.horario = "",
    this.valorPrevisto = "",
    this.observacaoCliente = "",
    this.justificativaPrestador = "",
    this.status = StatusAgendamento.pendente,
  });

  bool get concluido => status == StatusAgendamento.concluido;
  bool get pendente => status == StatusAgendamento.pendente;
  bool get aceito => status == StatusAgendamento.aceito;
  bool get emAtendimento => status == StatusAgendamento.emAtendimento;
  bool get recusado => status == StatusAgendamento.recusado;

  String get statusKey {
    switch (status) {
      case StatusAgendamento.pendente:
        return "pendente";
      case StatusAgendamento.aceito:
        return "aceito";
      case StatusAgendamento.emAtendimento:
        return "em_atendimento";
      case StatusAgendamento.recusado:
        return "recusado";
      case StatusAgendamento.concluido:
        return "concluido";
    }
  }

  String get statusTexto {
    switch (status) {
      case StatusAgendamento.pendente:
        return "Pendente";
      case StatusAgendamento.aceito:
        return "Aceito";
      case StatusAgendamento.emAtendimento:
        return "Em atendimento";
      case StatusAgendamento.recusado:
        return "Recusado";
      case StatusAgendamento.concluido:
        return "Concluído";
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "nomePrestador": nomePrestador,
      "prestadorEmail": prestadorEmail,
      "nomeCliente": nomeCliente,
      "servico": servico,
      "data": data,
      "dataAtendimento": dataAtendimento,
      "horario": horario,
      "valorPrevisto": valorPrevisto,
      "observacaoCliente": observacaoCliente,
      "justificativaPrestador": justificativaPrestador,
      "status": statusKey,
      "criadoEm": DateTime.now().toIso8601String(),
    };
  }

  factory Agendamento.fromMap(Map<String, dynamic> map, {String? id}) {
    return Agendamento(
      id: id,
      nomePrestador: map["nomePrestador"] ?? "",
      prestadorEmail: map["prestadorEmail"] ?? "",
      nomeCliente: map["nomeCliente"] ?? "",
      servico: map["servico"] ?? "",
      data: map["data"] ?? "",
      dataAtendimento: map["dataAtendimento"] ?? "",
      horario: map["horario"] ?? "",
      valorPrevisto: map["valorPrevisto"] ?? "",
      observacaoCliente: map["observacaoCliente"] ?? "",
      justificativaPrestador: map["justificativaPrestador"] ?? "",
      status: statusFromKey(map["status"]),
    );
  }

  static StatusAgendamento statusFromKey(dynamic value) {
    switch (value) {
      case "aceito":
        return StatusAgendamento.aceito;
      case "em_atendimento":
        return StatusAgendamento.emAtendimento;
      case "recusado":
        return StatusAgendamento.recusado;
      case "concluido":
        return StatusAgendamento.concluido;
      case "pendente":
      default:
        return StatusAgendamento.pendente;
    }
  }
}



