import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RamisThemeController extends ChangeNotifier {
  RamisThemeController({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _storageKey = 'ramis_theme_mode';
  final FlutterSecureStorage _storage;

  ThemeMode _themeMode = ThemeMode.system;
  bool _initialized = false;
  bool _isSaving = false;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _initialized;
  bool get isSaving => _isSaving;

  Future<void> load() async {
    if (_initialized) return;
    try {
      final value = await _storage.read(key: _storageKey);
      _themeMode = switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (_) {
      // Si el almacenamiento no está disponible, la app conserva System.
      _themeMode = ThemeMode.system;
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode == value) return;
    _themeMode = value;
    _isSaving = true;
    notifyListeners();
    try {
      if (value == ThemeMode.system) {
        await _storage.delete(key: _storageKey);
      } else {
        await _storage.write(
          key: _storageKey,
          value: value == ThemeMode.dark ? 'dark' : 'light',
        );
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}

final ramisThemeControllerProvider =
    ChangeNotifierProvider<RamisThemeController>((ref) {
  final controller = RamisThemeController();
  unawaited(controller.load());
  return controller;
});

/// Deja que los iconos de estado y navegación Android sigan el tema resuelto,
/// incluso cuando [ThemeMode.system] está activo.
class RamisSystemUiOverlay extends StatelessWidget {
  const RamisSystemUiOverlay({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final style = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: theme.scaffoldBackgroundColor,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: theme.colorScheme.outline,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style,
      child: child,
    );
  }
}
