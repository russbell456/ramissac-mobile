import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';

void main() {
  test('create and update payloads preserve their stock contract', () {
    final articulo = ArticuloModel(
      id: 8,
      nombre: 'Taladro',
      unidadMedida: 'UND',
      tipo: 'EQUIPO',
      stockTotal: 3,
      stockActual: 2,
    );

    expect(articulo.toCreateJson()['stock_total'], 3);
    expect(articulo.toCreateJson()['stock_actual'], 2);
    expect(articulo.toUpdateJson().containsKey('stock_total'), isFalse);
    expect(articulo.toUpdateJson().containsKey('stock_actual'), isFalse);
  });

  test('high value automatically enables both photo flags in payloads', () {
    final articulo = ArticuloModel(
      id: 9,
      nombre: 'Rotomartillo',
      unidadMedida: 'UND',
      tipo: 'EQUIPO',
      stockTotal: 1,
      stockActual: 1,
      esActivoAltoValor: true,
    );

    for (final payload in [articulo.toCreateJson(), articulo.toUpdateJson()]) {
      expect(payload['es_activo_alto_valor'], isTrue);
      expect(payload['requiere_foto_prestamo'], isTrue);
      expect(payload['requiere_foto_devolucion'], isTrue);
    }
  });
}
