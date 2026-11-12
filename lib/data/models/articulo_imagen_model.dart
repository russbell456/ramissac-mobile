class ArticuloImagenModel {
  final int id;
  final String nombreArchivo;
  final String ruta;
  final String tipoMime;
  final DateTime? fechaCreacion;

  ArticuloImagenModel({
    required this.id,
    required this.nombreArchivo,
    required this.ruta,
    required this.tipoMime,
    this.fechaCreacion,
  });

  factory ArticuloImagenModel.fromJson(Map<String, dynamic> json) {
    return ArticuloImagenModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombreArchivo: json['nombre_archivo'] as String? ?? '',
      ruta: json['ruta'] as String? ?? '',
      tipoMime: json['tipo_mime'] as String? ?? '',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_archivo': nombreArchivo,
      'ruta': ruta,
      'tipo_mime': tipoMime,
      if (fechaCreacion != null)
        'fecha_creacion': fechaCreacion!.toIso8601String(),
    };
  }
}
