// lib/services/auth_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService(this._dio);

  // ===========================
  // 🔹 LOGIN
  // ===========================
  Future<TokenModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final tokenModel = TokenModel.fromJson(data);

        // Guardar token y role
        await _storage.write(key: 'jwt_token', value: tokenModel.accessToken);
        await _storage.write(
            key: 'user_role', value: tokenModel.role ?? 'user');

        // Guardar usuario completo en storage
        final userJson = data['user'] as Map<String, dynamic>?;
        if (userJson != null) {
          final user = UserModel.fromJson(userJson);
          await _storage.write(
              key: 'user_data', value: jsonEncode(user.toJson()));
        }

        return tokenModel;
      }

      throw Exception('Login falló con código ${response.statusCode}');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      throw Exception(
        status == null
            ? 'No se pudo conectar con el servidor (${e.type.name}): ${e.message}'
            : 'El servidor respondió HTTP $status.',
      );
    }
  }

  // ===========================
  // 🔹 OBTENER USUARIO ACTUAL
  // ===========================
  Future<UserModel?> getCurrentUser() async {
    final userJsonStr = await _storage.read(key: 'user_data');
    if (userJsonStr == null) return null;

    try {
      final userJson = jsonDecode(userJsonStr) as Map<String, dynamic>;
      return UserModel.fromJson(userJson);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> fetchCurrentUser() async {
    final response = await _dio.get('/auth/me');
    final user = UserModel.fromJson(response.data as Map<String, dynamic>);
    await _storage.write(key: 'user_data', value: jsonEncode(user.toJson()));
    return user;
  }

  // ===========================
  // 🔹 LOGOUT
  // ===========================
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_role');
    await _storage.delete(key: 'user_data');
  }

  // ===========================
  // 🔹 OBTENER TODOS LOS TRABAJADORES
  // ===========================
  Future<List<Map<String, dynamic>>> getTrabajadores() async {
    try {
      final response = await _dio.get(
        '/auth/trabajadores',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _storage.read(key: 'jwt_token')}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        // Retornamos la lista de trabajadores como Map
        return data.map((e) => e as Map<String, dynamic>).toList();
      }

      throw Exception('Error al obtener trabajadores: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Error de conexión o servidor: ${e.message}');
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await _dio.post('/auth/me/cambiar-password', data: {
      'password_actual': currentPassword,
      'password_nueva': newPassword,
    });
  }

  Future<UserModel> updateMyProfile(Map<String, dynamic> data) async {
    final response = await _dio.patch('/auth/me', data: data);
    final user = UserModel.fromJson(response.data as Map<String, dynamic>);
    await _storage.write(key: 'user_data', value: jsonEncode(user.toJson()));
    return user;
  }

  Future<UserModel> register(Map<String, dynamic> data) async {
    final response = await _dio.post('/auth/register', data: data);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<UserModel>> listUsers(
      {String? search, String? role, String? status, bool? active}) async {
    final response = await _dio.get('/auth/usuarios', queryParameters: {
      if (search?.trim().isNotEmpty == true) 'search': search!.trim(),
      if (role != null && role != 'Todos') 'role': role,
      if (status != null && status != 'Todos') 'estado_laboral': status,
      if (active != null) 'activo': active,
    });
    return (response.data as List)
        .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel> getUser(int id) async {
    final response = await _dio.get('/auth/usuario/$id');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> updateUser(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/auth/usuario/$id', data: data);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> updateUserStatus(
      int id, bool active, String employmentStatus) async {
    final response = await _dio.patch('/auth/usuario/$id/estado', data: {
      'activo': active,
      'estado_laboral': employmentStatus,
    });
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> uploadUserPhoto(int id, PlatformFile file) async {
    final path = file.path;
    final bytes = file.bytes;
    if ((path == null || path.isEmpty) && bytes == null)
      throw const FormatException('No se pudo leer la imagen seleccionada.');
    final imagePart = path != null && path.isNotEmpty
        ? await MultipartFile.fromFile(path, filename: file.name)
        : MultipartFile.fromBytes(bytes!, filename: file.name);
    final response = await _dio.post('/auth/usuario/$id/foto',
        data: FormData.fromMap({
          'archivo': imagePart,
        }));
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> saveUserSignature(int id, String base64) async {
    final response = await _dio
        .put('/auth/usuario/$id/firma', data: {'firma_base64': base64});
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String?> generateUserSignatureImage(int id) async {
    final response = await _dio.post('/auth/usuario/$id/firma/imagen');
    final data = response.data;
    if (data is Map) return data['firma_url']?.toString();
    return data is String ? data : null;
  }
}
