import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sistema_ocs/data/models/user_model.dart';

class ProfileService {
  final Dio _dio;

  ProfileService(this._dio);

  // ============================================================
  // OBTENER DATOS DEL USUARIO ACTUAL
  // GET /auth/me
  // ============================================================
  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get('/auth/me');

    return UserModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<UserModel> updateContact({
    required String? telefono,
    required String? telefonoSecundario,
    required String? direccion,
  }) async {
    final response = await _dio.patch('/auth/me', data: {
      'telefono': telefono,
      'telefono_secundario': telefonoSecundario,
      'direccion': direccion,
    });
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ============================================================
  // GUARDAR FIRMA
  // PUT /auth/me/firma
  // ============================================================
  Future<UserModel> saveSignature(String base64) async {
    final response = await _dio.put(
      '/auth/me/firma',
      data: {
        'firma_base64': base64,
      },
    );

    if (response.data is Map<String, dynamic> &&
        (response.data as Map<String, dynamic>)['id'] != null) {
      return UserModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    return getCurrentUser();
  }

  // ============================================================
  // GENERAR IMAGEN DE FIRMA
  // POST /auth/me/firma/imagen
  // ============================================================
  Future<String?> generateSignatureImage() async {
    final response = await _dio.post(
      '/auth/me/firma/imagen',
    );

    final data = response.data;

    if (data is String) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      return (data['url'] ??
          data['ruta'] ??
          data['firma_url']) as String?;
    }

    return null;
  }

  // ============================================================
  // SUBIR FOTO
  // POST /auth/me/foto
  // ============================================================
  Future<UserModel> uploadPhoto(PlatformFile file) async {
    final path = file.path;
    final bytes = file.bytes;
    if ((path == null || path.isEmpty) && bytes == null) {
      throw const FormatException(
        'No se pudo leer el archivo seleccionado',
      );
    }

    final imagePart = path != null && path.isNotEmpty
        ? await MultipartFile.fromFile(path, filename: file.name)
        : MultipartFile.fromBytes(bytes!, filename: file.name);

    // El backend espera:
    //
    // archivo: UploadFile = File(...)
    //
    // Por eso el nombre del campo debe ser "archivo"
    // y no "foto".
    final formData = FormData.fromMap({
      'archivo': imagePart,
    });

    final response = await _dio.post(
      '/auth/me/foto',
      data: formData,
    );

    if (response.data is Map<String, dynamic> &&
        (response.data as Map<String, dynamic>)['id'] != null) {
      return UserModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    return getCurrentUser();
  }
}
