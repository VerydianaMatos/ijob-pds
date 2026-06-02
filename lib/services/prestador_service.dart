import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prestador_model.dart';

class PrestadorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<Prestador> prestadores = [];

  static Future<void> adicionarPrestador(Prestador prestador) async {
    prestadores.add(prestador);

    await _firestore.collection('prestadores').add({
      'nome': prestador.nome,
      'profissao': prestador.profissao,
      'categoria': prestador.categoria,
      'distancia': prestador.distancia,
      'rating': prestador.rating,
      'disponivel': prestador.disponivel,
      'descricao': prestador.descricao,
      'preco': prestador.preco,
      'resposta': prestador.resposta,
      'servicos': prestador.servicos,
      'fotoUrl': prestador.fotoUrl,
    });
  }

  static Future<List<Prestador>> carregarPrestadores() async {
    final snapshot = await _firestore.collection('prestadores').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return Prestador(
        nome: data['nome'] ?? '',
        profissao: data['profissao'] ?? '',
        categoria: data['categoria'] ?? '',
        distancia: data['distancia'] ?? '',
        rating: (data['rating'] ?? 0).toDouble(),
        disponivel: data['disponivel'] ?? true,
        descricao: data['descricao'] ?? '',
        preco: data['preco'] ?? '',
        resposta: data['resposta'] ?? '',
        servicos: data['servicos'] ?? '',
        fotoUrl: data['fotoUrl'] ?? '',
      );
    }).toList();
  }
}