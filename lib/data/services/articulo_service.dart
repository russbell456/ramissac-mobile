import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/data/models/articulo_imagen_model.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';

class ArticuloService {
  final Dio _dio;

  ArticuloService(this._dio);

  Future<List<ArticuloModel>> listarArticulos() async {
    final response = await _dio.get('/articulo');
    return (response.data as List)
        .map((json) => ArticuloModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<ArticuloModel>> buscarArticulos(String q) async {
    final response = await _dio.get('/articulo/buscar', queryParameters: {'q': q});
    return (response.data as List)
        .map((json) => ArticuloModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ArticuloModel> obtenerArticulo(int id) async {
    final response = await _dio.get('/articulo/$id');
    return ArticuloModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ArticuloModel> crearArticulo(Map<String, dynamic> data) async {
    final response = await _dio.post('/articulo', data: data);
    return ArticuloModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ArticuloModel> actualizarArticulo(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/articulo/$id', data: data);
    return ArticuloModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ArticuloModel> desactivarArticulo(int id) async {
    final response = await _dio.patch('/articulo/$id/desactivar');
    return ArticuloModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ArticuloModel> activarArticulo(int id) async {
    final response = await _dio.patch('/articulo/$id/activar');
    return ArticuloModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ArticuloImagenModel> subirImagen(int articuloId, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post('/articulo/$articuloId/imagenes', data: formData);
    return ArticuloImagenModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> eliminarImagen(int imagenId) async {
    await _dio.delete('/articulo/imagenes/$imagenId');
  }
}

final articuloServiceProvider = Provider<ArticuloService>((ref) {
  final dio = ref.watch(dioProvider);
  return ArticuloService(dio);
});
