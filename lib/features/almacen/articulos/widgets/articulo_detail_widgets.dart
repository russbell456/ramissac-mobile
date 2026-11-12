
import 'package:flutter/material.dart';

import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';

// =====================================================
// SECCIÓN DE DETALLE
// =====================================================

class ArticuloDetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const ArticuloDetailSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return RamisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: RamisRadius.small,
                ),
                child: Icon(
                  icon,
                  color: scheme.onPrimaryContainer,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Divider(
            height: 1,
            color: context.ramis.border,
          ),

          const SizedBox(height: 16),

          ...children,
        ],
      ),
    );
  }
}

// =====================================================
// FILA DE INFORMACIÓN
// =====================================================

class ArticuloDetailRow extends StatelessWidget {
  final String label;
  final String? value;

  const ArticuloDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: context.ramis.textSecondary,
      fontWeight: FontWeight.w500,
    );

    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // En celulares estrechos y con escalado de texto,
          // mostramos etiqueta y valor verticalmente.
          final vertical =
              constraints.maxWidth < 360 ||
              MediaQuery.textScalerOf(context).scale(14) > 18;

          if (vertical) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(height: 4),
                SelectableText(
                  value!,
                  style: valueStyle,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                child: Text(
                  label,
                  style: labelStyle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SelectableText(
                  value!,
                  style: valueStyle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =====================================================
// ALERTAS DE ARTÍCULOS
// =====================================================

enum ArticuloBannerSeverity {
  info,
  warning,
  error,
}

class ArticuloInfoBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final ArticuloBannerSeverity severity;

  const ArticuloInfoBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.severity = ArticuloBannerSeverity.info,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final Color accent;

    switch (severity) {
      case ArticuloBannerSeverity.info:
        accent = scheme.secondary;
        break;
      case ArticuloBannerSeverity.warning:
        accent = context.ramis.warning;
        break;
      case ArticuloBannerSeverity.error:
        accent = scheme.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accent.withValues(alpha: 0.10),
          scheme.surface,
        ),
        borderRadius: RamisRadius.medium,
        border: Border.all(
          color: accent.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: accent,
            size: 23,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// IMAGEN DEL ARTÍCULO
// =====================================================

class ArticuloImageTile extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onDelete;

  const ArticuloImageTile({
    super.key,
    required this.imageUrl,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: RamisRadius.medium,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: scheme.surfaceContainerHighest,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,

              loadingBuilder: (
                context,
                child,
                progress,
              ) {
                if (progress == null) {
                  return child;
                }

                return const Center(
                  child: RamisLoading(),
                );
              },

              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        color: scheme.onSurfaceVariant,
                        size: 32,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sin imagen',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          if (onDelete != null)
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: scheme.scrim.withValues(
                  alpha: 0.70,
                ),
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Eliminar imagen',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                  ),
                  iconSize: 20,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
