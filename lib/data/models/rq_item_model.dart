// lib/data/models/rq_item_model.dart

// 💡 Nota: Crearemos una clase vacía para OrdenParcialResponse por ahora.
class OrdenParcialResponse {}

class RQItemResponse {
  final int id;
  final String codigo;
  final String descripcion;
  final double cantidad;
  final String unidad; // ✅ Nuevo campo
  final List<OrdenParcialResponse> ordenesParciales;
   // ✅ Nuevo campo (vacío por ahora)
     // 👇 SOLO PARA OC (FRONT)
  bool seleccionado = false;
  int cantidadComprar = 0;
  double costoUnitario = 0.0;

  RQItemResponse({
    required this.id,
    required this.codigo,
    required this.descripcion,
    required this.cantidad,
    required this.unidad,
    required this.ordenesParciales,
  });

  factory RQItemResponse.fromJson(Map<String, dynamic> json) {
    return RQItemResponse(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      descripcion: json['descripcion'] as String,
      cantidad: (json['cantidad'] as num).toDouble(),
      unidad: json['unidad'] as String, // Lectura del campo
      // Asumimos que "ordenes_parciales" es una lista y la dejamos vacía por ahora
      ordenesParciales: (json['ordenes_parciales'] as List<dynamic>?)
          ?.map((i) => OrdenParcialResponse()) // Simulación
          .toList() ?? [],
    );
  }
}