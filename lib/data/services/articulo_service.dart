import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_ocs/data/models/articulo_imagen_model.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';

class ArticuloService {
  final Dio _dio;

  ArticuloService(this._dio);

  // ============================================================
  // LISTAR TODOS
  // GET /articulo
  // ============================================================

  Future<List<ArticuloModel>> listarArticulos() async {
    final response = await _dio.get('/articulo');

    return _parseLista(response.data);
  }

  // ============================================================
  // LISTAR DISPONIBLES
  // GET /articulo/disponibles
  // ============================================================

  Future<List<ArticuloModel>> listarDisponibles() async {
    final response = await _dio.get('/articulo/disponibles');

    return _parseLista(response.data);
  }

  // ============================================================
  // BUSCAR
  // GET /articulo/buscar?q=
  // ============================================================

  Future<List<ArticuloModel>> buscarArticulos(String q) async {
    final termino = q.trim();

    final response = await _dio.get(
      '/articulo/buscar',
      queryParameters: {
        'q': termino,
      },
    );

    return _parseLista(response.data);
  }

  // ============================================================
  // OBTENER UNO
  // GET /articulo/{id}
  // ============================================================

  Future<ArticuloModel> obtenerArticulo(int id) async {
    final response = await _dio.get('/articulo/$id');

    return ArticuloModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ============================================================
  // CREAR
  // POST /articulo
  // ============================================================

  Future<ArticuloModel> crearArticulo(
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post(
      '/articulo',
      data: data,
    );

    return ArticuloModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ============================================================
  // ACTUALIZAR
  // PUT /articulo/{id}
  // ============================================================

  Future<ArticuloModel> actualizarArticulo(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put(
      '/articulo/$id',
      data: data,
    );

    return ArticuloModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ============================================================
  // DESACTIVAR
  // PATCH /articulo/{id}/desactivar
  // ============================================================

  Future<ArticuloModel> desactivarArticulo(int id) async {
    final response = await _dio.patch(
      '/articulo/$id/desactivar',
    );

    return ArticuloModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ============================================================
  // ACTIVAR
  // PATCH /articulo/{id}/activar
  // ============================================================

  Future<ArticuloModel> activarArticulo(int id) async {
    final response = await _dio.patch(
      '/articulo/$id/activar',
    );

    return ArticuloModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ============================================================
  // SUBIR IMAGEN
  // POST /articulo/{id}/imagenes
  // multipart/form-data
  // ============================================================

  Future<ArticuloImagenModel> subirImagen(
    int articuloId,
    String filePath,
  ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
      ),
    });

    final response = await _dio.post(
      '/articulo/$articuloId/imagenes',
      data: formData,
    );

    return ArticuloImagenModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ============================================================
  // ELIMINAR IMAGEN
  // DELETE /articulo/imagenes/{imagen_id}
  // ============================================================

  Future<void> eliminarImagen(int imagenId) async {
    await _dio.delete(
      '/articulo/imagenes/$imagenId',
    );
  }

  // ============================================================
  // PARSER DE LISTAS
  // ============================================================

  List<ArticuloModel> _parseLista(dynamic data) {
    if (data is! List) {
      throw const FormatException(
        'La respuesta del servidor no es una lista de artículos.',
      );
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(ArticuloModel.fromJson)
        .toList();
  }
}

// ============================================================
// PROVIDER DEL SERVICE
// ============================================================

final articuloServiceProvider = Provider<ArticuloService>((ref) {
  final dio = ref.watch(dioProvider);

  return ArticuloService(dio);
});