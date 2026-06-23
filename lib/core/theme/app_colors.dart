// lib/core/theme/app_colors.dart
//
// @deprecated Usar AppTheme directamente.
// Este archivo se mantiene solo por compatibilidad temporal.

import 'package:flutter/material.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';

@Deprecated('Usar AppTheme en su lugar')
class AppColors {
  static const Color primaryRamisBlue = AppTheme.primary;
  static const Color accentRamisGreen = AppTheme.secondary;
  static const Color success = AppTheme.success;
  static const Color error = AppTheme.error;
  static const Color warning = AppTheme.warning;
  static const Color backgroundLight = AppTheme.background;
  static const Color textDark = AppTheme.textPrimary;
}
