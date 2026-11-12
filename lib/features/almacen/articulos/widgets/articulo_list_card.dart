
import 'package:flutter/material.dart';

import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';

class ArticuloListCard extends StatelessWidget {
  final ArticuloModel articulo;
  final VoidCallback onTap;

  const ArticuloListCard({
    super.key,
    required this.articulo,
    required this.onTap,
  });

  String get _tipoLabel {
    switch (articulo.tipo.toUpperCase()) {
      case 'EQUIPO':
        return 'Equipo';
      case 'HERRAMIENTA':
        return 'Herramienta';
      case 'CONSUMIBLE':
        return 'Consumible';
      default:
        return articulo.tipo;
    }
  }

  IconData get _tipoIcon {
    switch (articulo.tipo.toUpperCase()) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return RamisCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ENCABEZADO
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: RamisRadius.medium,
                ),
                child: Icon(
                  _tipoIcon,
                  color: scheme.onPrimaryContainer,
                  size: 26,
                ),
              ),

              const SizedBox(width: RamisSpacing.medium),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      articulo.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _tipoLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.ramis.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
                size: 24,
              ),
            ],
          ),

          const SizedBox(height: RamisSpacing.medium),

          // CÓDIGOS Y CARACTERÍSTICAS
          Wrap(
            spacing: 6,
            runSpacing: 8,
            children: [
              if (articulo.codigoExcel != null &&
                  articulo.codigoExcel!.isNotEmpty)
                _ArticuloInfoChip(
                  icon: Icons.qr_code_rounded,
                  label: articulo.codigoExcel!,
                ),

              if (articulo.serie != null &&
                  articulo.serie!.isNotEmpty)
                _ArticuloInfoChip(
                  icon: Icons.tag_rounded,
                  label: articulo.serie!,
                ),

              if (articulo.enPrestamo > 0)
                const _ArticuloInfoChip(
                  icon: Icons.assignment_return_outlined,
                  label: 'En préstamo',
                ),

              if (articulo.esActivoAltoValor)
                const _ArticuloInfoChip(
                  icon: Icons.star_outline_rounded,
                  label: 'Alto valor',
                ),
            ],
          ),

          const SizedBox(height: RamisSpacing.medium),

          Divider(
            height: 1,
            color: context.ramis.border,
          ),

          const SizedBox(height: RamisSpacing.medium),

          // STOCK Y ESTADO
          Row(
            children: [
              Expanded(
                child: _ArticuloStock(
                  actual: articulo.stockActual,
                  total: articulo.stockTotal,
                ),
              ),

              const SizedBox(width: 8),

              RamisStatusChip(
                label: articulo.activo ? 'Activo' : 'Inactivo',
                status: articulo.activo
                    ? RamisStatus.completed
                    : RamisStatus.cancelled,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================
// CHIP INFORMATIVO
// =====================================================

class _ArticuloInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ArticuloInfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: RamisRadius.small,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: scheme.onSurfaceVariant,
          ),

          const SizedBox(width: 5),

          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 170,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// STOCK
// =====================================================

class _ArticuloStock extends StatelessWidget {
  final int actual;
  final int total;

  const _ArticuloStock({
    required this.actual,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final disponible = actual > 0;

    final accent = disponible
        ? scheme.primary
        : scheme.error;

    final icon = disponible
        ? Icons.inventory_2_outlined
        : Icons.production_quantity_limits_rounded;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 19,
          color: accent,
        ),

        const SizedBox(width: 8),

        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stock disponible',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: context.ramis.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$actual / $total',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
