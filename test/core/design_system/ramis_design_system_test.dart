import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';

void main() {
  test('expone temas Material 3 para ambas apariencias', () {
    expect(RamisTheme.light.useMaterial3, isTrue);
    expect(RamisTheme.light.brightness, Brightness.light);
    expect(RamisTheme.dark.useMaterial3, isTrue);
    expect(RamisTheme.dark.brightness, Brightness.dark);
    expect(RamisTheme.light.extension<RamisThemeExtension>(), isNotNull);
    expect(RamisTheme.dark.extension<RamisThemeExtension>(), isNotNull);
  });

  test('los pares de acción y estados superan contraste AA para texto', () {
    final light = RamisTheme.light;
    final lightTokens = light.extension<RamisThemeExtension>()!;
    expectContrast(light.colorScheme.onPrimary, light.colorScheme.primary);
    expectContrast(lightTokens.success, lightTokens.approvedBackground);
    expectContrast(lightTokens.warning, lightTokens.pendingBackground);
    expectContrast(lightTokens.error, lightTokens.rejectedBackground);
    expectContrast(
        light.colorScheme.secondary, lightTokens.inProgressBackground);

    final dark = RamisTheme.dark;
    final darkTokens = dark.extension<RamisThemeExtension>()!;
    expectContrast(dark.colorScheme.onPrimary, dark.colorScheme.primary);
    expectContrast(darkTokens.success, darkTokens.approvedBackground);
    expectContrast(darkTokens.warning, darkTokens.pendingBackground);
    expectContrast(darkTokens.error, darkTokens.rejectedBackground);
    expectContrast(dark.colorScheme.secondary, darkTokens.inProgressBackground);
  });

  test('la escala tipográfica usa la familia Inter empaquetada', () {
    expect(RamisTypography.textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(RamisTypography.textTheme.bodyMedium?.fontVariations, hasLength(1));
  });

  testWidgets('los componentes base componen una pantalla en ambos temas', (
    tester,
  ) async {
    for (final theme in [RamisTheme.light, RamisTheme.dark]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: RamisScaffold(
            title: 'Design system',
            body: ListView(
              padding: const EdgeInsets.all(RamisSpacing.medium),
              children: [
                RamisCard(
                  child: const Text('Contenido'),
                  onTap: () {},
                ),
                RamisTextField(label: 'Nombre'),
                const RamisStatusChip(
                  label: 'Pendiente',
                  status: RamisStatus.pending,
                ),
                RamisButton(label: 'Acción', onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Design system'), findsOneWidget);
      expect(find.text('Contenido'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
      expect(find.text('Acción'), findsOneWidget);
    }
  });

  testWidgets('botón loading y deshabilitado no ejecuta el callback', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: RamisTheme.light,
        home: Scaffold(
          body: RamisButton(
            label: 'Guardar',
            onPressed: () => tapped = true,
            isDisabled: true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Guardar'));
    expect(tapped, isFalse);
  });

  testWidgets('el logo conserva el original y adapta la superficie al tema',
      (tester) async {
    for (final entry in [
      (ThemeMode.light, RamisTheme.light),
      (ThemeMode.dark, RamisTheme.dark),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: RamisTheme.light,
          darkTheme: RamisTheme.dark,
          themeMode: entry.$1,
          home: const Scaffold(body: RamisLogo()),
        ),
      );
      final logo = tester.widget<Image>(find.byType(Image).first);
      expect((logo.image as AssetImage).assetName,
          RamisAssets.logoOriginalExpanded);
      final container = tester.widget<Container>(
        find
            .ancestor(
                of: find.byType(Image).first, matching: find.byType(Container))
            .first,
      );
      expect(
        (container.decoration! as BoxDecoration).color,
        entry.$2.colorScheme.surface,
      );
    }
  });

  testWidgets('el emblema compacto es explícito y usa el arte propuesto', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RamisTheme.light,
        home: const Scaffold(
          body: RamisLogo(variant: RamisLogoVariant.compact),
        ),
      ),
    );

    final logo = tester.widget<Image>(find.byType(Image).first);
    expect((logo.image as AssetImage).assetName,
        RamisAssets.proposedEmeraldEmblem);
    expect(logo.fit, BoxFit.contain);
  });

  testWidgets('el fondo selecciona asset claro y oscuro sin integrarse solo', (
    tester,
  ) async {
    for (final entry in [
      (ThemeMode.light, RamisAssets.loginBackgroundLight),
      (ThemeMode.dark, RamisAssets.loginBackgroundDark),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: RamisTheme.light,
          darkTheme: RamisTheme.dark,
          themeMode: entry.$1,
          home: const Scaffold(
            body: RamisBackground(
              child: Center(child: Text('Contenido')),
            ),
          ),
        ),
      );
      final background = tester.widget<Image>(find.byType(Image).first);
      expect((background.image as AssetImage).assetName, entry.$2);
      expect(find.text('Contenido'), findsOneWidget);
    }
  });
}

void expectContrast(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  expect((lighter + 0.05) / (darker + 0.05), greaterThanOrEqualTo(4.5));
}
