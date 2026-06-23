import 'package:sistema_ocs/features/ordenes_compra/models/comprobante_local.dart';
import 'package:sistema_ocs/features/ordenes_compra/models/oc_item_model.dart';

class OrdenCompraRequest {
  final String? idLocal;     
  int? idServidor;           
  String estado;

  final String proveedor;
  final String tipoCompra;
  final String fecha;
  final String? ubicacionEnvio;
  final double? costoEnvio;
  final String? notas;

  final List<OCItem> itemsComprados;
  final List<ComprobanteLocal> comprobantes;

  OrdenCompraRequest({
    this.idLocal,
    this.idServidor,
    required this.estado,
    required this.proveedor,
    required this.tipoCompra,
    required this.fecha,
    this.ubicacionEnvio,
    this.costoEnvio,
    this.notas,
    required this.itemsComprados,
    required this.comprobantes,
  });

  Map<String, dynamic> toJson() {
    final data = {
      "estado": estado,
      "proveedor": proveedor,
      "tipo_compra": tipoCompra,
      "fecha": fecha,
      "ubicacion_envio": ubicacionEnvio,
      "costo_envio": costoEnvio,
      "notas": notas,
      "items_comprados": itemsComprados.map((i) => i.toJson()).toList(),
      "comprobantes": comprobantes
          .where((c) => c.archivoRuta != null && c.archivoRuta!.isNotEmpty)
          .map((c) => c.toJson())
          .toList(),
    };

    data.removeWhere((key, value) => value == null);
    return data;
  }

  OrdenCompraRequest copyWith({
    String? estado,
    int? idServidor,
  }) {
    return OrdenCompraRequest(
      idLocal: idLocal,
      idServidor: idServidor ?? this.idServidor,
      estado: estado ?? this.estado,
      proveedor: proveedor,
      tipoCompra: tipoCompra,
      fecha: fecha,
      ubicacionEnvio: ubicacionEnvio,
      costoEnvio: costoEnvio,
      notas: notas,
      itemsComprados: itemsComprados,
      comprobantes: comprobantes,
    );
  }

  // 💡 ÚTIL PARA DASHBOARD
  double get total {
    return itemsComprados.fold(0.0, (sum, item) {
      return sum + (item.cantidadComprada * item.costoUnitario);
    });
  }
}
