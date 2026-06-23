class RQLocal {
  int? id;
  String servicio;
  String productosJson;
  String fecha;
  int enviado; // 0 = Borrador, 1 = Enviado

  RQLocal({
    this.id,
    required this.servicio,
    required this.productosJson,
    required this.fecha,
    this.enviado = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'servicio': servicio,
      'productos': productosJson,
      'fecha': fecha,
      'enviado': enviado,
    };
  }

  factory RQLocal.fromMap(Map<String, dynamic> map) {
    return RQLocal(
      id: map['id'],
      servicio: map['servicio'],
      productosJson: map['productos'],
      fecha: map['fecha'],
      enviado: map['enviado'],
    );
  }
}