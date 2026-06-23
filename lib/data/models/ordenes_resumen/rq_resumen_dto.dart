import 'rq_item_resumen_dto.dart';

class RqResumenDto {
  final int rqId;
  final List<RqItemResumenDto> items;
  final double progresoCompra;
  final String estadoCompra;
  final double excesoTotal;

  RqResumenDto({
    required this.rqId,
    required this.items,
    required this.progresoCompra,
    required this.estadoCompra,
    required this.excesoTotal,
  });

  factory RqResumenDto.fromJson(Map<String, dynamic> json) {
    return RqResumenDto(
      rqId: json['rq_id'],
      items: (json['items'] as List)
          .map((e) => RqItemResumenDto.fromJson(e))
          .toList(),
      progresoCompra:
          (json['progreso_compra'] as num).toDouble(),
      estadoCompra: json['estado_compra'],
      excesoTotal:
          (json['exceso_total'] as num).toDouble(),
    );
  }
}
