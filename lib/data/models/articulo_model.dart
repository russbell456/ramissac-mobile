class ArticuloModel {
  final int id;
  final String nombre;
  final String unidadMedida;
  final String tipo;
  final int stockActual;
  final String codigoExcel;

  ArticuloModel({
    required this.id,
    required this.nombre,
    required this.unidadMedida,
    required this.tipo,
    required this.stockActual,
    required this.codigoExcel,
  });

  factory ArticuloModel.fromJson(Map<String, dynamic> json) {
    return ArticuloModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      unidadMedida: json['unidad_medida'] as String,
      tipo: json['tipo'] as String,
      stockActual: json['stock_actual'] as int,
      codigoExcel: json['codigo_excel'] as String,
    );
  }
}