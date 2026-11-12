import 'package:flutter/material.dart';

import 'ramis_colors.dart';
import 'ramis_radius.dart';
import 'ramis_theme_extension.dart';
import 'ramis_typography.dart';

abstract final class RamisTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background =
        isDark ? RamisColors.darkBackground : RamisColors.lightBackground;
    final surface = isDark ? RamisColors.darkSurface : RamisColors.lightSurface;
    final primary = isDark ? RamisColors.darkPrimary : RamisColors.lightPrimary;
    final foreground = isDark
        ? RamisColors.darkPrimaryForeground
        : RamisColors.lightPrimaryForeground;
    final text =
        isDark ? RamisColors.darkTextPrimary : RamisColors.lightTextPrimary;
    final border = isDark ? RamisColors.darkBorder : RamisColors.lightBorder;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: foreground,
      secondary: isDark ? RamisColors.darkBlue : RamisColors.lightBlue,
      onSecondary: isDark ? RamisColors.darkNavy : Colors.white,
      error: isDark ? RamisColors.darkError : RamisColors.lightError,
      onError: isDark ? RamisColors.darkNavy : Colors.white,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: isDark
          ? RamisColors.darkSurfaceVariant
          : RamisColors.lightSurfaceVariant,
      onSurfaceVariant: isDark
          ? RamisColors.darkTextSecondary
          : RamisColors.lightTextSecondary,
      outline: border,
      outlineVariant: border,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface:
          isDark ? RamisColors.lightTextPrimary : RamisColors.darkSurface,
      onInverseSurface: isDark ? RamisColors.darkBackground : Colors.white,
      inversePrimary:
          isDark ? RamisColors.lightPrimary : RamisColors.darkPrimary,
      surfaceTint: primary,
    );
    final textTheme = RamisTypography.textTheme.apply(
      bodyColor: text,
      displayColor: text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: surface,
      textTheme: textTheme,
      extensions: [
        isDark ? RamisThemeExtension.dark : RamisThemeExtension.light
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: RamisRadius.large,
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: RamisRadius.medium,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: RamisRadius.medium,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: RamisRadius.medium,
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: RamisRadius.medium,
          borderSide: BorderSide(color: scheme.error),
        ),
        labelStyle: TextStyle(
            color: isDark
                ? RamisColors.darkTextSecondary
                : RamisColors.lightTextSecondary),
      ),
      dividerTheme: DividerThemeData(color: border),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? RamisColors.darkSurfaceVariant : RamisColors.lightNavy,
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
