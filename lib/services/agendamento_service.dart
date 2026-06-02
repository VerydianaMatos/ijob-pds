import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agendamento_model.dart';

class AgendamentoService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static List<Agendamento> agendamentos = [];

  static Future<void> adicionar(
      Agendamento agendamento,
      ) async {
    agendamentos.add(agendamento);

    await _firestore
        .collection("agendamentos")
        .add(agendamento.toMap());
  }

  static Future<List<Agendamento>> carregarAgendamentos() async {
    final snapshot =
    await _firestore.collection("agendamentos").get();

    agendamentos = snapshot.docs.map((doc) {
      return Agendamento.fromMap(
        doc.data(),
        doc.id,
      );
    }).toList();

    return agendamentos;
  }

  static Future<void> concluirAgendamento(
      Agendamento agendamento,
      ) async {
    agendamento.concluido = true;

    if (agendamento.id.isNotEmpty) {
      await _firestore
          .collection("agendamentos")
          .doc(agendamento.id)
          .update({"concluido": true});
    }
  }
}