class ArticuloImagenModel {
  final int id;
  final String nombreArchivo;
  final String ruta;
  final String tipoMime;
  final int articuloId;

  ArticuloImagenModel({
    required this.id,
    required this.nombreArchivo,
    required this.ruta,
    required this.tipoMime,
    required this.articuloId,
  });

  factory ArticuloImagenModel.fromJson(Map<String, dynamic> json) {
    return ArticuloImagenModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombreArchivo: json['nombre_archivo'] as String? ?? '',
      ruta: json['ruta'] as String? ?? '',
      tipoMime: json['tipo_mime'] as String? ?? '',
      articuloId: (json['articulo_id'] as num?)?.toInt() ?? 0,
    );
  }
}
