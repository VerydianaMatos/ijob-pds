import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/prestador_model.dart';

class PrestadorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<Prestador> prestadores = [];

  static Future<void> adicionarPrestador(Prestador prestador) async {
    prestadores.add(prestador);

    await _firestore.collection('prestadores').add(prestador.toMap());
  }

  static Future<List<Prestador>> carregarPrestadores() async {
    final snapshot = await _firestore.collection('prestadores').get();

    final lista = snapshot.docs.map((doc) {
      return Prestador.fromMap(doc.data());
    }).toList();

    prestadores.clear();
    prestadores.addAll(lista);

    return lista;
  }
}