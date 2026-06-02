class Agendamento {
  final String id;
  final String nomePrestador;
  final String servico;
  final String data;
  bool concluido;

  Agendamento({
    this.id = "",
    required this.nomePrestador,
    required this.servico,
    required this.data,
    this.concluido = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "nomePrestador": nomePrestador,
      "servico": servico,
      "data": data,
      "concluido": concluido,
    };
  }

  factory Agendamento.fromMap(
      Map<String, dynamic> map,
      String id,
      ) {
    return Agendamento(
      id: id,
      nomePrestador: map["nomePrestador"] ?? "",
      servico: map["servico"] ?? "",
      data: map["data"] ?? "",
      concluido: map["concluido"] ?? false,
    );
  }
}