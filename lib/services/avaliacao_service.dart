import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/avaliacao_model.dart';
import 'prestador_service.dart';

class AvaliacaoService {
  static final CollectionReference<Map<String, dynamic>> _colecao =
      FirebaseFirestore.instance.collection("avaliacoes");

  static Future<void> adicionar(Avaliacao avaliacao) async {
    await _colecao.add(avaliacao.toMap());
    await atualizarNotaDoPrestador(avaliacao.nomePrestador);
  }

  static Stream<List<Avaliacao>> porPrestador(String nomePrestador) {
    return _colecao
        .where("nomePrestador", isEqualTo: nomePrestador)
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs
          .map((doc) => Avaliacao.fromMap(doc.data(), id: doc.id))
          .toList();
      lista.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
      return lista;
    });
  }

  static Future<void> atualizarNotaDoPrestador(String nomePrestador) async {
    final snapshot =
        await _colecao.where("nomePrestador", isEqualTo: nomePrestador).get();

    if (snapshot.docs.isEmpty) return;

    final avaliacoes = snapshot.docs
        .map((doc) => Avaliacao.fromMap(doc.data(), id: doc.id))
        .toList();

    final media = avaliacoes
            .map((item) => item.estrelas)
            .reduce((valor, item) => valor + item) /
        avaliacoes.length;

    await PrestadorService.atualizarNotaPorNome(
      nomePrestador,
      double.parse(media.toStringAsFixed(1)),
      avaliacoes.length,
    );
  }
}



