import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Definimos el storage aquí para que sea accesible
const _storage = FlutterSecureStorage();

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.33:8000',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  // AGREGAMOS EL INTERCEPTOR
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Leemos el token del almacenamiento seguro
        final token = await _storage.read(key: 'jwt_token');

        // Si el token existe, lo inyectamos en los Headers
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        options.extra['requestStartedAt'] = DateTime.now();
        debugPrint('🚀 ENVIANDO [${options.method}] ${options.uri}');
        return handler.next(options); // Continúa la petición
      },
      onResponse: (response, handler) {
        final startedAt = response.requestOptions.extra['requestStartedAt'];
        final elapsed = startedAt is DateTime
            ? DateTime.now().difference(startedAt).inMilliseconds
            : null;
        debugPrint(
          '✅ RESPUESTA [${response.statusCode}] '
          '${response.requestOptions.method} ${response.requestOptions.path}'
          '${elapsed == null ? '' : ' (${elapsed}ms)'}',
        );
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        final startedAt = e.requestOptions.extra['requestStartedAt'];
        final elapsed = startedAt is DateTime
            ? DateTime.now().difference(startedAt).inMilliseconds
            : null;
        debugPrint(
          '❌ ERROR [${e.response?.statusCode ?? e.type.name}] '
          '${e.requestOptions.method} ${e.requestOptions.path}: ${e.message}'
          '${elapsed == null ? '' : ' (${elapsed}ms)'}.',
        );
        return handler.next(e);
      },
    ),
  );

  return dio;
});
