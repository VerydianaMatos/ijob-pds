import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/prestador_model.dart';

class PrestadorService {
  static final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection("prestadores");
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static List<Prestador> prestadores = [
    Prestador(
      nome: "Carlos Martins",
      telefone: "51999990001",
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
      latitude: -29.7582,
      longitude: -50.0201,
      endereco: "Capão da Canoa - RS",
    ),
    Prestador(
      nome: "Ana Silva",
      telefone: "51999990002",
      profissao: "Faxineira",
      categoria: "Limpeza",
      distancia: "0.8 km",
      rating: 4.8,
      disponivel: true,
      descricao: "Especialista em limpeza residencial e comercial.",
      preco: "R\$ 60",
      resposta: "~5 min",
      servicos: "200+",
      latitude: -29.7526,
      longitude: -50.0154,
      endereco: "Capão da Canoa - RS",
    ),
    Prestador(
      nome: "Roberto Prado",
      telefone: "51999990003",
      profissao: "Encanador",
      categoria: "Hidráulica",
      distancia: "2.1 km",
      rating: 4.7,
      disponivel: false,
      descricao: "Atendimento rápido para vazamentos e manutenção hidráulica.",
      preco: "R\$ 90",
      resposta: "~15 min",
      servicos: "95+",
      latitude: -29.7683,
      longitude: -50.0277,
      endereco: "Capão da Canoa - RS",
    ),
    Prestador(
      nome: "Marcos Lima",
      telefone: "51999990004",
      profissao: "Pintor",
      categoria: "Pintura",
      distancia: "1.9 km",
      rating: 4.6,
      disponivel: true,
      descricao: "Pintura residencial e acabamento profissional.",
      preco: "R\$ 120",
      resposta: "~20 min",
      servicos: "80+",
      latitude: -29.7479,
      longitude: -50.0321,
      endereco: "Capão da Canoa - RS",
    ),
  ];

  static Stream<List<Prestador>> observarPrestadores() {
    return _collection.orderBy("nome").snapshots().map((snapshot) {
      final lista = snapshot.docs.map((doc) {
        return Prestador.fromMap(doc.data(), id: doc.id);
      }).toList();

      if (lista.isNotEmpty) {
        prestadores = lista;
      }

      return lista;
    });
  }

  static String _idPorEmail(String email) {
    return email.trim().toLowerCase().replaceAll(RegExp(r"[^a-z0-9._-]"), "_");
  }

  static Future<void> adicionarPrestador(Prestador prestador) async {
    final emailNormalizado = prestador.email.trim().toLowerCase();
    final dados = {
      ...prestador.toMap(),
      "email": emailNormalizado,
      "atualizadoEm": FieldValue.serverTimestamp(),
    };

    if (emailNormalizado.isEmpty) {
      await _collection.add({
        ...dados,
        "criadoEm": FieldValue.serverTimestamp(),
      });
    } else {
      await _collection.doc(_idPorEmail(emailNormalizado)).set({
        ...dados,
        "criadoEm": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    final index = prestadores.indexWhere(
      (item) => item.email.trim().toLowerCase() == emailNormalizado,
    );

    if (index >= 0) {
      prestadores[index] = prestador;
    } else {
      prestadores.add(prestador);
    }
  }

  static Future<Prestador?> buscarPrestadorPorEmail(String email) async {
    final emailNormalizado = email.trim().toLowerCase();
    if (emailNormalizado.isEmpty) return null;

    final docDireto = await _collection.doc(_idPorEmail(emailNormalizado)).get();

    if (docDireto.exists && docDireto.data() != null) {
      return Prestador.fromMap(docDireto.data()!, id: docDireto.id);
    }

    var resultado = await _collection
        .where("email", isEqualTo: emailNormalizado)
        .limit(1)
        .get();

    if (resultado.docs.isEmpty) {
      resultado = await _collection.limit(80).get();

      for (final doc in resultado.docs) {
        final dados = doc.data();
        final emailSalvo = (dados["email"] ?? "").toString().trim().toLowerCase();

        if (emailSalvo == emailNormalizado) {
          return Prestador.fromMap(dados, id: doc.id);
        }
      }

      return null;
    }

    final doc = resultado.docs.first;
    return Prestador.fromMap(doc.data(), id: doc.id);
  }

  static Stream<Prestador?> observarPrestadorPorEmail(String email) {
    final emailNormalizado = email.trim().toLowerCase();
    if (emailNormalizado.isEmpty) {
      return Stream.value(null);
    }

    return _collection.doc(_idPorEmail(emailNormalizado)).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Prestador.fromMap(doc.data()!, id: doc.id);
    });
  }

  static Future<void> atualizarPrestador(
    String id,
    Map<String, dynamic> dados,
  ) async {
    await _collection.doc(id).update(dados);
  }

  static Future<void> atualizarNotaPorNome(
    String nome,
    double rating,
    int totalAvaliacoes,
  ) async {
    final snapshot =
        await _collection.where("nome", isEqualTo: nome).limit(1).get();

    if (snapshot.docs.isEmpty) return;

    await snapshot.docs.first.reference.update({
      "rating": rating,
      "totalAvaliacoes": totalAvaliacoes,
    });
  }

  static Future<String> enviarFotoPrestador(
    String email,
    String caminhoLocal,
  ) async {
    if (caminhoLocal.isEmpty || caminhoLocal.startsWith("http")) {
      return caminhoLocal;
    }

    final arquivo = File(caminhoLocal);
    if (!arquivo.existsSync()) return caminhoLocal;

    final emailSeguro = email.trim().toLowerCase().replaceAll("/", "_");
    final ref = _storage.ref("prestadores/$emailSeguro/perfil.jpg");

    try {
      await ref.putFile(
        arquivo,
        SettableMetadata(contentType: "image/jpeg"),
      );

      return ref.getDownloadURL();
    } catch (_) {
      return caminhoLocal;
    }
  }
}



