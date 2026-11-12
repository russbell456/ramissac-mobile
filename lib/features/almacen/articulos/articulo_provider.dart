import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_ocs/data/models/articulo_imagen_model.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';
import 'package:sistema_ocs/data/services/articulo_service.dart';

// ============================================================
// PROVIDER PRINCIPAL DE ARTÍCULOS
// ============================================================

final articulosListProvider =
    AsyncNotifierProvider<ArticulosListNotifier, List<ArticuloModel>>(
  ArticulosListNotifier.new,
);

// ============================================================
// NOTIFIER
// ============================================================

class ArticulosListNotifier extends AsyncNotifier<List<ArticuloModel>> {
  int _requestRevision = 0;
  Future<List<ArticuloModel>>? _latestRequest;

  @override
  Future<List<ArticuloModel>> build() async {
    final revision = ++_requestRevision;
    final initialRequest = _fetch();
    _latestRequest = initialRequest;

    List<ArticuloModel>? result;
    try {
      result = await initialRequest;
    } catch (error, stackTrace) {
      if (revision == _requestRevision) {
        Error.throwWithStackTrace(error, stackTrace);
      }
    }

    var observedRevision = revision;
    while (observedRevision != _requestRevision) {
      observedRevision = _requestRevision;
      final latestRequest = _latestRequest;
      if (latestRequest != null) result = await latestRequest;
    }

    return result ?? _fetch();
  }

  // ============================================================
  // SERVICE
  // ============================================================

  ArticuloService get _service {
    return ref.read(articuloServiceProvider);
  }

  // ============================================================
  // OBTENER TODOS
  // ============================================================

  Future<List<ArticuloModel>> _fetch() async {
    try {
      return await _service.listarArticulos();
    } catch (e) {
      throw Exception(
        'Error al cargar artículos: $e',
      );
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    await _load(_fetch);
  }

  // ============================================================
  // BUSCAR
  // ============================================================

  Future<void> buscar(String q) async {
    final termino = q.trim();

    if (termino.length < 2) {
      await refresh();
      return;
    }

    await _load(() => _service.buscarArticulos(termino));
  }

  Future<void> _load(
    Future<List<ArticuloModel>> Function() request,
  ) async {
    final revision = ++_requestRevision;
    final previousState = state;
    state = const AsyncLoading<List<ArticuloModel>>()
        .copyWithPrevious(previousState);

    final pendingRequest = request();
    _latestRequest = pendingRequest;
    final result = await AsyncValue.guard(() => pendingRequest);

    if (revision != _requestRevision) return;
    state = result.hasError ? result.copyWithPrevious(previousState) : result;
  }

  // ============================================================
  // LISTAR DISPONIBLES
  // ============================================================

  Future<List<ArticuloModel>> listarDisponibles() async {
    try {
      return await _service.listarDisponibles();
    } catch (e) {
      throw Exception(
        'Error al cargar artículos disponibles: $e',
      );
    }
  }

  // ============================================================
  // OBTENER ARTÍCULO
  // ============================================================

  Future<ArticuloModel> obtenerArticulo(int id) async {
    try {
      return await _service.obtenerArticulo(id);
    } catch (e) {
      throw Exception(
        'Error al obtener el artículo: $e',
      );
    }
  }

  // ============================================================
  // CREAR
  // ============================================================

  Future<ArticuloModel> crear(
    Map<String, dynamic> data,
  ) async {
    try {
      final articulo = await _service.crearArticulo(data);

      await refresh();

      return articulo;
    } catch (e) {
      throw Exception(
        'Error al crear el artículo: $e',
      );
    }
  }

  // ============================================================
  // ACTUALIZAR
  // ============================================================

  Future<ArticuloModel> actualizar(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final articulo = await _service.actualizarArticulo(
        id,
        data,
      );

      await refresh();

      return articulo;
    } catch (e) {
      throw Exception(
        'Error al actualizar el artículo: $e',
      );
    }
  }

  // ============================================================
  // DESACTIVAR
  // ============================================================

  Future<ArticuloModel> desactivar(int id) async {
    try {
      final articulo = await _service.desactivarArticulo(id);

      await refresh();

      return articulo;
    } catch (e) {
      throw Exception(
        'Error al desactivar el artículo: $e',
      );
    }
  }

  // ============================================================
  // ACTIVAR
  // ============================================================

  Future<ArticuloModel> activar(int id) async {
    try {
      final articulo = await _service.activarArticulo(id);

      await refresh();

      return articulo;
    } catch (e) {
      throw Exception(
        'Error al activar el artículo: $e',
      );
    }
  }

  // ============================================================
  // SUBIR IMAGEN
  // ============================================================

  Future<ArticuloImagenModel> subirImagen(
    int articuloId,
    String filePath,
  ) async {
    try {
      final imagen = await _service.subirImagen(
        articuloId,
        filePath,
      );

      await refresh();

      return imagen;
    } catch (e) {
      throw Exception(
        'Error al subir la imagen: $e',
      );
    }
  }

  /// Uploads several images, then refreshes the shared list once.
  /// Returns the error for each failed path so the form can report partial success.
  Future<Map<String, String>> subirImagenes(
    int articuloId,
    List<String> filePaths,
  ) async {
    final failures = <String, String>{};
    var uploadedAtLeastOne = false;

    for (final filePath in filePaths) {
      try {
        await _service.subirImagen(articuloId, filePath);
        uploadedAtLeastOne = true;
      } catch (error) {
        failures[filePath] = error.toString();
      }
    }

    if (uploadedAtLeastOne) await refresh();
    return failures;
  }

  // ============================================================
  // ELIMINAR IMAGEN
  // ============================================================

  Future<void> eliminarImagen(int imagenId) async {
    try {
      await _service.eliminarImagen(imagenId);

      await refresh();
    } catch (e) {
      throw Exception(
        'Error al eliminar la imagen: $e',
      );
    }
  }
}
