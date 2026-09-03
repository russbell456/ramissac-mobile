import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';
import 'package:sistema_ocs/features/almacen/articulos/articulo_detail_screen.dart';
import 'package:sistema_ocs/features/almacen/articulos/articulo_form_screen.dart';
import 'package:sistema_ocs/features/almacen/articulos/articulo_provider.dart';

class ArticulosListScreen extends ConsumerStatefulWidget {
  const ArticulosListScreen({super.key});

  @override
  ConsumerState<ArticulosListScreen> createState() => _ArticulosListScreenState();
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

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (value.trim().length >= 2) {
        ref.read(articulosListProvider.notifier).buscar(value.trim());
      } else {
        ref.read(articulosListProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final articulosAsync = ref.watch(articulosListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Artículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => ref.read(articulosListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: AppTheme.inputDecoration.copyWith(
                hintText: 'Buscar por nombre, código o serie...',
                prefixIcon: const Icon(LucideIcons.search),
              ),
            ),
          ),
          Expanded(
            child: articulosAsync.when(
              data: (articulos) => _buildList(articulos),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => _buildError(err),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Nuevo Artículo'),
      ),
    );
  }

  Widget _buildList(List<ArticuloModel> articulos) {
    if (articulos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.packageX, size: 72, color: AppTheme.textDisabled),
            const SizedBox(height: AppTheme.spacingL),
            const Text(
              'No hay artículos registrados',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingS),
            const Text(
              'Toca el botón + para crear uno nuevo',
              style: AppTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingL, 0, AppTheme.spacingL, 80),
      itemCount: articulos.length,
      itemBuilder: (context, index) {
        final articulo = articulos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: _ArticuloCard(
            articulo: articulo,
            onTap: () => _openDetail(articulo),
            onToggleActivo: () => _toggleActivo(articulo),
          ),
        );
      },
    );
  }

  Widget _buildError(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.alertCircle, size: 64, color: AppTheme.error),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              '$err',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.error),
            ),
            const SizedBox(height: AppTheme.spacingL),
            AppButton(
              text: 'Reintentar',
              icon: Icons.refresh,
              onPressed: () =>
                  ref.read(articulosListProvider.notifier).refresh(),
            ),
          ],
        ),
      ),
    );
  }

  void _openForm({ArticuloModel? articulo}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ArticuloFormScreen(articulo: articulo),
      ),
    );
    if (result == true) {
      ref.read(articulosListProvider.notifier).refresh();
    }
  }

  void _openDetail(ArticuloModel articulo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticuloDetailScreen(articulo: articulo),
      ),
    );
    ref.read(articulosListProvider.notifier).refresh();
  }

  Future<void> _toggleActivo(ArticuloModel articulo) async {
    final notifier = ref.read(articulosListProvider.notifier);
    try {
      if (articulo.activo) {
        await notifier.desactivar(articulo.id);
        _mostrarSnack('Artículo desactivado');
      } else {
        await notifier.activar(articulo.id);
        _mostrarSnack('Artículo activado');
      }
    } catch (e) {
      _mostrarSnack('Error: $e', isError: true);
    }
  }

  void _mostrarSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
      ),
    );
  }
}

class _ArticuloCard extends StatelessWidget {
  final ArticuloModel articulo;
  final VoidCallback onTap;
  final VoidCallback onToggleActivo;

  const _ArticuloCard({
    required this.articulo,
    required this.onTap,
    required this.onToggleActivo,
  });

  @override
  Widget build(BuildContext context) {
    final esEquipo = articulo.esEquipo;

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: AppTheme.borderRadiusMedium,
            ),
            child: Icon(
              esEquipo ? LucideIcons.laptop : LucideIcons.package,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: AppTheme.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        articulo.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.titleMedium,
                      ),
                    ),
                    if (!articulo.activo)
                      const AppBadge(text: 'Inactivo', color: AppTheme.error),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Wrap(
                  spacing: AppTheme.spacingS,
                  runSpacing: AppTheme.spacingXS,
                  children: [
                    if (articulo.codigoExcel != null &&
                        articulo.codigoExcel!.isNotEmpty)
                      Text('Código: ${articulo.codigoExcel}',
                          style: AppTheme.bodySmall),
                    if (articulo.serie != null && articulo.serie!.isNotEmpty)
                      Text('Serie: ${articulo.serie}',
                          style: AppTheme.bodySmall),
                    if (articulo.unidadMedida != null)
                      Text(articulo.unidadMedida!,
                          style: AppTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          _stockChip(),
          IconButton(
            icon: Icon(
              articulo.activo ? LucideIcons.eyeOff : LucideIcons.eye,
              size: AppTheme.iconSizeMedium,
            ),
            onPressed: onToggleActivo,
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  Widget _stockChip() {
    final color = articulo.stockActual > 0 ? AppTheme.success : AppTheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppTheme.borderRadiusSmall,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '${articulo.stockActual}',
        style: AppTheme.labelSmall.copyWith(color: color),
      ),
    );
  }
}
