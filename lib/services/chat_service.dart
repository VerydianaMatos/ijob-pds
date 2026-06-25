import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/mensagem_model.dart';

class ChatService {
  static final CollectionReference<Map<String, dynamic>> _colecao =
      FirebaseFirestore.instance.collection("mensagens");

  static String chatId(String nomeA, String nomeB) {
    final partes = [nomeA.trim(), nomeB.trim()]..sort();
    return partes.join("_").replaceAll(RegExp(r"\s+"), "-").toLowerCase();
  }

  static Stream<List<Mensagem>> mensagens(String chatId) {
    return _colecao.where("chatId", isEqualTo: chatId).snapshots().map(
      (snapshot) {
        final lista = snapshot.docs
            .map((doc) => Mensagem.fromMap(doc.data(), id: doc.id))
            .toList();
        lista.sort((a, b) => a.criadoEm.compareTo(b.criadoEm));
        return lista;
      },
    );
  }

  static Future<void> enviar(Mensagem mensagem) async {
    await _colecao.add(mensagem.toMap());
  }
}



