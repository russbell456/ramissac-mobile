import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';
import 'package:sistema_ocs/features/almacen/prestamo/devolucion/prestamo_service.dart';
  
final prestamoServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return PrestamoService(dio);
});

// 🔥 Provider dinámico por trabajador
final prestamosProvider =
    FutureProvider.family<List<dynamic>, int>((ref, trabajadorId) async {
  final service = ref.read(prestamoServiceProvider);
  return service.getPrestamosPorTrabajador(trabajadorId);
});