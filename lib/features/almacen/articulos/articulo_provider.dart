import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';
import 'package:sistema_ocs/data/services/articulo_service.dart';

final articulosListProvider =
    AsyncNotifierProvider<ArticulosListNotifier, List<ArticuloModel>>(
        ArticulosListNotifier.new);

class ArticulosListNotifier extends AsyncNotifier<List<ArticuloModel>> {
  @override
  Future<List<ArticuloModel>> build() async {
    return _fetch();
  }

  ArticuloService get _service => ref.read(articuloServiceProvider);

  Future<List<ArticuloModel>> _fetch() async {
    try {
      return await _service.listarArticulos();
    } catch (e) {
      throw Exception('Error al cargar artículos: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> buscar(String q) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.buscarArticulos(q));
  }

  Future<bool> crear(Map<String, dynamic> data) async {
    try {
      await _service.crearArticulo(data);
      await refresh();
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> actualizar(int id, Map<String, dynamic> data) async {
    try {
      await _service.actualizarArticulo(id, data);
      await refresh();
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> desactivar(int id) async {
    try {
      await _service.desactivarArticulo(id);
      await refresh();
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> activar(int id) async {
    try {
      await _service.activarArticulo(id);
      await refresh();
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
