import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/features/ordenes_compra/models/orden_compra_request.dart';
import 'package:sistema_ocs/features/ordenes_compra/models/oc_item_model.dart';

// Carrito temporal (Solo ítems seleccionados)
final ocProvider = StateNotifierProvider<OCNotifier, List<OCItem>>((ref) => OCNotifier());

class OCNotifier extends StateNotifier<List<OCItem>> {
  OCNotifier() : super([]);

  void addItem(OCItem item) {
    final index = state.indexWhere((i) => i.rqItemId == item.rqItemId);
    if (index == -1) {
      state = [...state, item];
    } else {
      state = [for (final i in state) if (i.rqItemId == item.rqItemId) item else i];
    }
  }

  void removeItem(int rqItemId) => state = state.where((i) => i.rqItemId != rqItemId).toList();
  void clearOC() => state = [];
  double get total => state.fold(0, (sum, item) => sum + item.subtotal);
}

// LISTA DE BORRADORES (JSONs COMPLETOS LOCALES)
final listaOrdenesLocalesProvider = StateNotifierProvider<OrdenesLocalesNotifier, List<OrdenCompraRequest>>((ref) {
  return OrdenesLocalesNotifier();
});

class OrdenesLocalesNotifier extends StateNotifier<List<OrdenCompraRequest>> {
  OrdenesLocalesNotifier() : super([]);

  // Guardar JSON completo editable
  void guardarOrden(OrdenCompraRequest orden) {
    final index = state.indexWhere((o) => o.idLocal == orden.idLocal);
    if (index != -1) {
      state = [for (int i = 0; i < state.length; i++) if (i == index) orden else state[i]];
    } else {
      state = [...state, orden];
    }
  }

  void eliminarOrden(String idLocal) {
    state = state.where((o) => o.idLocal != idLocal).toList();
  }

  // Al recibir el ID del servidor, actualizamos el borrador
  void vincularIdServidor(String idLocal, int idServidor) {
    state = [
      for (final o in state)
        if (o.idLocal == idLocal) o.copyWith(idServidor: idServidor, estado: 'enviado') else o
    ];
  }
}