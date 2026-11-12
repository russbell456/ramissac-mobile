import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';
import 'package:sistema_ocs/features/almacen/articulos/articulo_provider.dart';
import 'package:sistema_ocs/features/almacen/articulos/articulo_detail_screen.dart';
import 'package:sistema_ocs/features/almacen/articulos/articulo_form_screen.dart';
import 'package:sistema_ocs/features/almacen/articulos/widgets/articulo_list_card.dart';

class ArticulosListScreen extends ConsumerStatefulWidget {
  const ArticulosListScreen({super.key});

  @override
  ConsumerState<ArticulosListScreen> createState() =>
      _ArticulosListScreenState();
}

class _ArticulosListScreenState extends ConsumerState<ArticulosListScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // BÚSQUEDA
  // =====================================================

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    // Actualiza el botón para limpiar la búsqueda.
    setState(() {});

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () {
        if (!mounted) return;

        final query = _searchController.text.trim();

        if (query.length < 2) {
          _refresh();
        } else {
          ref.read(articulosListProvider.notifier).buscar(query);
        }
      },
    );
  }

  void _limpiarBusqueda() {
    _debounce?.cancel();
    _searchController.clear();

    setState(() {});

    _refresh();
  }

  Future<void> _refresh() {
    return ref.read(articulosListProvider.notifier).refresh();
  }

  // =====================================================
  // NAVEGACIÓN
  // =====================================================

  Future<void> _nuevoArticulo() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const ArticuloFormScreen(),
      ),
    );

    if (!mounted || resultado != true) return;

    // The notifier refreshes the shared list after a successful mutation.
    // Retry here only if that refresh failed, avoiding a second GET on success.
    if (ref.read(articulosListProvider).hasError) {
      await _refresh();
    }
  }

  Future<void> _abrirDetalle(
    ArticuloModel articulo,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticuloDetailScreen(
          articulo: articulo,
        ),
      ),
    );
  }

  // =====================================================
  // SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articulosListProvider);
    final scheme = Theme.of(context).colorScheme;

    return RamisScaffold(
      appBar: RamisAppBar(
        title: 'Artículos',
        showBackButton: true,
        actions: [
          IconButton(
            tooltip: 'Actualizar artículos',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchHeader(context),
          Expanded(
            child: state.when(
              loading: () => const RamisLoading(
                label: 'Cargando artículos...',
              ),
              error: (error, stackTrace) {
                return RamisErrorView(
                  title: 'No se pudieron cargar los artículos',
                  description: error.toString(),
                  onRetry: _refresh,
                  retryLabel: 'Reintentar',
                );
              },
              data: (articulos) {
                if (articulos.isEmpty) {
                  return RamisEmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'No hay artículos',
                    description: _searchController.text.trim().isNotEmpty
                        ? 'No hay artículos para la búsqueda actual.'
                        : 'Registra un artículo para comenzar.',
                    actionLabel: 'Actualizar',
                    onAction: _refresh,
                  );
                }

                return _buildArticlesList(articulos);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoArticulo,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo artículo'),
      ),
    );
  }

  // =====================================================
  // HEADER DE BÚSQUEDA
  // =====================================================

  Widget _buildSearchHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(
        RamisSpacing.medium,
        RamisSpacing.medium,
        RamisSpacing.medium,
        RamisSpacing.small,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventario de artículos',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Consulta los equipos, herramientas y consumibles.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.ramis.textSecondary,
                ),
              ),
              const SizedBox(height: RamisSpacing.medium),
              RamisTextField(
                controller: _searchController,
                hint: 'Buscar artículo...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                ),
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar búsqueda',
                        onPressed: _limpiarBusqueda,
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // LISTADO
  // =====================================================

  Widget _buildArticlesList(
    List<ArticuloModel> articulos,
  ) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          RamisSpacing.medium,
          RamisSpacing.medium,
          RamisSpacing.medium,
          112,
        ),
        itemCount: articulos.length,
        separatorBuilder: (_, __) => const SizedBox(height: RamisSpacing.small),
        itemBuilder: (context, index) {
          final articulo = articulos[index];

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 760,
              ),
              child: ArticuloListCard(
                articulo: articulo,
                onTap: () => _abrirDetalle(articulo),
              ),
            ),
          );
        },
      ),
    );
  }
}
