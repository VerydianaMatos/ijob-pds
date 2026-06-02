import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static bool isPrestador = false;

  static String nome = "";
  static String email = "";
  static String localizacao = "Capão da Canoa - RS";

  static User? get usuario => _auth.currentUser;

  static bool get isLogged => usuario != null;

  static Future<String?> cadastrarCliente({
    required String nomeUser,
    required String emailUser,
    required String senha,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailUser,
        password: senha,
      );

      isPrestador = false;
      nome = nomeUser;
      email = emailUser;
      localizacao = "Capão da Canoa - RS";

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Erro ao cadastrar cliente.";
    } catch (e) {
      return "Erro ao cadastrar cliente.";
    }
  }

  static Future<String?> loginCliente({
    required String emailUser,
    required String senha,
  }) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: emailUser,
        password: senha,
      );

      isPrestador = false;
      email = credencial.user?.email ?? emailUser;
      nome = email.split("@").first;
      localizacao = "Capão da Canoa - RS";

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Erro ao fazer login.";
    } catch (e) {
      return "Erro ao fazer login.";
    }
  }

  static Future<String?> loginPrestador(
      String nomeUser,
      String emailUser,
      String localizacaoUser,
      ) async {
    isPrestador = true;
    nome = nomeUser;
    email = emailUser;
    localizacao = localizacaoUser;

    return null;
  }

  static Future<void> logout() async {
    await _auth.signOut();

    isPrestador = false;
    nome = "";
    email = "";
    localizacao = "Capão da Canoa - RS";
  }
}