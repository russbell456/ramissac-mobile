import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sistema_ocs/features/almacen/prestamos/screens/carrito_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';
import 'package:sistema_ocs/features/almacen/prestamos/providers/articulo_provider.dart';
import 'package:sistema_ocs/features/almacen/prestamos/providers/carrito_provider.dart';
import 'package:sistema_ocs/features/almacen/prestamos/screens/articulos_disponibles_screen.dart';
import 'package:sistema_ocs/features/almacen/prestamos/widgets/prestamo_articulo_widgets.dart';

Map<String, dynamic> article(int id, {int stock = 3, bool active = true}) => {
      'id': id,
      'nombre': 'Taladro $id',
      'codigo_excel': 'EQ-$id',
      'tipo': 'EQUIPO',
      'unidad_medida': 'UND',
      'stock_total': stock,
      'stock_actual': stock,
      'activo': active,
    };

void main() {
  setUpAll(() async {
    final inter = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'));
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await inter.load();
    await icons.load();
  });
  test('remote debounce, latest response, clear and retry', () async {
    final dio = Dio();
    final requests = <String, ResponseInterceptorHandler>{};
    final seen = <String>[];
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      final q = options.queryParameters['q'] as String? ?? '';
      seen.add(q);
      handler.resolve(
          Response(requestOptions: options, data: [article(q.length)]), true);
    }, onResponse: (response, handler) {
      requests[response.requestOptions.queryParameters['q'] as String? ?? ''] =
          handler;
    }));
    final container =
        ProviderContainer(overrides: [dioProvider.overrideWithValue(dio)]);
    addTearDown(container.dispose);
    final sub = container.listen(articulosProvider, (_, __) {});
    addTearDown(sub.close);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(seen, ['']);
    container.read(busquedaArticulosProvider.notifier).state = 'ta';
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    container.read(busquedaArticulosProvider.notifier).state = 'taladro';
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await Future<void>.delayed(const Duration(milliseconds: 250));
    expect(seen, ['']);
    await Future<void>.delayed(const Duration(milliseconds: 180));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(seen, ['', 'taladro']);
    requests['taladro']!.next(Response(
        requestOptions: RequestOptions(path: '/articulo/disponibles'),
        data: [article(7)]));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(container.read(articulosProvider).requireValue.single.id, 7);
    requests['']!.next(Response(
        requestOptions: RequestOptions(path: '/articulo/disponibles'),
        data: [article(0)]));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(container.read(articulosProvider).requireValue.single.id, 7);
    container.read(busquedaArticulosProvider.notifier).state = '';
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(seen, ['', 'taladro', '']);
    requests['']!.reject(DioException(
        requestOptions: RequestOptions(path: '/articulo/disponibles')));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(container.read(articulosProvider).hasError, true);
    container.invalidate(articulosProvider);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(seen.length, 4);
  });

  for (final dark in [false, true]) {
    testWidgets(
        '450 articles, selection and cart in ${dark ? 'dark' : 'light'}',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      FlutterSecureStorage.setMockInitialValues({'user_role': 'trabajador'});
      var catalogRequests = 0;
      final dio = Dio()
        ..interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
          if (o.path != '/articulo/disponibles') {
            h.resolve(Response(requestOptions: o, data: []));
            return;
          }
          catalogRequests++;
          h.resolve(Response(
              requestOptions: o, data: List.generate(450, (i) => article(i))));
        }));
      final container =
          ProviderContainer(overrides: [dioProvider.overrideWithValue(dio)]);
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
              theme: dark ? RamisTheme.dark : RamisTheme.light,
              home: const RepaintBoundary(
                  key: ValueKey('catalog-capture'),
                  child: ArticulosDisponiblesScreen()))));
      await tester.pumpAndSettle();
      expect(find.byType(PrestamoArticuloCard).evaluate().length, lessThan(15));
      expect(find.text('Taladro 449'), findsNothing);
      final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('catalog-capture')));
      await tester.runAsync(() async {
        final capture = await boundary.toImage(pixelRatio: 1);
        final png = await capture.toByteData(format: ui.ImageByteFormat.png);
        final file = File('build/catalogo_${dark ? 'dark' : 'light'}.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(png!.buffer.asUint8List());
        capture.dispose();
      });

      await tester.tap(find.byTooltip('Seleccionar Taladro 0'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Aumentar cantidad'));
      await tester.tap(find.byTooltip('Aumentar cantidad'));
      await tester.pump();
      final plus = tester.widget<IconButton>(find.byWidgetPredicate(
          (w) => w is IconButton && w.tooltip == 'Aumentar cantidad'));
      expect(plus.onPressed, isNull);
      await tester.tap(find.text('Agregar al carrito'));
      await tester.pumpAndSettle();
      expect(container.read(carritoProvider).single.cantidad, 3);
      expect(find.text('Carrito (1)'), findsOneWidget);
      await tester.tap(find.byTooltip('Seleccionar Taladro 0'));
      await tester.pumpAndSettle();
      expect(find.byType(PrestamoCantidadDialog), findsNothing);
      await tester.scrollUntilVisible(find.text('Taladro 449'), 700,
          maxScrolls: 120,
          scrollable: find.descendant(
              of: find.byType(ListView), matching: find.byType(Scrollable)));
      expect(find.text('Taladro 449'), findsOneWidget);
      await tester.tap(find.text('Carrito (1)'));
      await tester.pumpAndSettle();
      expect(find.byType(CarritoScreen), findsOneWidget);
      Navigator.of(tester.element(find.byType(CarritoScreen))).pop();
      await tester.pumpAndSettle();
      expect(catalogRequests, 2);
      expect(container.read(carritoProvider).single.cantidad, 3);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('zero stock disables selection and quantity confirmation',
      (tester) async {
    var selected = false;
    await tester.pumpWidget(MaterialApp(
        theme: RamisTheme.light,
        home: Scaffold(
            body: Column(children: [
          PrestamoArticuloCard(
              nombre: 'Sin stock',
              codigo: null,
              stock: 0,
              onTap: () => selected = true),
          const PrestamoCantidadDialog(nombre: 'Sin stock', stockDisponible: 0),
        ]))));
    await tester.tap(find.text('Sin stock').first);
    expect(selected, false);
    expect(
        tester
            .widget<RamisButton>(
                find.widgetWithText(RamisButton, 'Agregar al carrito'))
            .onPressed,
        isNull);
  });
}
