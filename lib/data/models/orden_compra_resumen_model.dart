// lib/models/orden_compra_resumen.dart
class OrdenCompraResumen {
  final int rqId;
  final String estadoCompra;
  final double progresoCompra;
  final int excesoTotal;
  final List<OrdenCompraItemResumen> items;

  OrdenCompraResumen({
    required this.rqId,
    required this.estadoCompra,
    required this.progresoCompra,
    required this.excesoTotal,
    required this.items,
  });

  factory OrdenCompraResumen.fromJson(Map<String, dynamic> json) {
    return OrdenCompraResumen(
      rqId: json['rq_id'],
      estadoCompra: json['estado_compra'],
      progresoCompra: (json['progreso_compra'] as num).toDouble(),
      excesoTotal: json['exceso_total'],
      items: (json['items'] as List)
          .map((e) => OrdenCompraItemResumen.fromJson(e))
          .toList(),
    );
  }
}

class OrdenCompraItemResumen {
  final int itemId;
  final String codigo;
  final String descripcion;
  final int cantidadRequerida;
  final int compradoAntes;
  final int compradoNuevo;
  final int compradoTotal;
  final int avanceEfectivoRq;
  final int exceso;
  final String progreso;
  final String estadoItem;

  OrdenCompraItemResumen({
    required this.itemId,
    required this.codigo,
    required this.descripcion,
    required this.cantidadRequerida,
    required this.compradoAntes,
    required this.compradoNuevo,
    required this.compradoTotal,
    required this.avanceEfectivoRq,
    required this.exceso,
    required this.progreso,
    required this.estadoItem,
  });

  factory OrdenCompraItemResumen.fromJson(Map<String, dynamic> json) {
    return OrdenCompraItemResumen(
      itemId: json['item_id'],
      codigo: json['codigo'],
      descripcion: json['descripcion'],
      cantidadRequerida: json['cantidad_requerida'],
      compradoAntes: json['comprado_antes'] ?? 0,
      compradoNuevo: json['comprado_nuevo'] ?? 0,
      compradoTotal: json['comprado_total'] ?? 0,
      avanceEfectivoRq: json['avance_efectivo_rq'] ?? 0,
      exceso: json['exceso'] ?? 0,
      progreso: json['progreso'],
      estadoItem: json['estado_item'],
    );
  }
}
