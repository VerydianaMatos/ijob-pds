import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';

class FavoritoService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<Map<String, dynamic>> favoritos = [];

  static String get _uid {
    return AuthService.usuario?.uid ?? "visitante";
  }

  static bool isFavorito(String nome) {
    return favoritos.any((p) => p["nome"] == nome);
  }

  static Future<void> carregarFavoritos() async {
    favoritos.clear();

    final snapshot = await _firestore
        .collection("usuarios")
        .doc(_uid)
        .collection("favoritos")
        .get();

    favoritos.addAll(
      snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  static Future<void> alternarFavorito(
      Map<String, dynamic> prestador,
      ) async {
    final nome = prestador["nome"];

    if (isFavorito(nome)) {
      favoritos.removeWhere((p) => p["nome"] == nome);

      final snapshot = await _firestore
          .collection("usuarios")
          .doc(_uid)
          .collection("favoritos")
          .where("nome", isEqualTo: nome)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } else {
      favoritos.add(prestador);

      await _firestore
          .collection("usuarios")
          .doc(_uid)
          .collection("favoritos")
          .add(prestador);
    }
  }
}