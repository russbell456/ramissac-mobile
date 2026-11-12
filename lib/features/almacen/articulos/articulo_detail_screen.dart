import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';
import 'package:sistema_ocs/data/models/articulo_imagen_model.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';
import 'package:sistema_ocs/data/network/backend_url.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';
import 'package:sistema_ocs/features/almacen/articulos/articulo_provider.dart';
import 'package:sistema_ocs/features/almacen/articulos/articulo_form_screen.dart';
import 'package:sistema_ocs/features/almacen/articulos/widgets/articulo_detail_widgets.dart';

class ArticuloDetailScreen extends ConsumerStatefulWidget {
  final ArticuloModel articulo;

  const ArticuloDetailScreen({
    super.key,
    required this.articulo,
  });

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

  // =====================================================
  // OPERACIONES
  // =====================================================

  void _mostrarError(Object error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  Future<void> _recargarArticulo() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final actualizado = await ref
          .read(articulosListProvider.notifier)
          .obtenerArticulo(_articulo.id);

      if (!mounted) return;

      setState(() {
        _articulo = actualizado;
      });
    } catch (error) {
      _mostrarError(error);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _toggleActivo() async {
    if (_loading) return;

    // Protección de la regla de negocio original.
    if (_articulo.activo && _articulo.enPrestamo > 0) {
      return;
    }

    setState(() => _loading = true);

    try {
      final notifier = ref.read(articulosListProvider.notifier);

      final ArticuloModel actualizado;

      if (_articulo.activo) {
        actualizado = await notifier.desactivar(
          _articulo.id,
        );
      } else {
        actualizado = await notifier.activar(
          _articulo.id,
        );
      }

      if (!mounted) return;

      setState(() {
        _articulo = actualizado;
      });

      _mostrarMensaje(
        actualizado.activo ? 'Artículo activado' : 'Artículo desactivado',
      );
    } catch (error) {
      _mostrarError(error);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _editar() async {
    if (_loading) return;

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ArticuloFormScreen(
          articulo: _articulo,
        ),
      ),
    );

    if (!mounted) return;

    if (resultado == true) {
      await _recargarArticulo();
    }
  }

  Future<void> _eliminarImagen(
    ArticuloImagenModel imagen,
  ) async {
    if (_loading) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar imagen'),
          content: const Text(
            '¿Deseas eliminar esta imagen?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmar != true || _loading) {
      return;
    }

    setState(() => _loading = true);

    try {
      final notifier = ref.read(articulosListProvider.notifier);

      await notifier.eliminarImagen(imagen.id);

      // Recargamos directamente sin iniciar otra operación
      // de loading sobre la que ya está en progreso.
      final actualizado = await notifier.obtenerArticulo(
        _articulo.id,
      );

      if (!mounted) return;

      setState(() {
        _articulo = actualizado;
      });

      _mostrarMensaje('Imagen eliminada correctamente');
    } catch (error) {
      _mostrarError(error);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // =====================================================
  // HELPERS
  // =====================================================

  String get _tipoLabel {
    switch (_articulo.tipo.toUpperCase()) {
      case 'EQUIPO':
        return 'Equipo';
      case 'HERRAMIENTA':
        return 'Herramienta';
      case 'CONSUMIBLE':
        return 'Consumible';
      default:
        return _articulo.tipo;
    }
  }

  IconData get _tipoIcon {
    switch (_articulo.tipo.toUpperCase()) {
      case 'EQUIPO':
        return Icons.precision_manufacturing_outlined;
      case 'HERRAMIENTA':
        return Icons.handyman_outlined;
      case 'CONSUMIBLE':
        return Icons.inventory_2_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  String _formatMoney(double? value) {
    if (value == null) return 'No definido';
    return 'S/ ${value.toStringAsFixed(2)}';
  }

  String _imageUrl(String ruta) {
    return buildBackendUrl(ref.read(dioProvider), ruta);
  }

  // =====================================================
  // SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return RamisScaffold(
      appBar: RamisAppBar(
        title: 'Detalle del artículo',
        showBackButton: true,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _loading ? null : _recargarArticulo,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Editar',
            onPressed: _loading ? null : _editar,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _recargarArticulo,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                32,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 760,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 12),
                        _buildAlerts(),
                        _buildInformation(),
                        const SizedBox(height: 12),
                        _buildStock(),
                        const SizedBox(height: 12),
                        _buildCosts(),
                        const SizedBox(height: 12),
                        _buildState(),
                        const SizedBox(height: 12),
                        _buildImages(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_loading)
            Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: Theme.of(context)
                      .colorScheme
                      .scrim
                      .withValues(alpha: 0.22),
                  child: const RamisLoading(
                    label: 'Procesando...',
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return RamisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: RamisRadius.large,
                ),
                child: Icon(
                  _tipoIcon,
                  size: 30,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _articulo.nombre,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _tipoLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.ramis.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RamisStatusChip(
                      label: _articulo.activo ? 'Activo' : 'Inactivo',
                      status: _articulo.activo
                          ? RamisStatus.completed
                          : RamisStatus.cancelled,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ALERTAS
  // =====================================================

  Widget _buildAlerts() {
    final alerts = <Widget>[];

    if (_articulo.esActivoAltoValor) {
      alerts.add(
        const ArticuloInfoBanner(
          icon: Icons.star_outline_rounded,
          title: 'Activo de alto valor',
          message: 'Este artículo requiere mayor control.',
          severity: ArticuloBannerSeverity.warning,
        ),
      );
    }

    if (_articulo.enPrestamo > 0) {
      alerts.add(
        ArticuloInfoBanner(
          icon: Icons.assignment_return_outlined,
          title: 'Artículo en préstamo',
          message: 'Actualmente hay ${_articulo.enPrestamo} '
              'unidad(es) en préstamo. No puede desactivarse '
              'mientras tenga unidades prestadas.',
          severity: ArticuloBannerSeverity.warning,
        ),
      );
    }

    if (_articulo.esConsumible) {
      alerts.add(
        const ArticuloInfoBanner(
          icon: Icons.info_outline_rounded,
          title: 'Consumible',
          message: 'Este artículo corresponde a un consumible '
              'y no forma parte del flujo de devolución.',
          severity: ArticuloBannerSeverity.info,
        ),
      );
    }

    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < alerts.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            alerts[i],
          ],
        ],
      ),
    );
  }

  // =====================================================
  // INFORMACIÓN
  // =====================================================

  Widget _buildInformation() {
    return ArticuloDetailSection(
      title: 'Información',
      icon: Icons.info_outline_rounded,
      children: [
        ArticuloDetailRow(
          label: 'Nombre',
          value: _articulo.nombre,
        ),
        ArticuloDetailRow(
          label: 'Marca',
          value: _articulo.marca,
        ),
        ArticuloDetailRow(
          label: 'Modelo',
          value: _articulo.modelo,
        ),
        ArticuloDetailRow(
          label: 'Categoría',
          value: _articulo.categoria,
        ),
        ArticuloDetailRow(
          label: 'Descripción',
          value: _articulo.descripcion,
        ),
        ArticuloDetailRow(
          label: 'Código Excel',
          value: _articulo.codigoExcel,
        ),
        ArticuloDetailRow(
          label: 'Serie',
          value: _articulo.serie,
        ),
        ArticuloDetailRow(
          label: 'Unidad de medida',
          value: _articulo.unidadMedida,
        ),
        ArticuloDetailRow(
          label: 'Tipo',
          value: _tipoLabel,
        ),
      ],
    );
  }

  // =====================================================
  // STOCK
  // =====================================================

  Widget _buildStock() {
    return ArticuloDetailSection(
      title: 'Stock',
      icon: Icons.inventory_2_outlined,
      children: [
        ArticuloDetailRow(
          label: 'Stock total',
          value: '${_articulo.stockTotal}',
        ),
        ArticuloDetailRow(
          label: 'Stock actual',
          value: '${_articulo.stockActual}',
        ),
        ArticuloDetailRow(
          label: 'En préstamo',
          value: '${_articulo.enPrestamo}',
        ),
      ],
    );
  }

  // =====================================================
  // COSTOS
  // =====================================================

  Widget _buildCosts() {
    return ArticuloDetailSection(
      title: 'Costos',
      icon: Icons.payments_outlined,
      children: [
        ArticuloDetailRow(
          label: 'Costo por hora',
          value: _formatMoney(_articulo.costoHora),
        ),
        ArticuloDetailRow(
          label: 'Costo por día',
          value: _formatMoney(_articulo.costoDia),
        ),
        ArticuloDetailRow(
          label: 'Costo de reposición',
          value: _formatMoney(_articulo.costoReposicion),
        ),
      ],
    );
  }

  // =====================================================
  // ESTADO
  // =====================================================

  Widget _buildState() {
    return ArticuloDetailSection(
      title: 'Estado y controles',
      icon: Icons.fact_check_outlined,
      children: [
        ArticuloDetailRow(
          label: 'Estado físico',
          value: _articulo.estadoFisico,
        ),
        ArticuloDetailRow(
          label: 'Activo de alto valor',
          value: _articulo.esActivoAltoValor ? 'Sí' : 'No',
        ),
        ArticuloDetailRow(
          label: 'Foto en préstamo',
          value: _articulo.requiereFotoPrestamo ? 'Sí' : 'No',
        ),
        ArticuloDetailRow(
          label: 'Foto en devolución',
          value: _articulo.requiereFotoDevolucion ? 'Sí' : 'No',
        ),
      ],
    );
  }

  // =====================================================
  // IMÁGENES
  // =====================================================

  Widget _buildImages() {
    return ArticuloDetailSection(
      title: 'Imágenes',
      icon: Icons.photo_library_outlined,
      children: [
        if (_articulo.imagenes.isEmpty)
          Text(
            'Este artículo todavía no tiene imágenes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.ramis.textSecondary,
                ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 500 ? 3 : 2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _articulo.imagenes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final imagen = _articulo.imagenes[index];

                  return ArticuloImageTile(
                    imageUrl: _imageUrl(imagen.ruta),
                    onDelete: _loading ? null : () => _eliminarImagen(imagen),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  // =====================================================
  // ACCIÓN INFERIOR
  // =====================================================

  Widget _buildBottomAction(BuildContext context) {
    final theme = Theme.of(context);
    final canDeactivate = !_articulo.activo || _articulo.enPrestamo == 0;

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10,
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 760,
            ),
            child: RamisButton(
              label:
                  _articulo.activo ? 'Desactivar artículo' : 'Activar artículo',
              icon: _articulo.activo
                  ? Icons.visibility_off_outlined
                  : Icons.check_circle_outline_rounded,
              variant: _articulo.activo
                  ? RamisButtonVariant.destructive
                  : RamisButtonVariant.primary,
              fullWidth: true,
              isLoading: _loading,
              onPressed: !_loading && canDeactivate ? _toggleActivo : null,
            ),
          ),
        ),
      ),
    );
  }
}
