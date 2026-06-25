import 'package:flutter_test/flutter_test.dart';
import 'package:ijob_app/services/location_service.dart';

void main() {
  test('calcula distancia aproximada entre dois pontos', () {
    final distancia = LocationService.calcularDistanciaEmKm(
      origemLatitude: -29.7604,
      origemLongitude: -50.0280,
      destinoLatitude: -29.7582,
      destinoLongitude: -50.0201,
    );

    expect(distancia, greaterThan(0));
    expect(distancia, lessThan(2));
  });
}
