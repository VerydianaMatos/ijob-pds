class Prestador {
  final String? id;
  final String nome;
  final String email;
  final String telefone;
  final String profissao;
  final String categoria;
  final String distancia;
  final double rating;
  final bool disponivel;
  final String descricao;
  final String preco;
  final String resposta;
  final String servicos;
  final double latitude;
  final double longitude;
  final String endereco;
  final String fotoPath;
  final int idade;
  final List<String> fotosServicos;
  final List<String> frasesPerfil;
  final double raioAtendimentoKm;
  final List<String> diasAtendimento;
  final List<String> horariosAtendimento;

  Prestador({
    this.id,
    required this.nome,
    this.email = "",
    this.telefone = "",
    required this.profissao,
    required this.categoria,
    required this.distancia,
    required this.rating,
    required this.disponivel,
    required this.descricao,
    required this.preco,
    required this.resposta,
    required this.servicos,
    required this.latitude,
    required this.longitude,
    this.endereco = "Capão da Canoa - RS",
    this.fotoPath = "",
    this.idade = 0,
    this.fotosServicos = const [],
    this.frasesPerfil = const [],
    this.raioAtendimentoKm = 10,
    this.diasAtendimento = const [
      "Segunda",
      "Terça",
      "Quarta",
      "Quinta",
      "Sexta",
    ],
    this.horariosAtendimento = const [
      "08:00",
      "09:00",
      "10:00",
      "11:00",
      "14:00",
      "15:00",
      "16:00",
    ],
  });

  factory Prestador.fromMap(Map<String, dynamic> data, {String? id}) {
    return Prestador(
      id: id,
      nome: data["nome"] ?? "",
      email: data["email"] ?? "",
      telefone: data["telefone"] ?? data["whatsapp"] ?? "",
      profissao: data["profissao"] ?? "",
      categoria: data["categoria"] ?? "Serviço geral",
      distancia: data["distancia"] ?? "0.5 km",
      rating: (data["rating"] ?? 5.0).toDouble(),
      disponivel: data["disponivel"] ?? true,
      descricao: data["descricao"] ?? "",
      preco: data["preco"] ?? "A combinar",
      resposta: data["resposta"] ?? "~10 min",
      servicos: data["servicos"] ?? "Novo",
      latitude: (data["latitude"] ?? -29.7604).toDouble(),
      longitude: (data["longitude"] ?? -50.0280).toDouble(),
      endereco: data["endereco"] ?? data["localizacao"] ?? "Capão da Canoa - RS",
      fotoPath: data["fotoPath"] ?? data["fotoUrl"] ?? "",
      idade: (data["idade"] ?? 0).toInt(),
      fotosServicos: List<String>.from(data["fotosServicos"] ?? []),
      frasesPerfil: List<String>.from(data["frasesPerfil"] ?? []),
      raioAtendimentoKm: (data["raioAtendimentoKm"] ?? 10).toDouble(),
      diasAtendimento: List<String>.from(
        data["diasAtendimento"] ??
            ["Segunda", "Terça", "Quarta", "Quinta", "Sexta"],
      ),
      horariosAtendimento: List<String>.from(
        data["horariosAtendimento"] ??
            ["08:00", "09:00", "10:00", "11:00", "14:00", "15:00", "16:00"],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "nome": nome,
      "email": email,
      "telefone": telefone,
      "profissao": profissao,
      "categoria": categoria,
      "distancia": distancia,
      "rating": rating,
      "disponivel": disponivel,
      "descricao": descricao,
      "preco": preco,
      "resposta": resposta,
      "servicos": servicos,
      "latitude": latitude,
      "longitude": longitude,
      "endereco": endereco,
      "fotoPath": fotoPath,
      "idade": idade,
      "fotosServicos": fotosServicos,
      "frasesPerfil": frasesPerfil,
      "raioAtendimentoKm": raioAtendimentoKm,
      "diasAtendimento": diasAtendimento,
      "horariosAtendimento": horariosAtendimento,
    };
  }
}



