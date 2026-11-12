import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

Uint8List _decodeBase64Image(String value) {
  final normalized =
      value.contains(',') ? value.substring(value.indexOf(',') + 1) : value;
  return base64Decode(normalized);
}

/// Builds a multipart request where metadata is JSON and evidence travels as
/// binary file parts associated to their article/detail IDs.
FormData buildEvidenceFormData({
  required Map<String, dynamic> data,
  required String signatureBase64,
  Map<int, String> photosById = const {},
  required String photoIdField,
}) {
  final photoFiles = <MultipartFile>[];
  final metadata = <Map<String, dynamic>>[];
  for (final entry in photosById.entries) {
    final filename = 'evidencia_${entry.key}.jpg';
    photoFiles.add(MultipartFile.fromBytes(
      _decodeBase64Image(entry.value),
      filename: filename,
      contentType: MediaType('image', 'jpeg'),
    ));
    metadata.add({photoIdField: entry.key, 'filename': filename});
  }

  return FormData.fromMap({
    'datos': jsonEncode(data),
    'firma': MultipartFile.fromBytes(
      _decodeBase64Image(signatureBase64),
      filename: 'firma.png',
      contentType: MediaType('image', 'png'),
    ),
    'fotos_metadata': jsonEncode(metadata),
    'fotos': photoFiles,
  });
}
