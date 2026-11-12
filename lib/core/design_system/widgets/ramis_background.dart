import 'package:flutter/material.dart';

import '../ramis_assets.dart';

enum RamisBackgroundVariant { login, welcome, banner, dashboard }

/// Fondo opcional para composición explícita dentro de una pantalla.
/// No se aplica automáticamente en ninguna ruta ni Screen.
class RamisBackground extends StatelessWidget {
  const RamisBackground({
    required this.child,
    this.variant = RamisBackgroundVariant.login,
    this.assetPath,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.opacity = 1,
    this.overlayColor,
    this.overlayOpacity = 0,
    this.borderRadius,
    super.key,
  })  : assert(opacity >= 0 && opacity <= 1),
        assert(overlayOpacity >= 0 && overlayOpacity <= 1);

  final Widget child;
  final RamisBackgroundVariant variant;
  final String? assetPath;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final double opacity;
  final Color? overlayColor;
  final double overlayOpacity;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedPath = assetPath ?? _pathForTheme(isDark);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: opacity,
              child: Image.asset(
                resolvedPath,
                fit: fit,
                alignment: alignment,
              ),
            ),
          ),
          if (overlayColor != null && overlayOpacity > 0)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: overlayColor!.withValues(alpha: overlayOpacity),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }

  String _pathForTheme(bool isDark) => switch (variant) {
        RamisBackgroundVariant.login => isDark
            ? RamisAssets.loginBackgroundDark
            : RamisAssets.loginBackgroundLight,
        RamisBackgroundVariant.welcome ||
        RamisBackgroundVariant.banner =>
          isDark
              ? RamisAssets.bannerBackgroundDark
              : RamisAssets.bannerBackgroundLight,
        RamisBackgroundVariant.dashboard => isDark
            ? RamisAssets.dashboardBackgroundDark
            : RamisAssets.dashboardBackgroundLight,
      };
}
