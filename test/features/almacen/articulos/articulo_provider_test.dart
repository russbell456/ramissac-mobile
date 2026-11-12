import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';
import 'package:sistema_ocs/data/services/articulo_service.dart';
import 'package:sistema_ocs/features/almacen/articulos/articulo_provider.dart';

class _ArticuloServiceFake extends ArticuloService {
  _ArticuloServiceFake() : super(Dio());

  Future<List<ArticuloModel>>? initialList;
  final Map<String, Completer<List<ArticuloModel>>> searches = {};

  @override
  Future<List<ArticuloModel>> listarArticulos() =>
      initialList ?? Future.value(const []);

  @override
  Future<List<ArticuloModel>> buscarArticulos(String q) => searches[q]!.future;
}

ArticuloModel _article(int id, String name) => ArticuloModel(
      id: id,
      nombre: name,
      unidadMedida: 'UND',
      tipo: 'EQUIPO',
      stockTotal: 1,
      stockActual: 1,
    );

void main() {
  test('an initial load cannot overwrite a search started while it is pending',
      () async {
    final service = _ArticuloServiceFake();
    final initial = Completer<List<ArticuloModel>>();
    final latestSearch = Completer<List<ArticuloModel>>();
    service.initialList = initial.future;
    service.searches['taladro'] = latestSearch;

    final container = ProviderContainer(
      overrides: [articuloServiceProvider.overrideWith((ref) => service)],
    );
    addTearDown(container.dispose);

    final initialLoad = container.read(articulosListProvider.future);
    final search =
        container.read(articulosListProvider.notifier).buscar('taladro');

    initial.complete([_article(1, 'Lista inicial')]);
    latestSearch.complete([_article(2, 'Taladro')]);

    final loaded = await initialLoad;
    await search;

    expect(loaded.single.nombre, 'Taladro');
    expect(container.read(articulosListProvider).requireValue.single.nombre,
        'Taladro');
  });

  test('overlapping searches publish only the most recent result', () async {
    final service = _ArticuloServiceFake()
      ..initialList = Future.value(const []);
    final olderSearch = Completer<List<ArticuloModel>>();
    final newerSearch = Completer<List<ArticuloModel>>();
    service.searches['antiguo'] = olderSearch;
    service.searches['actual'] = newerSearch;

    final container = ProviderContainer(
      overrides: [articuloServiceProvider.overrideWith((ref) => service)],
    );
    addTearDown(container.dispose);
    await container.read(articulosListProvider.future);

    final notifier = container.read(articulosListProvider.notifier);
    final olderRequest = notifier.buscar('antiguo');
    final newerRequest = notifier.buscar('actual');

    newerSearch.complete([_article(2, 'Resultado actual')]);
    await newerRequest;
    olderSearch.complete([_article(1, 'Resultado antiguo')]);
    await olderRequest;

    expect(container.read(articulosListProvider).requireValue.single.nombre,
        'Resultado actual');
  });

  test('refresh preserves the current list while loading', () async {
    final service = _ArticuloServiceFake()
      ..initialList = Future.value([_article(1, 'Artículo actual')]);
    final container = ProviderContainer(
      overrides: [articuloServiceProvider.overrideWith((ref) => service)],
    );
    addTearDown(container.dispose);
    await container.read(articulosListProvider.future);

    final refreshed = Completer<List<ArticuloModel>>();
    service.initialList = refreshed.future;
    final request = container.read(articulosListProvider.notifier).refresh();

    final loadingState = container.read(articulosListProvider);
    expect(loadingState.isLoading, isTrue);
    expect(loadingState.requireValue.single.nombre, 'Artículo actual');

    refreshed.complete([_article(2, 'Artículo actualizado')]);
    await request;
    expect(container.read(articulosListProvider).requireValue.single.nombre,
        'Artículo actualizado');

    final failedRefresh = Completer<List<ArticuloModel>>();
    service.initialList = failedRefresh.future;
    final failedRequest =
        container.read(articulosListProvider.notifier).refresh();
    failedRefresh.completeError(StateError('Sin conexión'));
    await failedRequest;

    final failedState = container.read(articulosListProvider);
    expect(failedState.hasError, isTrue);
    expect(failedState.hasValue, isTrue);
    expect(failedState.requireValue.single.nombre, 'Artículo actualizado');
  });
}
