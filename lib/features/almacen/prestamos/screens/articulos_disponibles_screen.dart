import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';
import '../providers/articulo_provider.dart';
import '../providers/carrito_provider.dart';
import '../widgets/prestamo_articulo_widgets.dart';
import 'carrito_screen.dart';

class ArticulosDisponiblesScreen extends ConsumerStatefulWidget {
  const ArticulosDisponiblesScreen({super.key});
  @override
  ConsumerState<ArticulosDisponiblesScreen> createState() =>
      _ArticulosDisponiblesScreenState();
}

class _ArticulosDisponiblesScreenState
    extends ConsumerState<ArticulosDisponiblesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    if (query == _searchQuery) return;
    setState(() => _searchQuery = query);
    ref.read(busquedaArticulosProvider.notifier).state = query;
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  int _restante(ArticuloModel articulo) {
    if (!articulo.activo || !articulo.tieneStock) return 0;
    final limite = articulo.esActivoAltoValor ? 1 : articulo.stockActual;
    final seleccionados = ref
        .read(carritoProvider)
        .where((item) => item.articulo.id == articulo.id)
        .fold<int>(0, (total, item) => total + item.cantidad);
    return math.max(0, limite - seleccionados);
  }

  Future<void> _seleccionarCantidad(ArticuloModel articulo) async {
    final disponible = _restante(articulo);
    if (disponible < 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sin unidades adicionales disponibles para el carrito.'),
      ));
      return;
    }
    final cantidad = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => PrestamoCantidadDialog(
        nombre: articulo.nombre,
        stockDisponible: disponible,
      ),
    );
    if (!mounted || cantidad == null) return;
    if (cantidad < 1 || cantidad > _restante(articulo)) return;
    ref.read(carritoProvider.notifier).agregar(articulo, cantidad);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$cantidad × ${articulo.nombre} agregado al carrito'),
    ));
  }

  Future<void> _abrirCarrito() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const CarritoScreen()));
    if (mounted) ref.invalidate(articulosProvider);
  }

  @override
  Widget build(BuildContext context) {
    final articulosAsync = ref.watch(articulosProvider);
    return RamisScaffold(
      appBar: const RamisAppBar(
          title: 'Catálogo de préstamos', showBackButton: true),
      body: Column(children: [
        _buildSearchHeader(),
        Expanded(
            child: articulosAsync.when(
          skipLoadingOnRefresh: false,
          skipLoadingOnReload: false,
          loading: () =>
              const RamisLoading(label: 'Consultando artículos disponibles...'),
          error: (error, stack) => RamisErrorView(
            title: 'No se pudieron cargar los artículos',
            description: 'Comprueba tu conexión y vuelve a intentarlo.',
            onRetry: () => ref.invalidate(articulosProvider),
          ),
          data: (articulos) {
            if (articulos.isEmpty) {
              return RamisEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No hay resultados',
                description: _searchQuery.isEmpty
                    ? 'No hay artículos disponibles para mostrar.'
                    : 'No se encontraron artículos disponibles con esa búsqueda.',
                actionLabel:
                    _searchQuery.isEmpty ? 'Actualizar' : 'Limpiar búsqueda',
                onAction: _searchQuery.isEmpty
                    ? () => ref.invalidate(articulosProvider)
                    : _clearSearch,
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(articulosProvider);
                await ref.read(articulosProvider.future);
              },
              child: ListView.separated(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(RamisSpacing.medium,
                    RamisSpacing.medium, RamisSpacing.medium, 100),
                itemCount: articulos.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: RamisSpacing.small),
                itemBuilder: (context, index) {
                  final articulo = articulos[index];
                  return Center(
                      child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: PrestamoArticuloCard(
                      key: ValueKey(articulo.id),
                      nombre: articulo.nombre,
                      codigo: articulo.codigoExcel,
                      stock: articulo.stockActual,
                      tipo: articulo.tipo,
                      unidadMedida: articulo.unidadMedida,
                      habilitado: articulo.activo && articulo.tieneStock,
                      onTap: () => _seleccionarCantidad(articulo),
                    ),
                  ));
                },
              ),
            );
          },
        )),
      ]),
      floatingActionButton: Consumer(builder: (context, ref, child) {
        final carrito = ref.watch(carritoProvider);
        if (carrito.isEmpty) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: _abrirCarrito,
          tooltip: 'Ver carrito de préstamos',
          icon: const Icon(Icons.shopping_cart_outlined),
          label: Text('Carrito (${carrito.length})'),
        );
      }),
    );
  }

  Widget _buildSearchHeader() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: RamisSpacing.screenPadding,
      decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(bottom: BorderSide(color: context.ramis.border))),
      child: Center(
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RAMIS · ALMACÉN',
              style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
          const SizedBox(height: RamisSpacing.small),
          Text('Todo listo para tu trabajo', style: theme.textTheme.titleLarge),
          const SizedBox(height: RamisSpacing.xSmall),
          Text(
              'Encuentra equipos, herramientas e insumos con stock disponible.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.ramis.textSecondary)),
          const SizedBox(height: RamisSpacing.medium),
          RamisTextField(
            controller: _searchController,
            label: 'Buscar artículos',
            hint: 'Nombre, código, serie, marca o modelo',
            prefixIcon: const Icon(Icons.search_rounded),
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpiar búsqueda',
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close_rounded)),
          ),
        ]),
      )),
    );
  }
}
