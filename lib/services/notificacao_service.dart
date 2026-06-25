import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'auth_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificacaoService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final CollectionReference<Map<String, dynamic>> _tokens =
      FirebaseFirestore.instance.collection("notification_tokens");

  static Future<void> inicializar() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      // O Firebase exibe notificações em segundo plano. Em primeiro plano,
      // esta escuta mantém o app preparado para banners internos no futuro.
    });

    _messaging.onTokenRefresh.listen((token) {
      salvarToken(token: token);
    });
  }

  static Future<void> salvarToken({String? token}) async {
    final email = AuthService.email.trim().toLowerCase();
    if (email.isEmpty) return;

    final fcmToken = token ?? await _messaging.getToken();
    if (fcmToken == null || fcmToken.isEmpty) return;

    await _tokens.doc(email).set({
      "email": email,
      "nome": AuthService.nome,
      "isPrestador": AuthService.isPrestador,
      "token": fcmToken,
      "atualizadoEm": DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  static Future<String?> tokenAtual() {
    return _messaging.getToken();
  }
}



