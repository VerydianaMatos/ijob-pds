import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/agendamento_model.dart';

class AgendamentoService {
  static final CollectionReference<Map<String, dynamic>> _colecao =
      FirebaseFirestore.instance.collection("agendamentos");

  static final List<Agendamento> agendamentos = [];

  static Future<bool> adicionar(Agendamento agendamento) async {
    final salvo = await _salvarNoBanco(agendamento);
    if (!salvo) return false;

    agendamentos.add(agendamento);
    return true;
  }

  static Future<bool> horarioOcupado({
    required String nomePrestador,
    required String dataAtendimento,
    required String horario,
  }) async {
    final localOcupado = agendamentos.any((item) {
      return item.nomePrestador == nomePrestador &&
          item.dataAtendimento == dataAtendimento &&
          item.horario == horario &&
          !item.recusado;
    });

    if (localOcupado) return true;

    try {
      final snapshot = await _colecao
          .where("nomePrestador", isEqualTo: nomePrestador)
          .where("dataAtendimento", isEqualTo: dataAtendimento)
          .where("horario", isEqualTo: horario)
          .get();

      return snapshot.docs.any((doc) {
        final agendamento = Agendamento.fromMap(doc.data(), id: doc.id);
        return !agendamento.recusado;
      });
    } catch (_) {
      return false;
      return false;
    }
  }

  static List<Agendamento> porPrestador(String nomePrestador) {
    return agendamentos
        .where((item) => item.nomePrestador == nomePrestador)
        .toList();
  }

  static List<Agendamento> porPrestadorConta({
    required String nomePrestador,
    required String emailPrestador,
  }) {
    final nomeNormalizado = _normalizar(nomePrestador);
    final emailNormalizado = emailPrestador.trim().toLowerCase();

    return agendamentos.where((item) {
      final itemNome = _normalizar(item.nomePrestador);
      final itemEmail = item.prestadorEmail.trim().toLowerCase();

      return (nomeNormalizado.isNotEmpty && _nomesParecidos(itemNome, nomeNormalizado)) ||
          (emailNormalizado.isNotEmpty && itemEmail == emailNormalizado);
    }).toList();
  }

  static List<Agendamento> porCliente(String nomeCliente) {
    return agendamentos
        .where((item) => item.nomeCliente == nomeCliente)
        .toList();
  }

  static int pendentesDoPrestador(String nomePrestador) {
    return porPrestador(nomePrestador).where((item) => item.pendente).length;
  }

  static Future<bool> aceitar(
    Agendamento agendamento, {
    String justificativa = "",
  }) async {
    final statusAnterior = agendamento.status;
    final justificativaAnterior = agendamento.justificativaPrestador;

    agendamento.status = StatusAgendamento.aceito;
    agendamento.justificativaPrestador = justificativa.trim();
    final atualizado = await _atualizarStatusNoBanco(agendamento);

    if (!atualizado) {
      agendamento.status = statusAnterior;
      agendamento.justificativaPrestador = justificativaAnterior;
    }

    return atualizado;
  }

  static Future<bool> recusar(
    Agendamento agendamento, {
    String justificativa = "",
  }) async {
    final statusAnterior = agendamento.status;
    final justificativaAnterior = agendamento.justificativaPrestador;

    agendamento.status = StatusAgendamento.recusado;
    agendamento.justificativaPrestador = justificativa.trim();
    final atualizado = await _atualizarStatusNoBanco(agendamento);

    if (!atualizado) {
      agendamento.status = statusAnterior;
      agendamento.justificativaPrestador = justificativaAnterior;
    }

    return atualizado;
  }

  static Future<bool> concluir(Agendamento agendamento) async {
    final statusAnterior = agendamento.status;

    agendamento.status = StatusAgendamento.concluido;
    final atualizado = await _atualizarStatusNoBanco(agendamento);

    if (!atualizado) {
      agendamento.status = statusAnterior;
    }

    return atualizado;
  }

  static Future<bool> iniciarAtendimento(Agendamento agendamento) async {
    final statusAnterior = agendamento.status;

    agendamento.status = StatusAgendamento.emAtendimento;
    final atualizado = await _atualizarStatusNoBanco(agendamento);

    if (!atualizado) {
      agendamento.status = statusAnterior;
    }

    return atualizado;
  }

  static Stream<List<Agendamento>> streamPorPrestador(String nomePrestador) {
    return _colecao
        .where("nomePrestador", isEqualTo: nomePrestador)
        .snapshots()
        .map(_converterSnapshot);
  }

  static Stream<List<Agendamento>> streamPorPrestadorConta({
    required String nomePrestador,
    required String emailPrestador,
  }) {
    final nomeNormalizado = _normalizar(nomePrestador);
    final emailNormalizado = emailPrestador.trim().toLowerCase();

    return _colecao.snapshots().map(_converterSnapshot).map((lista) {
      return lista.where((item) {
        final itemNome = _normalizar(item.nomePrestador);
        final itemEmail = item.prestadorEmail.trim().toLowerCase();

        return (nomeNormalizado.isNotEmpty && _nomesParecidos(itemNome, nomeNormalizado)) ||
            (emailNormalizado.isNotEmpty && itemEmail == emailNormalizado);
      }).toList();
    });
  }

  static Stream<List<Agendamento>> streamProximosDoPrestador(
    String nomePrestador,
  ) {
    return streamPorPrestador(nomePrestador).map((lista) {
      final ativos = lista
          .where((item) => item.pendente || item.aceito || item.emAtendimento)
          .toList();
      ativos.sort((a, b) => a.data.compareTo(b.data));
      return ativos;
    });
  }

  static Stream<List<Agendamento>> streamPorCliente(String nomeCliente) {
    return _colecao
        .where("nomeCliente", isEqualTo: nomeCliente)
        .snapshots()
        .map(_converterSnapshot);
  }

  static List<Agendamento> _converterSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final lista = snapshot.docs
        .map((doc) => Agendamento.fromMap(doc.data(), id: doc.id))
        .toList();

    for (final agendamento in lista) {
      final index = agendamentos.indexWhere((item) => item.id == agendamento.id);
      if (index >= 0) {
        agendamentos[index] = agendamento;
      } else {
        agendamentos.add(agendamento);
      }
    }

    return lista;
  }

  static Future<bool> _salvarNoBanco(Agendamento agendamento) async {
    try {
      final doc = await _colecao.add(agendamento.toMap());
      agendamento.id = doc.id;
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _atualizarStatusNoBanco(Agendamento agendamento) async {
    final id = agendamento.id;
    if (id == null || id.isEmpty) return false;

    try {
      await _colecao.doc(id).update({
        "status": agendamento.statusKey,
        "justificativaPrestador": agendamento.justificativaPrestador,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool _nomesParecidos(String a, String b) {
    if (a == b) return true;
    if (a.isEmpty || b.isEmpty) return false;
    return a.contains(b) || b.contains(a);
  }

  static String _normalizar(String texto) {
    return texto
        .trim()
        .toLowerCase()
        .replaceAll("á", "a")
        .replaceAll("à", "a")
        .replaceAll("ã", "a")
        .replaceAll("â", "a")
        .replaceAll("é", "e")
        .replaceAll("ê", "e")
        .replaceAll("í", "i")
        .replaceAll("ó", "o")
        .replaceAll("õ", "o")
        .replaceAll("ô", "o")
        .replaceAll("ú", "u")
        .replaceAll("ç", "c")
        .replaceAll(RegExp(r"\s+"), " ");
  }
}



