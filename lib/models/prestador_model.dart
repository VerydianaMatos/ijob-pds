class Prestador {
  final String nome;
  final String profissao;

  final String categoria;
  final List<String> categorias;

  final String distancia;

  final double rating;

  final bool disponivel;

  final String descricao;
  final String preco;
  final String resposta;
  final String servicos;

  final String fotoUrl;

  Prestador({
    required this.nome,
    required this.profissao,
    required this.categoria,
    required this.categorias,
    required this.distancia,
    required this.rating,
    required this.disponivel,
    required this.descricao,
    required this.preco,
    required this.resposta,
    required this.servicos,
    this.fotoUrl = "",
  });

  Map<String, dynamic> toMap() {
    return {
      "nome": nome,
      "profissao": profissao,
      "categoria": categoria,
      "categorias": categorias,
      "distancia": distancia,
      "rating": rating,
      "disponivel": disponivel,
      "descricao": descricao,
      "preco": preco,
      "resposta": resposta,
      "servicos": servicos,
      "fotoUrl": fotoUrl,
    };
  }

  factory Prestador.fromMap(Map<String, dynamic> map) {
    return Prestador(
      nome: map["nome"] ?? "",
      profissao: map["profissao"] ?? "",
      categoria: map["categoria"] ?? "",
      categorias: map["categorias"] != null
          ? List<String>.from(map["categorias"])
          : [],
      distancia: map["distancia"] ?? "",
      rating: (map["rating"] ?? 0).toDouble(),
      disponivel: map["disponivel"] ?? true,
      descricao: map["descricao"] ?? "",
      preco: map["preco"] ?? "",
      resposta: map["resposta"] ?? "",
      servicos: map["servicos"] ?? "",
      fotoUrl: map["fotoUrl"] ?? "",
    );
  }
}