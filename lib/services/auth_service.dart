class AuthService {
  static bool isLogged = false;
  static bool isPrestador = false;

  static String nome = "";
  static String email = "";

  static void loginCliente(String nomeUser, String emailUser) {
    isLogged = true;
    isPrestador = false;
    nome = nomeUser;
    email = emailUser;
  }

  static void loginPrestador(String nomeUser, String emailUser) {
    isLogged = true;
    isPrestador = true;
    nome = nomeUser;
    email = emailUser;
  }

  static void logout() {
    isLogged = false;
    isPrestador = false;
    nome = "";
    email = "";
  }
}