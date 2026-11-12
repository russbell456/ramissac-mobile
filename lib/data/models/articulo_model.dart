import 'articulo_imagen_model.dart';

class ArticuloModel {
  final int id;

  // Información general
  final String nombre;
  final String? marca;
  final String? modelo;
  final String? serie;
  final String? descripcion;
  final String? categoria;
  final String unidadMedida;
  final String tipo;
  final String? codigoExcel;

  // Stock
  final int stockTotal;
  final int stockActual;
  final int enPrestamo;

  // Estado
  final String? estadoFisico;

  // Costos
  final double? costoHora;
  final double? costoDia;
  final double? costoReposicion;

  // Configuración de fotografías
  final bool requiereFotoPrestamo;
  final bool requiereFotoDevolucion;
  final bool esActivoAltoValor;

  // Estado del artículo
  final bool activo;
  final DateTime? fechaBaja;

  // Imágenes
  final List<ArticuloImagenModel> imagenes;

  ArticuloModel({
    required this.id,
    required this.nombre,
    this.marca,
    this.modelo,
    this.serie,
    this.descripcion,
    this.categoria,
    required this.unidadMedida,
    required this.tipo,
    this.codigoExcel,
    required this.stockTotal,
    required this.stockActual,
    this.enPrestamo = 0,
    this.estadoFisico,
    this.costoHora,
    this.costoDia,
    this.costoReposicion,
    bool requiereFotoPrestamo = false,
    bool requiereFotoDevolucion = false,
    bool esActivoAltoValor = false,
    this.activo = true,
    this.fechaBaja,
    this.imagenes = const [],
  })  : esActivoAltoValor = esActivoAltoValor,
        requiereFotoPrestamo = esActivoAltoValor || requiereFotoPrestamo,
        requiereFotoDevolucion = esActivoAltoValor || requiereFotoDevolucion;

  // ============================================================
  // HELPERS
  // ============================================================

  bool get esEquipo => tipo.toUpperCase() == 'EQUIPO';

  bool get esHerramienta => tipo.toUpperCase() == 'HERRAMIENTA';

  bool get esConsumible => tipo.toUpperCase() == 'CONSUMIBLE';

  bool get tieneStock => stockActual > 0;

  bool get tieneImagenes => imagenes.isNotEmpty;

  bool get estaEnPrestamo => enPrestamo > 0;

  // ============================================================
  // JSON -> MODEL
  // ============================================================

  factory ArticuloModel.fromJson(Map<String, dynamic> json) {
    return ArticuloModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre'] as String? ?? '',
      marca: json['marca'] as String?,
      modelo: json['modelo'] as String?,
      serie: json['serie'] as String?,
      descripcion: json['descripcion'] as String?,
      categoria: json['categoria'] as String?,
      unidadMedida: json['unidad_medida'] as String? ?? '',
      tipo: json['tipo'] as String? ?? '',
      codigoExcel: json['codigo_excel'] as String?,
      stockTotal: (json['stock_total'] as num?)?.toInt() ?? 0,
      stockActual: (json['stock_actual'] as num?)?.toInt() ?? 0,
      enPrestamo: (json['en_prestamo'] as num?)?.toInt() ?? 0,
      estadoFisico: json['estado_fisico'] as String?,
      costoHora: _parseDouble(json['costo_hora']),
      costoDia: _parseDouble(json['costo_dia']),
      costoReposicion: _parseDouble(json['costo_reposicion']),
      requiereFotoPrestamo: json['requiere_foto_prestamo'] as bool? ?? false,
      requiereFotoDevolucion:
          json['requiere_foto_devolucion'] as bool? ?? false,
      esActivoAltoValor: json['es_activo_alto_valor'] as bool? ?? false,
      activo: json['activo'] as bool? ?? true,
      fechaBaja: json['fecha_baja'] != null
          ? DateTime.tryParse(json['fecha_baja'].toString())
          : null,
      imagenes: (json['imagenes'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(ArticuloImagenModel.fromJson)
              .toList() ??
          const [],
    );
  }

  // ============================================================
  // MODEL -> JSON PARA CREAR
  // ============================================================

  Map<String, dynamic> toCreateJson() => _toRequestJson(
        includeStock: true,
      );

  // ============================================================
  // MODEL -> JSON PARA ACTUALIZAR
  // ============================================================
  // El contrato de actualización mantiene el stock fuera del payload.
  Map<String, dynamic> toUpdateJson() => _toRequestJson(
        includeStock: false,
      );

  Map<String, dynamic> _toRequestJson({
    required bool includeStock,
  }) {
    return {
      'nombre': nombre,
      if (marca != null && marca!.trim().isNotEmpty) 'marca': marca!.trim(),
      if (modelo != null && modelo!.trim().isNotEmpty) 'modelo': modelo!.trim(),
      if (serie != null && serie!.trim().isNotEmpty) 'serie': serie!.trim(),
      if (descripcion != null && descripcion!.trim().isNotEmpty)
        'descripcion': descripcion!.trim(),
      if (categoria != null && categoria!.trim().isNotEmpty)
        'categoria': categoria!.trim(),
      'unidad_medida': unidadMedida,
      'tipo': tipo.toUpperCase(),
      if (codigoExcel != null && codigoExcel!.trim().isNotEmpty)
        'codigo_excel': codigoExcel!.trim(),
      if (includeStock) 'stock_total': stockTotal,
      if (includeStock) 'stock_actual': stockActual,
      if (costoHora != null) 'costo_hora': costoHora,
      if (costoDia != null) 'costo_dia': costoDia,
      if (costoReposicion != null) 'costo_reposicion': costoReposicion,
      'requiere_foto_prestamo': requiereFotoPrestamo,
      'requiere_foto_devolucion': requiereFotoDevolucion,
      'es_activo_alto_valor': esActivoAltoValor,
      if (estadoFisico != null && estadoFisico!.trim().isNotEmpty)
        'estado_fisico': estadoFisico!.trim(),
    };
  }

  // ============================================================
  // HELPERS PRIVADOS
  // ============================================================

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}
