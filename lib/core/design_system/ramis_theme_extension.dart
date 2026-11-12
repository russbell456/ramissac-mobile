import 'package:flutter/material.dart';

@immutable
class RamisThemeExtension extends ThemeExtension<RamisThemeExtension> {
  const RamisThemeExtension({
    required this.brandEmerald,
    required this.brandNavy,
    required this.secondaryBlue,
    required this.textSecondary,
    required this.border,
    required this.surfaceVariant,
    required this.success,
    required this.warning,
    required this.error,
    required this.pendingBackground,
    required this.approvedBackground,
    required this.rejectedBackground,
    required this.inProgressBackground,
  });

  final Color brandEmerald;
  final Color brandNavy;
  final Color secondaryBlue;
  final Color textSecondary;
  final Color border;
  final Color surfaceVariant;
  final Color success;
  final Color warning;
  final Color error;
  final Color pendingBackground;
  final Color approvedBackground;
  final Color rejectedBackground;
  final Color inProgressBackground;

  static const light = RamisThemeExtension(
    brandEmerald: Color(0xFF00C878),
    brandNavy: Color(0xFF0D3764),
    secondaryBlue: Color(0xFF1167BB),
    textSecondary: Color(0xFF61798B),
    border: Color(0xFFDFE9EF),
    surfaceVariant: Color(0xFFEAF2F5),
    success: Color(0xFF176B45),
    warning: Color(0xFF805600),
    error: Color(0xFFB3261E),
    pendingBackground: Color(0xFFFFF2CC),
    approvedBackground: Color(0xFFE2F5EA),
    rejectedBackground: Color(0xFFFCE8E6),
    inProgressBackground: Color(0xFFE4F1FC),
  );

  static const dark = RamisThemeExtension(
    brandEmerald: Color(0xFF00C878),
    brandNavy: Color(0xFF101F30),
    secondaryBlue: Color(0xFF6CB6FF),
    textSecondary: Color(0xFFA3B6C6),
    border: Color(0xFF294154),
    surfaceVariant: Color(0xFF1C3043),
    success: Color(0xFF62D99B),
    warning: Color(0xFFFFD166),
    error: Color(0xFFFF8A80),
    pendingBackground: Color(0xFF493812),
    approvedBackground: Color(0xFF123B2C),
    rejectedBackground: Color(0xFF4A2224),
    inProgressBackground: Color(0xFF163853),
  );

  @override
  RamisThemeExtension copyWith({
    Color? brandEmerald,
    Color? brandNavy,
    Color? secondaryBlue,
    Color? textSecondary,
    Color? border,
    Color? surfaceVariant,
    Color? success,
    Color? warning,
    Color? error,
    Color? pendingBackground,
    Color? approvedBackground,
    Color? rejectedBackground,
    Color? inProgressBackground,
  }) =>
      RamisThemeExtension(
        brandEmerald: brandEmerald ?? this.brandEmerald,
        brandNavy: brandNavy ?? this.brandNavy,
        secondaryBlue: secondaryBlue ?? this.secondaryBlue,
        textSecondary: textSecondary ?? this.textSecondary,
        border: border ?? this.border,
        surfaceVariant: surfaceVariant ?? this.surfaceVariant,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        error: error ?? this.error,
        pendingBackground: pendingBackground ?? this.pendingBackground,
        approvedBackground: approvedBackground ?? this.approvedBackground,
        rejectedBackground: rejectedBackground ?? this.rejectedBackground,
        inProgressBackground: inProgressBackground ?? this.inProgressBackground,
      );

  @override
  RamisThemeExtension lerp(
    covariant ThemeExtension<RamisThemeExtension>? other,
    double t,
  ) {
    if (other is! RamisThemeExtension) return this;
    return RamisThemeExtension(
      brandEmerald: Color.lerp(brandEmerald, other.brandEmerald, t)!,
      brandNavy: Color.lerp(brandNavy, other.brandNavy, t)!,
      secondaryBlue: Color.lerp(secondaryBlue, other.secondaryBlue, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      pendingBackground:
          Color.lerp(pendingBackground, other.pendingBackground, t)!,
      approvedBackground:
          Color.lerp(approvedBackground, other.approvedBackground, t)!,
      rejectedBackground:
          Color.lerp(rejectedBackground, other.rejectedBackground, t)!,
      inProgressBackground:
          Color.lerp(inProgressBackground, other.inProgressBackground, t)!,
    );
  }
}

extension RamisThemeContext on BuildContext {
  RamisThemeExtension get ramis =>
      Theme.of(this).extension<RamisThemeExtension>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? RamisThemeExtension.dark
          : RamisThemeExtension.light);
}
