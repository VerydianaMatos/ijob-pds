class FavoritoService {
  static final List<Map<String, dynamic>> favoritos = [];

  static bool isFavorito(String nome) {
    return favoritos.any((p) => p["nome"] == nome);
  }

  static void alternarFavorito(Map<String, dynamic> prestador) {
    if (isFavorito(prestador["nome"])) {
      favoritos.removeWhere((p) => p["nome"] == prestador["nome"]);
    } else {
      favoritos.add(prestador);
    }
  }
}


