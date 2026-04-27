class Agendamento {
  final String nomePrestador;
  final String servico;
  final String data;
  bool concluido;

  Agendamento({
    required this.nomePrestador,
    required this.servico,
    required this.data,
    this.concluido = false,
  });
}