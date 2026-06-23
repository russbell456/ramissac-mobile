class OrdenAsociadaDto {
  final int ordenId;
  final String proveedor;
  final String fecha;
  final double cantidadComprada;
  final double costoUnitario;

  OrdenAsociadaDto({
    required this.ordenId,
    required this.proveedor,
    required this.fecha,
    required this.cantidadComprada,
    required this.costoUnitario,
  });

  factory OrdenAsociadaDto.fromJson(Map<String, dynamic> json) {
    return OrdenAsociadaDto(
      ordenId: json['orden_id'],
      proveedor: json['proveedor'],
      fecha: json['fecha'],
      cantidadComprada:
          (json['cantidad_comprada_en_orden'] as num).toDouble(),
      costoUnitario:
          (json['costo_unitario'] as num).toDouble(),
    );
  }
}
