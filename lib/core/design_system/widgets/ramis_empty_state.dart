import 'package:flutter/material.dart';

import '../ramis_spacing.dart';
import 'ramis_button.dart';

class RamisEmptyState extends StatelessWidget {
  const RamisEmptyState({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RamisSpacing.xxLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.secondary),
            const SizedBox(height: RamisSpacing.medium),
            Text(title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: RamisSpacing.small),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: RamisSpacing.xLarge),
              RamisButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  variant: RamisButtonVariant.outlined),
            ],
          ],
        ),
      ),
    );
  }
}
