import 'orden_asociada_dto.dart';

class RqItemResumenDto {
  final int itemId;
  final String codigo;
  final String descripcion;
  final double cantidadRequerida;
  final double compradoTotal;
  final double avanceEfectivo;
  final double exceso;
  final String progreso;
  final String estadoItem;
  final List<OrdenAsociadaDto> ordenes;

  RqItemResumenDto({
    required this.itemId,
    required this.codigo,
    required this.descripcion,
    required this.cantidadRequerida,
    required this.compradoTotal,
    required this.avanceEfectivo,
    required this.exceso,
    required this.progreso,
    required this.estadoItem,
    required this.ordenes,
  });

  factory RqItemResumenDto.fromJson(Map<String, dynamic> json) {
    return RqItemResumenDto(
      itemId: json['item_id'],
      codigo: json['codigo'],
      descripcion: json['descripcion'],
      cantidadRequerida:
          (json['cantidad_requerida'] as num).toDouble(),
      compradoTotal:
          (json['comprado_total'] as num).toDouble(),
      avanceEfectivo:
          (json['avance_efectivo_rq'] as num).toDouble(),
      exceso:
          (json['exceso'] as num).toDouble(),
      progreso: json['progreso'],
      estadoItem: json['estado_item'],
      ordenes: (json['ordenes_asociadas'] as List)
          .map((e) => OrdenAsociadaDto.fromJson(e))
          .toList(),
    );
  }
}
