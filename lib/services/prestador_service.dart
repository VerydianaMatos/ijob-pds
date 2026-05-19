import '../models/prestador_model.dart';

class PrestadorService {
  static List<Prestador> prestadores = [
    Prestador(
      nome: "Carlos Martins",
      profissao: "Eletricista",
      categoria: "Elétrica",
      distancia: "1.2 km",
      rating: 4.9,
      disponivel: true,
      descricao:
      "Profissional com 8 anos de experiência em instalações e reparos elétricos.",
      preco: "R\$ 80",
      resposta: "~10 min",
      servicos: "120+",
    ),
    Prestador(
      nome: "Ana Silva",
      profissao: "Faxineira",
      categoria: "Limpeza",
      distancia: "0.8 km",
      rating: 4.8,
      disponivel: true,
      descricao: "Especialista em limpeza residencial e comercial.",
      preco: "R\$ 60",
      resposta: "~5 min",
      servicos: "200+",
    ),
    Prestador(
      nome: "Roberto Prado",
      profissao: "Encanador",
      categoria: "Hidráulica",
      distancia: "2.1 km",
      rating: 4.7,
      disponivel: false,
      descricao: "Atendimento rápido para vazamentos e manutenção hidráulica.",
      preco: "R\$ 90",
      resposta: "~15 min",
      servicos: "95+",
    ),
    Prestador(
      nome: "Marcos Lima",
      profissao: "Pintor",
      categoria: "Pintura",
      distancia: "1.9 km",
      rating: 4.6,
      disponivel: true,
      descricao: "Pintura residencial e acabamento profissional.",
      preco: "R\$ 120",
      resposta: "~20 min",
      servicos: "80+",
    ),
  ];

  static void adicionarPrestador(Prestador prestador) {
    prestadores.add(prestador);
  }
}