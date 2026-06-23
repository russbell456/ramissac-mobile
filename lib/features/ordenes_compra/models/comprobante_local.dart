class ComprobanteLocal {
  final String tipoDocumento;
  final String archivoRuta;
  final String? numeroComprobante;
  final bool esFactura;
  final String? fecha;

  ComprobanteLocal({
    required this.tipoDocumento,
    required this.archivoRuta,
    this.numeroComprobante,
    this.esFactura = true,
    this.fecha,
  });

  Map<String, dynamic> toJson() {
    final data = {
      "tipo_documento": tipoDocumento,
      "archivo_ruta": archivoRuta.split('/').last,
      "numero_comprobante": numeroComprobante,
      "es_factura": esFactura,
      "fecha": fecha,
    };

    data.removeWhere((key, value) => value == null || value == '');
    return data;
  }
}
