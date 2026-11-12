import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';

final busquedaArticulosProvider =
    StateProvider.autoDispose<String>((ref) => '');

// Invalidating on every edit immediately retires the previous future. Riverpod
// only publishes the current future, even if an old transport ignores cancel.
final articulosProvider =
    FutureProvider.autoDispose<List<ArticuloModel>>((ref) async {
  final query = ref.watch(busquedaArticulosProvider).trim();
  final dio = ref.watch(dioProvider);
  final cancelToken = CancelToken();
  final debounce = Completer<void>();
  final timer =
      Timer(Duration(milliseconds: query.isEmpty ? 0 : 400), debounce.complete);
  ref.onDispose(() {
    timer.cancel();
    if (!debounce.isCompleted) debounce.complete();
    cancelToken.cancel('Consulta reemplazada o catálogo cerrado');
  });
  await debounce.future;
  if (cancelToken.isCancelled) {
    throw const FormatException('Consulta cancelada');
  }
  final response = await dio.get<List<dynamic>>(
    '/articulo/disponibles',
    queryParameters: query.isEmpty ? null : {'q': query},
    cancelToken: cancelToken,
  );
  return response.data!
      .map((json) => ArticuloModel.fromJson(json as Map<String, dynamic>))
      .toList();
});
