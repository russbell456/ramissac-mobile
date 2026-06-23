class OCItem {
  final int rqId;
  final int rqItemId;
  final String descripcion;
  final double cantidadSolicitada;
  double cantidadComprada;
  double costoUnitario;

  OCItem({
    required this.rqId,
    required this.rqItemId,
    required this.descripcion,
    required this.cantidadSolicitada,
    this.cantidadComprada = 0,
    this.costoUnitario = 0,
  });

  double get subtotal => cantidadComprada * costoUnitario;

  Map<String, dynamic> toJson() {
    return {
      "rq_item_id": rqItemId,
      "cantidad_comprada": cantidadComprada,
      "costo_unitario": costoUnitario,
      // "subtotal": subtotal, // Descomentar si el backend lo pide
    };
  }

  // Útil para cuando recuperas de un borrador local
  factory OCItem.fromJson(Map<String, dynamic> json) {
    return OCItem(
      rqId: json['rq_id'] ?? 0,
      rqItemId: json['rq_item_id'],
      descripcion: json['descripcion'] ?? '',
      cantidadSolicitada: (json['cantidad_solicitada'] ?? 0).toDouble(),
      cantidadComprada: (json['cantidad_comprada'] ?? 0).toDouble(),
      costoUnitario: (json['costo_unitario'] ?? 0).toDouble(),
    );
  }
}