Map<String, dynamic> construirPrestamoJson({
  required dynamic user,
  required List carrito,
  required DateTime fechaDevolucion,
}) {
  return {
    "trabajador_id": user.id,
    "codigo_unico": "PRE-${DateTime.now().millisecondsSinceEpoch}",
    "dni": user.dni ?? "",
    "nombres_completos": user.nombresCompletos,
    "cargo": user.cargo ?? "",
    "fecha_prestamo": DateTime.now().toIso8601String(),
    "fecha_devolucion_prevista": fechaDevolucion.toIso8601String(),
    "items": carrito.map((item) => {
      "articulo_id": item.articulo.id,
      "cantidad": item.cantidad,
    }).toList(),

    // 🔥 AÚN VACÍO (firma luego)
    "firma_base64": ""
  };
}