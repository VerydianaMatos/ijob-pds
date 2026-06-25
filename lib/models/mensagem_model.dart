class Mensagem {
  final String? id;
  final String chatId;
  final String texto;
  final String autor;
  final DateTime criadoEm;

  Mensagem({
    this.id,
    required this.chatId,
    required this.texto,
    required this.autor,
    required this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      "chatId": chatId,
      "texto": texto,
      "autor": autor,
      "criadoEm": criadoEm.toIso8601String(),
    };
  }

  factory Mensagem.fromMap(Map<String, dynamic> map, {String? id}) {
    return Mensagem(
      id: id,
      chatId: map["chatId"] ?? "",
      texto: map["texto"] ?? "",
      autor: map["autor"] ?? "",
      criadoEm: DateTime.tryParse(map["criadoEm"] ?? "") ?? DateTime.now(),
    );
  }
}



