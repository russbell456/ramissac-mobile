// lib/features/requerimientos/rq_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/data/models/rq_model.dart';
import 'package:sistema_ocs/data/services/rq_service.dart';

// 1. Proveedor del Servicio
final rqServiceProvider = Provider((ref) => RqService());

// 2. Notifier para gestionar la lista de RQs
class RqListNotifier extends StateNotifier<AsyncValue<List<RQResponse>>> {
  final RqService _service;

  RqListNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchRqs();
  }

  Future<void> fetchRqs() async {
    try {
      state = const AsyncValue.loading();
      final rqs = await _service.listRqs();
      state = AsyncValue.data(rqs);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteRq(int rqId) async {
    try {
      await _service.deleteRq(rqId);
      // Refrescar la lista después de la eliminación exitosa
      await fetchRqs(); 
    } catch (e) {
      // Re-lanza el error para que la UI lo maneje (mostrar SnackBar)
      rethrow; 
    }
  }
}

// 3. Proveedor del Notifier
final rqListNotifierProvider = 
    StateNotifierProvider<RqListNotifier, AsyncValue<List<RQResponse>>>(
  (ref) => RqListNotifier(ref.watch(rqServiceProvider)),
);