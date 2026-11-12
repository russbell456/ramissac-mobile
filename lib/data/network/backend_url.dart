import 'package:dio/dio.dart';

String buildBackendUrl(Dio dio, String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;

  final baseUrl = dio.options.baseUrl.replaceFirst(RegExp(r'/$'), '');
  final normalizedPath = path.startsWith('/') ? path : '/$path';
  return '$baseUrl$normalizedPath';
}
