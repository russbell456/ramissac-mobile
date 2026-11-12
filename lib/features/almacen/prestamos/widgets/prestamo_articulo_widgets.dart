import 'package:flutter/material.dart';
import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';

class PrestamoArticuloCard extends StatelessWidget {
  final String nombre;
  final String? codigo;
  final int stock;
  final String tipo;
  final String unidadMedida;
  final bool habilitado;
  final VoidCallback onTap;

  const PrestamoArticuloCard({
    super.key,
    required this.nombre,
    required this.codigo,
    required this.stock,
    required this.onTap,
    this.tipo = '',
    this.unidadMedida = '',
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final disponible = habilitado && stock > 0;
    final icon = switch (tipo.toUpperCase()) {
      'EQUIPO' => Icons.precision_manufacturing_outlined,
      'HERRAMIENTA' => Icons.handyman_outlined,
      _ => Icons.inventory_2_outlined,
    };
    return RamisCard(
      onTap: disponible ? onTap : null,
      padding: const EdgeInsets.all(RamisSpacing.mediumSmall),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: RamisRadius.medium,
          ),
          child: Icon(icon, color: scheme.primary),
        ),
        const SizedBox(width: RamisSpacing.mediumSmall),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: RamisSpacing.xSmall),
            Text('CÓD. ${codigo?.isNotEmpty == true ? codigo : 'Sin código'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: context.ramis.textSecondary)),
            const SizedBox(height: RamisSpacing.small),
            RamisStatusChip(
              label: disponible
                  ? '$stock $unidadMedida disponibles'.trim()
                  : 'No disponible',
              status: disponible ? RamisStatus.approved : RamisStatus.cancelled,
            ),
          ],
        )),
        const SizedBox(width: RamisSpacing.xSmall),
        IconButton.filledTonal(
          tooltip: 'Seleccionar $nombre',
          onPressed: disponible ? onTap : null,
          icon: const Icon(Icons.add_rounded),
        ),
      ]),
    );
  }
}

// The existing selector is hosted in a modal sheet; its result remains an int.
class PrestamoCantidadDialog extends StatefulWidget {
  final String nombre;
  final int stockDisponible;

  const PrestamoCantidadDialog({
    super.key,
    required this.nombre,
    required this.stockDisponible,
  });

  @override
  State<PrestamoCantidadDialog> createState() => _PrestamoCantidadDialogState();
}

class _PrestamoCantidadDialogState extends State<PrestamoCantidadDialog> {
  int _cantidad = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valida = _cantidad >= 1 && _cantidad <= widget.stockDisponible;
    return SafeArea(
        child: SingleChildScrollView(
      padding: RamisSpacing.screenPadding,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Agregar al préstamo',
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.primary)),
        const SizedBox(height: RamisSpacing.small),
        Text(widget.nombre,
            textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
        const SizedBox(height: RamisSpacing.small),
        Text('${widget.stockDisponible} unidades disponibles para agregar',
            textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
        const SizedBox(height: RamisSpacing.xLarge),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton.filledTonal(
            tooltip: 'Reducir cantidad',
            onPressed: _cantidad > 1 ? () => setState(() => _cantidad--) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          const SizedBox(width: RamisSpacing.xLarge),
          Semantics(
              liveRegion: true,
              label: 'Cantidad seleccionada',
              child: Text('$_cantidad', style: theme.textTheme.headlineMedium)),
          const SizedBox(width: RamisSpacing.xLarge),
          IconButton.filledTonal(
            tooltip: 'Aumentar cantidad',
            onPressed: _cantidad < widget.stockDisponible
                ? () => setState(() => _cantidad++)
                : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ]),
        const SizedBox(height: RamisSpacing.xLarge),
        RamisButton(
          label: 'Agregar al carrito',
          icon: Icons.add_shopping_cart_outlined,
          fullWidth: true,
          onPressed: valida ? () => Navigator.of(context).pop(_cantidad) : null,
        ),
        const SizedBox(height: RamisSpacing.small),
        RamisButton(
            label: 'Cancelar',
            variant: RamisButtonVariant.text,
            onPressed: () => Navigator.of(context).pop()),
      ]),
    ));
  }
}
