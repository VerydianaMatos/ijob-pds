import 'dart:math' as math;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocalizacaoAtual {
  final double latitude;
  final double longitude;
  final double precisaoEmMetros;
  final String endereco;
  final String cidade;
  final String estado;
  final String pais;

  const LocalizacaoAtual({
    required this.latitude,
    required this.longitude,
    required this.precisaoEmMetros,
    required this.endereco,
    required this.cidade,
    required this.estado,
    required this.pais,
  });

  String get enderecoCurto {
    final partes = [
      if (cidade.trim().isNotEmpty) cidade.trim(),
      if (estado.trim().isNotEmpty) estado.trim(),
    ];

    if (partes.isEmpty) {
      return resumoCoordenadas;
    }

    return partes.join(" - ");
  }

  String get resumo {
    if (endereco.trim().isNotEmpty) {
      return endereco;
    }

    return enderecoCurto;
  }

  String get resumoCoordenadas {
    final lat = latitude.toStringAsFixed(4);
    final lng = longitude.toStringAsFixed(4);
    return "Atual: $lat, $lng";
  }
}

class LocationService {
  static Future<LocalizacaoAtual> obterLocalizacaoAtual() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();

    if (!servicoAtivo) {
      throw const LocationException(
        "Ative a localização do aparelho para encontrar profissionais perto de você.",
      );
    }

    var permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied) {
      throw const LocationException(
        "Permita o acesso à localização para ordenar os profissionais por distância.",
      );
    }

    if (permissao == LocationPermission.deniedForever) {
      throw const LocationException(
        "A permissão de localização está bloqueada. Abra as configurações do app para liberar.",
      );
    }

    final posicao = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return _comEndereco(
      latitude: posicao.latitude,
      longitude: posicao.longitude,
      precisaoEmMetros: posicao.accuracy,
    );
  }

  static Future<LocalizacaoAtual> obterLocalizacaoPorEndereco(
    String endereco,
  ) async {
    final texto = endereco.trim();

    if (texto.length < 5) {
      throw const LocationException(
        "Digite um endereço, bairro ou cidade mais completo.",
      );
    }

    try {
      await setLocaleIdentifier("pt_BR");
      final locais = await locationFromAddress(texto);

      if (locais.isEmpty) {
        throw const LocationException("Endereço não encontrado.");
      }

      final local = locais.first;

      return _comEndereco(
        latitude: local.latitude,
        longitude: local.longitude,
        precisaoEmMetros: 0,
        enderecoDigitado: texto,
      );
    } on LocationException {
      rethrow;
    } catch (_) {
      throw const LocationException(
        "Não foi possível localizar esse endereço.",
      );
    }
  }

  static Future<LocalizacaoAtual> _comEndereco({
    required double latitude,
    required double longitude,
    required double precisaoEmMetros,
    String enderecoDigitado = "",
  }) async {
    try {
      await setLocaleIdentifier("pt_BR");

      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      final place = placemarks.isNotEmpty ? placemarks.first : null;

      final rua = place?.street ?? "";
      final bairro = place?.subLocality ?? "";
      final cidade = place?.subAdministrativeArea?.isNotEmpty == true
          ? place!.subAdministrativeArea!
          : place?.locality ?? "";
      final estado = place?.administrativeArea ?? "";
      final pais = place?.country ?? "";
      final endereco = _juntarPartes([
        rua,
        bairro,
        cidade,
        estado,
      ]);

      return LocalizacaoAtual(
        latitude: latitude,
        longitude: longitude,
        precisaoEmMetros: precisaoEmMetros,
        endereco: endereco.isEmpty ? enderecoDigitado : endereco,
        cidade: cidade,
        estado: estado,
        pais: pais,
      );
    } catch (_) {
      return LocalizacaoAtual(
        latitude: latitude,
        longitude: longitude,
        precisaoEmMetros: precisaoEmMetros,
        endereco: enderecoDigitado,
        cidade: "",
        estado: "",
        pais: "",
      );
    }
  }

  static double calcularDistanciaEmKm({
    required double origemLatitude,
    required double origemLongitude,
    required double destinoLatitude,
    required double destinoLongitude,
  }) {
    const raioTerraEmKm = 6371.0;
    final dLat = _grausParaRadianos(destinoLatitude - origemLatitude);
    final dLng = _grausParaRadianos(destinoLongitude - origemLongitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_grausParaRadianos(origemLatitude)) *
            math.cos(_grausParaRadianos(destinoLatitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return raioTerraEmKm * c;
  }

  static String formatarDistancia(double distanciaEmKm) {
    if (distanciaEmKm < 1) {
      return "${(distanciaEmKm * 1000).round()} m";
    }

    return "${distanciaEmKm.toStringAsFixed(1)} km";
  }

  static String _juntarPartes(List<String> partes) {
    return partes
        .where((parte) => parte.trim().isNotEmpty)
        .map((parte) => parte.trim())
        .toSet()
        .join(", ");
  }

  static double _grausParaRadianos(double graus) {
    return graus * math.pi / 180;
  }
}

class LocationException implements Exception {
  final String message;

  const LocationException(this.message);

  @override
  String toString() => message;
}



