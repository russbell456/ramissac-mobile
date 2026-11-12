import 'package:flutter/material.dart';

import '../ramis_spacing.dart';
import 'ramis_button.dart';

class RamisErrorView extends StatelessWidget {
  const RamisErrorView({
    this.title = 'Ocurrió un error',
    required this.description,
    this.onRetry,
    this.retryLabel = 'Reintentar',
    super.key,
  });

  final String title;
  final String description;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RamisSpacing.xxLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 44, color: theme.colorScheme.error),
            const SizedBox(height: RamisSpacing.medium),
            Text(title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: RamisSpacing.small),
            Text(
              description,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: RamisSpacing.xLarge),
              RamisButton(
                  label: retryLabel,
                  onPressed: onRetry,
                  variant: RamisButtonVariant.outlined,
                  icon: Icons.refresh),
            ],
          ],
        ),
      ),
    );
  }
}
