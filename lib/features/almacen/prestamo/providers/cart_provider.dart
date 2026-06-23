import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';
// Asegúrate de importar tu modelo de Articulo

class CartItem {
  final ArticuloModel articulo;
  int cantidad;

  CartItem({required this.articulo, this.cantidad = 1});
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void toggleItem(ArticuloModel articulo) {
    final exists = state.any((item) => item.articulo.id == articulo.id);
    if (exists) {
      state = state.where((item) => item.articulo.id != articulo.id).toList();
    } else {
      state = [...state, CartItem(articulo: articulo)];
    }
  }

  void updateCantidad(String id, int nuevaCantidad) {
    state = [
      for (final item in state)
        if (item.articulo.id == id)
          CartItem(articulo: item.articulo, cantidad: nuevaCantidad)
        else
          item
    ];
  }

  void removeItem(String id) {
    state = state.where((item) => item.articulo.id != id).toList();
  }

  void clear() => state = [];
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});