
import 'package:dio/dio.dart';
import 'prestamo_multipart.dart';

class PrestamoService {
  final Dio _dio;

  PrestamoService(this._dio);

  // 🔹 Obtener préstamos por trabajador
  Future<List<Map<String, dynamic>>> getPrestamosPorTrabajador(int trabajadorId) async {
    try {
      final response = await _dio.get('/almacen/trabajador/$trabajadorId/prestamos');

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => e as Map<String, dynamic>).toList();
      }

      throw Exception('Error al obtener préstamos');
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Error de servidor');
    }
  }

  Future<Map<String, dynamic>> crearSolicitud(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/almacen/solicitudes-prestamo', data: data);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw Exception(_detail(e));
    }
  }

  Future<Map<String, dynamic>> obtenerSolicitud(String codigo) async {
    try {
      final response = await _dio.get('/almacen/solicitudes-prestamo/$codigo');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw Exception(_detail(e));
    }
  }

  Future<Map<String, dynamic>> confirmarSolicitud({
    required int prestamoId,
    required String signatureBase64,
    required Map<int, String> photosByArticle,
  }) async {
    try {
      final response = await _dio.post(
        '/almacen/solicitudes-prestamo/$prestamoId/confirmar',
        data: buildEvidenceFormData(
          data: const {},
          signatureBase64: signatureBase64,
          photosById: photosByArticle,
          photoIdField: 'articulo_id',
        ),
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw Exception(_detail(e));
    }
  }

  String _detail(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['detail'] != null) return data['detail'].toString();
    return data?.toString() ?? error.message ?? 'Error de servidor';
  }

}
