import 'package:flutter/material.dart';

import '../ramis_assets.dart';

enum RamisLogoVariant { corporate, compact }

/// Logo visual de RAMIS. La variante predeterminada mantiene el asset original;
/// el emblema propuesto solo se usa cuando se pide explícitamente compact.
class RamisLogo extends StatelessWidget {
  const RamisLogo({
    this.variant = RamisLogoVariant.corporate,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.assetPath,
    this.lightAssetPath,
    this.darkAssetPath,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.semanticLabel,
    super.key,
  });

  final RamisLogoVariant variant;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? assetPath;
  final String? lightAssetPath;
  final String? darkAssetPath;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultAsset = switch (variant) {
      RamisLogoVariant.corporate => isDark
          ? (darkAssetPath ?? RamisAssets.logoOriginalExpanded)
          : (lightAssetPath ?? RamisAssets.logoOriginalExpanded),
      RamisLogoVariant.compact => RamisAssets.proposedEmeraldEmblem,
    };
    final compact = variant == RamisLogoVariant.compact;
    final effectiveWidth = width ?? (compact ? 48.0 : 180.0);
    final effectiveHeight = height ?? (compact ? 48.0 : 180.0);
    final resolvedPadding =
        (padding ?? (compact ? const EdgeInsets.all(6) : EdgeInsets.zero))
            .resolve(Directionality.of(context));
    final imageWidth = (effectiveWidth - resolvedPadding.horizontal)
        .clamp(0.0, effectiveWidth)
        .toDouble();
    final imageHeight = (effectiveHeight - resolvedPadding.vertical)
        .clamp(0.0, effectiveHeight)
        .toDouble();
    final image = Image.asset(
      assetPath ?? defaultAsset,
      width: imageWidth,
      height: imageHeight,
      fit: fit,
      semanticLabel: semanticLabel ??
          (compact ? 'Emblema RAMIS propuesto' : 'Corporación Ramis S.A.C.'),
    );

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (compact
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.surface),
        borderRadius: borderRadius ?? BorderRadius.circular(compact ? 12 : 16),
      ),
      child: image,
    );
  }
}
