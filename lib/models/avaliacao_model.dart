class Avaliacao {
  final String? id;
  final String nomePrestador;
  final String nomeCliente;
  final String servico;
  final int estrelas;
  final String comentario;
  final List<String> tags;
  final DateTime criadoEm;

  Avaliacao({
    this.id,
    required this.nomePrestador,
    required this.nomeCliente,
    required this.servico,
    required this.estrelas,
    required this.comentario,
    required this.tags,
    required this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      "nomePrestador": nomePrestador,
      "nomeCliente": nomeCliente,
      "servico": servico,
      "estrelas": estrelas,
      "comentario": comentario,
      "tags": tags,
      "criadoEm": criadoEm.toIso8601String(),
    };
  }

  factory Avaliacao.fromMap(Map<String, dynamic> map, {String? id}) {
    return Avaliacao(
      id: id,
      nomePrestador: map["nomePrestador"] ?? "",
      nomeCliente: map["nomeCliente"] ?? "",
      servico: map["servico"] ?? "",
      estrelas: map["estrelas"] ?? 0,
      comentario: map["comentario"] ?? "",
      tags: List<String>.from(map["tags"] ?? []),
      criadoEm: DateTime.tryParse(map["criadoEm"] ?? "") ?? DateTime.now(),
    );
  }
}



