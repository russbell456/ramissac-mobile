class RqItemModeloc {
  final int id;
  final String producto;
  final int cantidadSolicitada;

  bool seleccionado;
  int cantidadComprar;

  RqItemModeloc({
    required this.id,
    required this.producto,
    required this.cantidadSolicitada,
    this.seleccionado = false,
    this.cantidadComprar = 0,
  });
}
