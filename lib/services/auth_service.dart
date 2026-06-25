class AuthService {
  static bool isLogged = false;
  static bool isPrestador = false;

  static String nome = "";
  static String email = "";
  static String localizacao = "Capão da Canoa - RS";

  static void loginCliente(String nomeUser, String emailUser) {
    isLogged = true;
    isPrestador = false;
    nome = nomeUser;
    email = emailUser;
    localizacao = "Capão da Canoa - RS";
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
    localizacao = localizacaoUser;
  }

  static void logout() {
    isLogged = false;
    isPrestador = false;
    nome = "";
    email = "";
    localizacao = "Capão da Canoa - RS";
  }
}