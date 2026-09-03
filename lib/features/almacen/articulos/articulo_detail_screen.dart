import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';
import 'package:sistema_ocs/features/almacen/articulos/articulo_form_screen.dart';
import 'package:sistema_ocs/features/almacen/articulos/articulo_provider.dart';

class ArticuloDetailScreen extends ConsumerStatefulWidget {
  final ArticuloModel articulo;

  const ArticuloDetailScreen({super.key, required this.articulo});

  @override
  ConsumerState<ArticuloDetailScreen> createState() =>
      _ArticuloDetailScreenState();
}

class _ArticuloDetailScreenState extends ConsumerState<ArticuloDetailScreen> {
  late ArticuloModel _articulo;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _articulo = widget.articulo;
  }

  Future<void> _toggleActivo() async {
    setState(() => _loading = true);
    try {
      final notifier = ref.read(articulosListProvider.notifier);
      if (_articulo.activo) {
        await notifier.desactivar(_articulo.id);
      } else {
        await notifier.activar(_articulo.id);
      }
      if (!mounted) return;
      setState(() {
        _articulo = ArticuloModel(
          id: _articulo.id,
          nombre: _articulo.nombre,
          unidadMedida: _articulo.unidadMedida,
          tipo: _articulo.tipo,
          stockActual: _articulo.stockActual,
          stockTotal: _articulo.stockTotal,
          codigoExcel: _articulo.codigoExcel,
          serie: _articulo.serie,
          activo: !_articulo.activo,
          enPrestamo: _articulo.enPrestamo,
          imagenes: _articulo.imagenes,
        );
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
      );
    }
  }

  Future<void> _editar() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ArticuloFormScreen(articulo: _articulo)),
    );
    if (result == true) {
      ref.read(articulosListProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEquipo = _articulo.esEquipo;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Detalle de Artículo'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil),
            tooltip: 'Editar',
            onPressed: _editar,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        children: [
          _headerCard(esEquipo),
          const SizedBox(height: AppTheme.spacingL),
          _infoCard(),
          const SizedBox(height: AppTheme.spacingL),
          if (_articulo.imagenes.isNotEmpty) _imagenesCard(),
          const SizedBox(height: AppTheme.spacingL),
          if (_articulo.enPrestamo > 0) _prestamoWarning(),
          const SizedBox(height: AppTheme.spacingXXXL),
          AppButton(
            text: _articulo.activo ? 'Desactivar artículo' : 'Activar artículo',
            icon: _articulo.activo ? LucideIcons.eyeOff : LucideIcons.eye,
            isFullWidth: true,
            backgroundColor: _articulo.activo ? AppTheme.error : AppTheme.success,
            onPressed: _loading ? () {} : _toggleActivo,
          ),
        ],
      ),
    );
  }

  Widget _headerCard(bool esEquipo) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: AppTheme.borderRadiusMedium,
                ),
                child: Icon(
                  esEquipo ? LucideIcons.laptop : LucideIcons.package,
                  color: AppTheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppTheme.spacingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_articulo.nombre, style: AppTheme.headlineSmall),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      esEquipo ? 'EQUIPO' : 'INSUMO',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              AppBadge(
                text: _articulo.activo ? 'Activo' : 'Inactivo',
                color: _articulo.activo ? AppTheme.success : AppTheme.error,
                isUpperCase: false,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXL),
          Row(
            children: [
              Expanded(
                child: _metric(
                  label: 'Stock Actual',
                  value: '${_articulo.stockActual}',
                  icon: LucideIcons.boxes,
                  color: AppTheme.success,
                ),
              ),
              Expanded(
                child: _metric(
                  label: 'Stock Total',
                  value: '${_articulo.stockTotal}',
                  icon: LucideIcons.box,
                  color: AppTheme.info,
                ),
              ),
              if (_articulo.enPrestamo > 0)
                Expanded(
                  child: _metric(
                    label: 'En Préstamo',
                    value: '${_articulo.enPrestamo}',
                    icon: LucideIcons.hand,
                    color: AppTheme.warning,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Información', style: AppTheme.titleMedium),
          const SizedBox(height: AppTheme.spacingM),
          _infoRow(LucideIcons.barcode, 'Código',
              _articulo.codigoExcel?.isNotEmpty == true
                  ? _articulo.codigoExcel!
                  : '—'),
          const Divider(height: AppTheme.spacingXL),
          _infoRow(LucideIcons.hash, 'Número de serie',
              _articulo.serie?.isNotEmpty == true ? _articulo.serie! : '—'),
          const Divider(height: AppTheme.spacingXL),
          _infoRow(
              LucideIcons.ruler,
              'Unidad de medida',
              _articulo.unidadMedida?.isNotEmpty == true
                  ? _articulo.unidadMedida!
                  : '—'),
          const Divider(height: AppTheme.spacingXL),
          _infoRow(LucideIcons.package, 'Tipo',
              _articulo.esEquipo ? 'Equipo' : 'Insumo'),
        ],
      ),
    );
  }

  Widget _imagenesCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Imágenes (${_articulo.imagenes.length})',
              style: AppTheme.titleMedium),
          const SizedBox(height: AppTheme.spacingM),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _articulo.imagenes.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingM),
              itemBuilder: (context, index) {
                final img = _articulo.imagenes[index];
                return Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: AppTheme.borderRadiusMedium,
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: img.ruta.isNotEmpty
                      ? ClipRRect(
                          borderRadius: AppTheme.borderRadiusMedium,
                          child: Image.network(
                            img.ruta.startsWith('http')
                                ? img.ruta
                                : 'https://ramissac-api.sorbits.site${img.ruta}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(LucideIcons.image, size: 40),
                          ),
                        )
                      : const Icon(LucideIcons.image, size: 40),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _prestamoWarning() {
    return AppCard(
      backgroundColor: AppTheme.quantityBadgeBg,
      child: Row(
        children: [
          Icon(LucideIcons.alertTriangle, color: AppTheme.warning),
          const SizedBox(width: AppTheme.spacingM),
          const Expanded(
            child: Text(
              'Este artículo está en préstamo y no puede desactivarse.',
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: AppTheme.iconSizeMedium, color: AppTheme.primary),
        const SizedBox(width: AppTheme.spacingM),
        SizedBox(
          width: 130,
          child: Text(label, style: AppTheme.bodySmall),
        ),
        Expanded(
          child: Text(value, style: AppTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _metric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: AppTheme.spacingS),
        Text(value,
            style: AppTheme.headlineMedium.copyWith(color: color)),
        Text(label, style: AppTheme.labelSmall),
      ],
    );
  }
}
