import 'package:flutter/material.dart';

class RamisLoading extends StatelessWidget {
  const RamisLoading({this.label, this.size = 28, super.key});

  final String? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Semantics(
        label: label ?? 'Cargando',
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: const CircularProgressIndicator(strokeWidth: 3),
            ),
            if (label != null) ...[
              const SizedBox(height: 12),
              Text(label!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
