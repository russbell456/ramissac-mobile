import 'package:dio/dio.dart';

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

  // 🔹 Devolver préstamo
  Future<void> devolverPrestamo(int prestamoId) async {
    try {
      final response = await _dio.patch('/prestamos/$prestamoId/devolver');

      if (response.statusCode != 200) {
        throw Exception('Error al devolver préstamo');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Error de servidor');
    }
  }
}