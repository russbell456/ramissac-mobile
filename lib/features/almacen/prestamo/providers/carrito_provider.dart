import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarritoItem {
  final dynamic articulo;
  int cantidad;

  CarritoItem({required this.articulo, required this.cantidad});
}
class CarritoNotifier extends StateNotifier<List<CarritoItem>> {
  CarritoNotifier() : super([]);

  void agregar(dynamic articulo, int cantidad) {
    final index = state.indexWhere(
      (item) => item.articulo.id == articulo.id,
    );

    if (index != -1) {
      final nuevaLista = [...state];
      nuevaLista[index].cantidad += cantidad;
      state = nuevaLista;
    } else {
      state = [
        ...state,
        CarritoItem(articulo: articulo, cantidad: cantidad),
      ];
    }
  }

  void aumentarCantidad(int index) {
    final nuevaLista = [...state];
    nuevaLista[index].cantidad++;
    state = nuevaLista;
  }

  void disminuirCantidad(int index) {
    final nuevaLista = [...state];

    if (nuevaLista[index].cantidad > 1) {
      nuevaLista[index].cantidad--;
    } else {
      nuevaLista.removeAt(index);
    }

    state = nuevaLista;
  }

  void eliminar(int index) {
    final nuevaLista = [...state];
    nuevaLista.removeAt(index);
    state = nuevaLista;
  }
}

final carritoProvider =
    StateNotifierProvider<CarritoNotifier, List<CarritoItem>>((ref) {
  return CarritoNotifier();
});