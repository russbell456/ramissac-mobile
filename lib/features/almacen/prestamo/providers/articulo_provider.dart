import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';
 // Tu dioProvider

final articulosProvider = FutureProvider<List<ArticuloModel>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/articulo/articulos');
    return (response.data as List).map((json) => ArticuloModel.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Error al cargar artículos: $e');
  }
});