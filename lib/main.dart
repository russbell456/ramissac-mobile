import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';
import 'package:sistema_ocs/core/design_system/ramis_theme_controller.dart';
import 'package:sistema_ocs/features/dashboard/dashboard_screen.dart';
import 'package:sistema_ocs/features/almacen/almacen_dashboard_screen.dart';
import 'package:sistema_ocs/features/login/auth_notifier.dart';
import 'package:sistema_ocs/features/login/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(RamisAssets.interLicense);
    yield LicenseEntryWithLineBreaks(['Inter'], license);
  });
  final themeController = RamisThemeController();
  await themeController.load();
  runApp(
    ProviderScope(
      overrides: [
        ramisThemeControllerProvider.overrideWith((ref) => themeController),
      ],
      child: const OCSApp(),
    ),
  );
}

class OCSApp extends ConsumerWidget {
  const OCSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authNotifierProvider);
    final themeController = ref.watch(ramisThemeControllerProvider);
    Widget homeScreen;
    if (authStatus == AuthStatus.unauthenticated) {
      homeScreen = const LoginScreen();
    } else if (authStatus == AuthStatus.authenticated) {
      final user = ref.watch(authenticatedUserProvider);
      homeScreen = user.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(
          body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('No se pudo validar la sesión. Revisa tu conexión.'),
            const SizedBox(height: 12),
            OutlinedButton(
                onPressed: () => ref.invalidate(authenticatedUserProvider),
                child: const Text('Reintentar')),
            TextButton(
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).logout(),
                child: const Text('Cerrar sesión')),
          ])),
        ),
        data: (currentUser) =>
            currentUser.role == 'trabajador' || currentUser.role == 'almacenero'
                ? const AlmacenDashboardScreen()
                : const DashboardScreen(),
      );
    } else {
      homeScreen =
          const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MaterialApp(
      title: 'Sistema OCS',
      theme: RamisTheme.light,
      darkTheme: RamisTheme.dark,
      themeMode: themeController.themeMode,
      builder: (context, child) => RamisSystemUiOverlay(
        child: child ?? const SizedBox.shrink(),
      ),
      home: homeScreen,
    );
  }
}
