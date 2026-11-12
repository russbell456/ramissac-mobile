import 'package:flutter/material.dart';

import '../ramis_radius.dart';
import '../ramis_spacing.dart';

class RamisCard extends StatelessWidget {
  const RamisCard({
    required this.child,
    this.padding = RamisSpacing.cardPadding,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius = RamisRadius.large,
    this.elevation = 0,
    this.margin = EdgeInsets.zero,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final BorderRadiusGeometry borderRadius;
  final double elevation;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius.resolve(Directionality.of(context));
    return Card(
      margin: margin,
      color: color ?? theme.colorScheme.surface,
      elevation: elevation,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side:
            BorderSide(color: borderColor ?? theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
