import 'package:flutter/material.dart';

/// Escala tipográfica central usando Inter con fallback de plataforma.
abstract final class RamisTypography {
  static TextTheme get textTheme => TextTheme(
        displayLarge: _style(57, 1.12, FontWeight.w400),
        displayMedium: _style(45, 1.16, FontWeight.w400),
        displaySmall: _style(36, 1.22, FontWeight.w400),
        headlineLarge: _style(32, 1.25, FontWeight.w600),
        headlineMedium: _style(28, 1.29, FontWeight.w600),
        headlineSmall: _style(24, 1.33, FontWeight.w600),
        titleLarge: _style(22, 1.27, FontWeight.w600),
        titleMedium: _style(16, 1.5, FontWeight.w600),
        titleSmall: _style(14, 1.43, FontWeight.w600),
        bodyLarge: _style(16, 1.5, FontWeight.w400),
        bodyMedium: _style(14, 1.43, FontWeight.w400),
        bodySmall: _style(12, 1.33, FontWeight.w400),
        labelLarge: _style(14, 1.43, FontWeight.w600),
        labelMedium: _style(12, 1.33, FontWeight.w600),
        labelSmall: _style(11, 1.45, FontWeight.w600),
      );

  static TextStyle _style(double size, double height, FontWeight weight) =>
      TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        height: height,
        fontWeight: weight,
        fontVariations: [FontVariation('wght', weight.value.toDouble())],
      );
}
