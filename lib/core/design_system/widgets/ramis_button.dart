import 'package:flutter/material.dart';

enum RamisButtonVariant { primary, secondary, outlined, text, destructive }

class RamisButton extends StatelessWidget {
  const RamisButton({
    required this.label,
    required this.onPressed,
    this.variant = RamisButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = false,
    this.height = 48,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final RamisButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final destructive = variant == RamisButtonVariant.destructive;
    final foreground = destructive ? colors.onError : colors.onPrimary;
    final child = SizedBox(
      height: height,
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: variant == RamisButtonVariant.outlined ||
                          variant == RamisButtonVariant.text
                      ? colors.primary
                      : foreground,
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
    );

    final callback = isDisabled || isLoading ? null : onPressed;
    final Widget button;
    switch (variant) {
      case RamisButtonVariant.primary:
        button = FilledButton(onPressed: callback, child: child);
      case RamisButtonVariant.secondary:
        button = FilledButton.tonal(onPressed: callback, child: child);
      case RamisButtonVariant.outlined:
        button = OutlinedButton(onPressed: callback, child: child);
      case RamisButtonVariant.text:
        button = TextButton(onPressed: callback, child: child);
      case RamisButtonVariant.destructive:
        button = FilledButton(
          onPressed: callback,
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          ),
          child: child,
        );
    }
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
