import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'orden_compra_service.dart';

// Provider singleton del servicio de OrdenCompra
final ordenCompraServiceProvider = Provider<OrdenCompraService>((ref) {
  return OrdenCompraService();
});
