import 'package:flutter/material.dart';

/// Paleta base RAMIS Emerald Tech. Los componentes deben preferir tokens
/// semánticos de [RamisThemeExtension] o el [ColorScheme] del tema actual.
abstract final class RamisColors {
  static const brandEmerald = Color(0xFF00C878);
  static const lightPrimary = Color(0xFF007C52);
  static const lightPrimaryForeground = Color(0xFFFFFFFF);
  static const lightNavy = Color(0xFF0D3764);
  static const lightBlue = Color(0xFF1167BB);
  static const lightBackground = Color(0xFFF3F8FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFEAF2F5);
  static const lightTextPrimary = Color(0xFF163752);
  static const lightTextSecondary = Color(0xFF61798B);
  static const lightBorder = Color(0xFFDFE9EF);

  static const darkPrimary = Color(0xFF21D991);
  static const darkPrimaryForeground = Color(0xFF062A1C);
  static const darkNavy = Color(0xFF101F30);
  static const darkBlue = Color(0xFF6CB6FF);
  static const darkBackground = Color(0xFF0B1622);
  static const darkSurface = Color(0xFF152638);
  static const darkSurfaceVariant = Color(0xFF1C3043);
  static const darkTextPrimary = Color(0xFFF0F7FB);
  static const darkTextSecondary = Color(0xFFA3B6C6);
  static const darkBorder = Color(0xFF294154);

  static const lightSuccess = Color(0xFF176B45);
  static const lightWarning = Color(0xFF805600);
  static const lightError = Color(0xFFB3261E);
  static const darkSuccess = Color(0xFF62D99B);
  static const darkWarning = Color(0xFFFFD166);
  static const darkError = Color(0xFFFF8A80);
}
