import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/prestador_model.dart';

class AuthService {
  static bool isLogged = false;
  static bool isPrestador = false;

  static String nome = "";
  static String email = "";
  static String telefone = "";
  static String localizacao = "Localização não informada";
  static String fotoPath = "";

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static void loginCliente(
    String nomeUser,
    String emailUser, {
    String telefoneUser = "",
  }) {
    isLogged = true;
    isPrestador = false;
    nome = nomeUser;
    email = emailUser;
    telefone = telefoneUser.isEmpty ? telefone : telefoneUser;
    localizacao = "Localização não informada";
    fotoPath = _auth.currentUser?.photoURL ?? fotoPath;
  }

  static void loginPrestador(
    String nomeUser,
    String emailUser,
    String localizacaoUser,
  ) {
    isLogged = true;
    isPrestador = true;
    nome = nomeUser;
    email = emailUser;
    telefone = "";
    localizacao = localizacaoUser;
    fotoPath = _auth.currentUser?.photoURL ?? fotoPath;
  }

  static Future<void> cadastrarCliente({
    required String nomeUser,
    required String emailUser,
    String telefoneUser = "",
    required String senha,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: emailUser,
      password: senha,
    );

    await credencial.user?.updateDisplayName(nomeUser);
    loginCliente(nomeUser, emailUser, telefoneUser: telefoneUser);
  }

  static Future<void> entrarCliente({
    required String emailUser,
    required String senha,
  }) async {
    final credencial = await _auth.signInWithEmailAndPassword(
      email: emailUser,
      password: senha,
    );

    final nomeFirebase = credencial.user?.displayName;
    loginCliente(
      nomeFirebase == null || nomeFirebase.isEmpty
          ? emailUser.split("@").first
          : nomeFirebase,
      emailUser,
    );
  }

  static Future<void> enviarRecuperacaoSenha(String emailUser) async {
    await _auth.sendPasswordResetEmail(email: emailUser.trim().toLowerCase());
  }

  static Future<void> atualizarPerfilCliente({
    required String nomeUser,
    required String telefoneUser,
    required String localizacaoUser,
  }) async {
    final user = _auth.currentUser;

    await user?.updateDisplayName(nomeUser);

    nome = nomeUser;
    telefone = telefoneUser;
    localizacao = localizacaoUser.isEmpty
        ? "Localização não informada"
        : localizacaoUser;
  }

  static Future<void> alterarSenha(String novaSenha) async {
    await _auth.currentUser?.updatePassword(novaSenha);
  }

  static Future<void> cadastrarPrestador({
    required String nomeUser,
    required String emailUser,
    required String senha,
    required String localizacaoUser,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: emailUser,
      password: senha,
    );

    await credencial.user?.updateDisplayName(nomeUser);
    loginPrestador(nomeUser, emailUser, localizacaoUser);
  }

  static Future<void> entrarPrestador({
    required Prestador prestador,
    required String emailUser,
    required String senha,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: emailUser,
      password: senha,
    );

    loginPrestador(
      prestador.nome,
      prestador.email.isEmpty ? emailUser : prestador.email,
      prestador.endereco,
    );
  }

  static Future<String> salvarFotoPerfil(String caminhoLocal) async {
    if (caminhoLocal.isEmpty || caminhoLocal.startsWith("http")) {
      fotoPath = caminhoLocal;
      return caminhoLocal;
    }

    final arquivo = File(caminhoLocal);
    if (!arquivo.existsSync()) {
      fotoPath = caminhoLocal;
      return caminhoLocal;
    }

    final emailSeguro = email.trim().toLowerCase().replaceAll("/", "_");
    final ref = _storage.ref("clientes/$emailSeguro/perfil.jpg");

    try {
      await ref.putFile(
        arquivo,
        SettableMetadata(contentType: "image/jpeg"),
      );

      final url = await ref.getDownloadURL();
      await _auth.currentUser?.updatePhotoURL(url);
      fotoPath = url;
      return url;
    } catch (_) {
      fotoPath = caminhoLocal;
      return caminhoLocal;
    }
  }

  static void logout() {
    _auth.signOut();
    isLogged = false;
    isPrestador = false;
    nome = "";
    email = "";
    telefone = "";
    localizacao = "Localização não informada";
    fotoPath = "";
  }
}



