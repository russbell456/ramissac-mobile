import 'package:flutter/material.dart';

import '../ramis_theme_extension.dart';

enum RamisStatus {
  pending,
  approved,
  rejected,
  completed,
  inProgress,
  cancelled
}

class RamisStatusChip extends StatelessWidget {
  const RamisStatusChip({
    required this.label,
    this.status,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final String label;
  final RamisStatus? status;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.ramis;
    final colors = theme.colorScheme;
    final pair = _colors(status, colors, tokens);

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor ?? pair.$1,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: foregroundColor ?? pair.$2,
          ),
        ),
      ),
    );
  }

  (Color, Color) _colors(
    RamisStatus? status,
    ColorScheme scheme,
    RamisThemeExtension tokens,
  ) {
    switch (status) {
      case RamisStatus.pending:
        return (tokens.pendingBackground, tokens.warning);
      case RamisStatus.approved:
      case RamisStatus.completed:
        return (tokens.approvedBackground, tokens.success);
      case RamisStatus.rejected:
      case RamisStatus.cancelled:
        return (tokens.rejectedBackground, tokens.error);
      case RamisStatus.inProgress:
        return (tokens.inProgressBackground, scheme.secondary);
      case null:
        return (tokens.surfaceVariant, scheme.onSurfaceVariant);
    }
  }
}
