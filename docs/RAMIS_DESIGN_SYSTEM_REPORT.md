# RAMIS Emerald Tech Design System — Reporte V1.0

## 1. Resumen de implementación

Se creó la infraestructura reutilizable Emerald Tech en `lib/core/design_system/`: paleta semántica, Inter local, escalas de espaciado/radio, temas Material 3 claro y oscuro, extensión de tema, persistencia de `ThemeMode` y once componentes universales, incluidos `RamisLogo` y `RamisBackground`.

`MaterialApp` ahora usa el nuevo tema claro, oscuro y la preferencia del dispositivo. La preferencia se carga antes de `runApp`, evitando mostrar una apariencia incorrecta mientras se restaura. El valor inicial es `ThemeMode.system`.

No se migró ni se aplicó un fondo automáticamente a ninguna pantalla de negocio. La fuente variable Inter se descargó desde el repositorio oficial Google Fonts y se empaqueta junto con su licencia SIL OFL 1.1; ya no depende de una descarga al ejecutar la app. `RamisLogo` conserva el asset identificado como logo original por defecto. El emblema propuesto solo aparece si una pantalla solicita expresamente la variante compacta.

## 2. Arquitectura existente

- **SDK del proyecto:** `pubspec.yaml` declara Dart `>=3.5.0 <4.0.0`. La versión local identificada en el metadata del SDK es Flutter 3.44.1 estable y Dart 3.12.1. La llamada directa a `flutter --version` no terminó dentro del tiempo de espera del entorno.
- **Aplicación raíz:** `lib/main.dart`, widget `OCSApp`, contiene el `MaterialApp` existente.
- **Navegación:** principalmente `Navigator` con `MaterialPageRoute`; no se encontró un router declarativo central como GoRouter.
- **Estado:** Flutter Riverpod 2.x, con `ProviderScope`, `ConsumerWidget`, `Provider` y notifiers. La autenticación existente se observa desde `authNotifierProvider` y `authenticatedUserProvider`.
- **Autenticación:** ubicada en `lib/features/login/` y `lib/data/services/auth_service.dart`; el acceso HTTP existente se realiza con Dio y la sesión/credenciales se conservan mediante `flutter_secure_storage`. Este trabajo no modifica esos contratos.
- **Servicios desde Screens:** los módulos observan providers Riverpod y estos delegan en servicios/repositorios; las pantallas no deberían ejecutar llamadas HTTP para adoptar el Design System.
- **Tema previo:** `lib/core/theme/app_theme.dart` y `app_colors.dart` siguen existiendo para pantallas antiguas. No se migraron ni se cambiaron sus consumidores.
- **Assets:** se revisaron los archivos reales en `assets/logos/` y `assets/images/`. Los nombres `*_original*` y `logo.jpg` identifican referencias originales, pero no se validó la aprobación de marca con Corporación Ramis. Hay adaptaciones gráficas y propuestas distinguidas abajo. Inter ahora está empaquetada en `assets/fonts/` con su licencia.
- **Componentes previos:** `app_theme.dart` contiene un tema legacy y helpers propios. El nuevo sistema queda aislado en `lib/core/design_system/` para permitir la migración gradual.

## 3. Árbol de archivos

```text
lib/core/design_system/
├── ramis_colors.dart
├── ramis_assets.dart
├── ramis_design_system.dart
├── ramis_radius.dart
├── ramis_spacing.dart
├── ramis_theme.dart
├── ramis_theme_controller.dart
├── ramis_theme_extension.dart
├── ramis_typography.dart
└── widgets/
    ├── ramis_app_bar.dart
    ├── ramis_button.dart
    ├── ramis_card.dart
    ├── ramis_empty_state.dart
    ├── ramis_error_view.dart
    ├── ramis_loading.dart
    ├── ramis_logo.dart
    ├── ramis_background.dart
    ├── ramis_scaffold.dart
    ├── ramis_status_chip.dart
    └── ramis_text_field.dart

test/core/design_system/ramis_design_system_test.dart
assets/fonts/Inter-Variable.ttf
assets/fonts/OFL.txt
docs/RAMIS_DESIGN_SYSTEM_REPORT.md
```

Integración modificada: `lib/main.dart` (registro de la licencia Inter en el registro de licencias de Flutter). `pubspec.yaml` declara los directorios de imágenes/logos que ya existían, el asset de licencia y la familia local Inter. No se añadieron dependencias de paquetes para assets, fuentes, estado, navegación ni persistencia.

### Assets revisados y clasificación

`RamisAssets` centraliza las rutas existentes de marca, fondos, ilustraciones raster y la fuente/licencia. No incluye PDFs ni el ejecutable que también están en `assets/images/`, porque no son recursos visuales para `Image.asset`.

| Ruta | Clasificación | Uso / observación |
|---|---|---|
| `assets/logos/ramis_logo_original_ampliado.png` | Referencia original por nombre | Asset predeterminado de `RamisLogoVariant.corporate`; se conserva sin editar. |
| `assets/logos/ramis_logo_original_referencia.png` | Referencia original por nombre | Versión raster pequeña de referencia. |
| `assets/images/logo.jpg` | Logo legacy | Versión JPEG pequeña, centralizada pero no seleccionada automáticamente. |
| `assets/logos/ramis_lockup_light.png` | Adaptación gráfica | Lockup horizontal; no se selecciona automáticamente. |
| `assets/logos/ramis_lockup_dark.png` | Adaptación gráfica | Su SHA-256 coincide exactamente con `ramis_lockup_light.png` (`FF51D86E269562FC9EEDF4108B54C613CEAC154274C19DD10DB920CFE0C5CC67`); hoy no existe diferencia real para oscuro. |
| `assets/logos/ramis_emblema_emerald_propuesto.png` | Propuesta gráfica | Solo se usa cuando se selecciona expresamente `RamisLogoVariant.compact`. No sustituye al original por defecto. |
| `assets/logos/ramis_app_icon_propuesto.png` | Propuesta gráfica | Disponible como constante; no se usa automáticamente. |
| `assets/images/ramis_bg_login_{light,dark}.png` | Fondo/adaptación visual | Variante de fondo de login. |
| `assets/images/ramis_banner_abstract_{light,dark}.png` | Fondo/adaptación visual | Banner abstracto; sirve para bienvenida o banner. |
| `assets/images/ramis_bg_dashboard_{light,dark}.png` | Fondo/adaptación visual | Fondo de dashboard; disponible, sin aplicación automática. |
| `assets/images/almacen.png`, `almacenero.png`, `imagen1.png`, `persona1.jpg`–`persona3.jpg` | Imágenes existentes | Rutas centralizadas; no se cambian ni se aplican a pantallas. |

La clasificación se basa en el nombre y el contenido visible de los archivos; no equivale a una certificación de marca. Ningún asset original fue sobrescrito.

### Constantes de `RamisAssets`

| Constante | Ruta |
|---|---|
| `logoOriginalReference` | `assets/logos/ramis_logo_original_referencia.png` |
| `logoOriginalExpanded` | `assets/logos/ramis_logo_original_ampliado.png` |
| `logoLegacyImage` | `assets/images/logo.jpg` |
| `logoLockupLight` | `assets/logos/ramis_lockup_light.png` |
| `logoLockupDark` | `assets/logos/ramis_lockup_dark.png` |
| `proposedEmeraldEmblem` | `assets/logos/ramis_emblema_emerald_propuesto.png` |
| `proposedAppIcon` | `assets/logos/ramis_app_icon_propuesto.png` |
| `loginBackgroundLight` / `loginBackgroundDark` | `assets/images/ramis_bg_login_light.png` / `assets/images/ramis_bg_login_dark.png` |
| `dashboardBackgroundLight` / `dashboardBackgroundDark` | `assets/images/ramis_bg_dashboard_light.png` / `assets/images/ramis_bg_dashboard_dark.png` |
| `bannerBackgroundLight` / `bannerBackgroundDark` | `assets/images/ramis_banner_abstract_light.png` / `assets/images/ramis_banner_abstract_dark.png` |
| `warehouseIllustration` | `assets/images/almacen.png` |
| `warehouseWorkerIllustration` | `assets/images/almacenero.png` |
| `sampleImage` | `assets/images/imagen1.png` |
| `person1`, `person2`, `person3` | `assets/images/persona1.jpg`, `persona2.jpg`, `persona3.jpg` |
| `interVariableFont` | `assets/fonts/Inter-Variable.ttf` |
| `interLicense` | `assets/fonts/OFL.txt` |

## 4. Tokens de diseño

### Colores

Los colores se encuentran en `ramis_colors.dart`. Para usar colores de producto en widgets, preferir `Theme.of(context).colorScheme` y `context.ramis`; usar `RamisColors` para definir o revisar la paleta base.

| Token | Light | Dark |
|---|---|---|
| Brand Emerald | `#00C878` | `#00C878` |
| Primary Action | `#007C52` | `#21D991` |
| Primary Foreground | `#FFFFFF` | `#062A1C` |
| Brand Navy | `#0D3764` | `#101F30` |
| Secondary Blue | `#1167BB` | `#6CB6FF` |
| Background | `#F3F8FA` | `#0B1622` |
| Surface | `#FFFFFF` | `#152638` |
| Surface Variant | `#EAF2F5` | `#1C3043` |
| Text Primary | `#163752` | `#F0F7FB` |
| Text Secondary | `#61798B` | `#A3B6C6` |
| Border | `#DFE9EF` | `#294154` |

Los colores de estados también son semánticos y están en `RamisThemeExtension`. Las acciones primarias usan un verde oscuro/foreground contrastado en Light y un verde luminoso con texto oscuro en Dark; el verde de marca se reserva para acentos.

### Tipografía

`RamisTypography.textTheme` define Display, Headline, Title, Body y Label con tamaños y alturas de línea. `RamisTheme` usa la familia local `Inter`, declarada en `pubspec.yaml`, y los estilos ajustan el eje variable de peso. Los estilos no limitan el escalado de texto de Android.

La fuente está en `assets/fonts/Inter-Variable.ttf`; su licencia completa está en `assets/fonts/OFL.txt`, se declara como asset y se registra en `LicenseRegistry` desde `main.dart`. El TTF proviene de [Google Fonts, directorio oficial de Inter](https://github.com/google/fonts/tree/main/ofl/inter); la metadata oficial indica la fuente variable `Inter[opsz,wght].ttf`, eje de peso y licencia OFL. [METADATA.pb de Inter](https://github.com/google/fonts/blob/main/ofl/inter/METADATA.pb). La OFL permite empaquetar y redistribuir la fuente con la app conservando la licencia; no se modificó el archivo.

### Espaciado, radios y dimensiones

- `RamisSpacing`: 4, 8, 12, 16, 20, 24, 32, 40 y 48 dp; incluye `cardPadding` y `screenPadding` de 16 dp.
- `RamisRadius`: Small 8, Medium 12, Large 16 y Extra Large 24 dp.
- `RamisButton`: alto predeterminado 48 dp.
- `RamisLoading`: indicador predeterminado de 28 dp.
- Iconos de botón: 18 dp. Iconos de Empty/Error: 48/44 dp.
- Campos y chips tienen padding táctil integrado; deben conservarse los targets estándar Material al migrar pantallas.

## 5. Componentes creados

Importación cómoda: `package:sistema_ocs/core/design_system/ramis_design_system.dart`. Todos los componentes usan el `ThemeData` actual.

### `RamisScaffold` — `widgets/ramis_scaffold.dart`

Constructor público:

```dart
const RamisScaffold({
  required Widget body,
  String? title,
  PreferredSizeWidget? appBar,
  List<Widget>? actions,
  Widget? leading,
  Widget? bottomNavigationBar,
  Widget? floatingActionButton,
  bool safeArea = true,
  bool useScreenPadding = false,
  bool resizeToAvoidBottomInset = true,
  Color? backgroundColor,
  Key? key,
})
```

Usa `RamisAppBar` si recibe `title` y no un `appBar` propio. `safeArea` envuelve el contenido; `useScreenPadding` agrega el padding estándar. No navega ni contiene lógica de negocio.

### `RamisAppBar` — `widgets/ramis_app_bar.dart`

`const RamisAppBar({required String title, bool showBackButton = false, Widget? leading, List<Widget>? actions, Widget? logo, bool centerTitle = false, Key? key})`. Implementa `PreferredSizeWidget`. `logo` es un widget opcional; no hay logo oficial impuesto.

### `RamisCard` — `widgets/ramis_card.dart`

`const RamisCard({required Widget child, EdgeInsetsGeometry padding = RamisSpacing.cardPadding, VoidCallback? onTap, Color? color, Color? borderColor, BorderRadiusGeometry borderRadius = RamisRadius.large, double elevation = 0, EdgeInsetsGeometry margin = EdgeInsets.zero, Key? key})`. Usa superficie y borde del tema; el `InkWell` solo activa pulsación cuando recibe callback.

### `RamisButton` — `widgets/ramis_button.dart`

`const RamisButton({required String label, required VoidCallback? onPressed, RamisButtonVariant variant = primary, IconData? icon, bool isLoading = false, bool isDisabled = false, bool fullWidth = false, double height = 48, Key? key})`.

`RamisButtonVariant`: `primary`, `secondary`, `outlined`, `text`, `destructive`. Loading y disabled bloquean el callback. En Light/Dark emplea los colores del `ColorScheme`, sin texto blanco sobre el verde de marca brillante.

### `RamisTextField` — `widgets/ramis_text_field.dart`

`const RamisTextField({String? label, String? hint, TextEditingController? controller, FormFieldValidator<String>? validator, Widget? prefixIcon, Widget? suffixIcon, TextInputType? keyboardType, bool obscureText = false, bool enabled = true, ValueChanged<String>? onChanged, TextInputAction? textInputAction, TextCapitalization textCapitalization = none, int? maxLines = 1, int? minLines, Iterable<String>? autofillHints, FocusNode? focusNode, bool autofocus = false, int? maxLength, Key? key})`. Es un `TextFormField` y funciona dentro del `Form` nativo.

### `RamisStatusChip` — `widgets/ramis_status_chip.dart`

`const RamisStatusChip({required String label, RamisStatus? status, Color? backgroundColor, Color? foregroundColor, Key? key})`. `RamisStatus`: `pending`, `approved`, `rejected`, `completed`, `inProgress`, `cancelled`. Status define pares de colores centralizados; un status nulo usa tokens neutrales. Siempre presenta etiqueta textual.

### `RamisEmptyState` — `widgets/ramis_empty_state.dart`

`const RamisEmptyState({required IconData icon, required String title, required String description, String? actionLabel, VoidCallback? onAction, Key? key})`. Muestra botón Outlined únicamente cuando existen etiqueta y callback.

### `RamisLoading` — `widgets/ramis_loading.dart`

`const RamisLoading({String? label, double size = 28, Key? key})`. Indicador nativo centrado, anunciado como región viva; el texto es opcional.

### `RamisErrorView` — `widgets/ramis_error_view.dart`

`const RamisErrorView({String title = 'Ocurrió un error', required String description, VoidCallback? onRetry, String retryLabel = 'Reintentar', Key? key})`. Presenta botón Outlined solo si se proporciona reintento.

### `RamisLogo` — `widgets/ramis_logo.dart`

`const RamisLogo({RamisLogoVariant variant = corporate, double? width, double? height, BoxFit fit = contain, String? assetPath, String? lightAssetPath, String? darkAssetPath, Color? backgroundColor, EdgeInsetsGeometry? padding, BorderRadiusGeometry? borderRadius, String? semanticLabel, Key? key})`.

- `RamisLogoVariant.corporate` es el valor predeterminado y muestra `RamisAssets.logoOriginalExpanded`, con la imagen y nombre corporativo sin editar. Dimensión por defecto: 180 × 180 dp.
- `RamisLogoVariant.compact` debe solicitarse explícitamente; muestra `RamisAssets.proposedEmeraldEmblem`, una propuesta gráfica, a 48 × 48 dp por defecto.
- `assetPath` selecciona explícitamente un asset único. `lightAssetPath` y `darkAssetPath` permiten configurar paths diferentes según `Theme.of(context).brightness`; si no se pasan, conserva el original en ambos temas.
- El `Container` exterior usa `ColorScheme.surface` para la variante corporativa y `surfaceContainerHighest` para la compacta. El widget no sobrescribe ni transforma los pixeles del logo. `fit` predeterminado es `BoxFit.contain`.
- Para usar los lockups adaptados expresamente: `RamisLogo(lightAssetPath: RamisAssets.logoLockupLight, darkAssetPath: RamisAssets.logoLockupDark)`. Actualmente esos dos archivos son idénticos byte por byte; requiere corregir los assets antes de esperar una diferencia visual.

Ejemplos:

```dart
// Original con nombre corporativo (predeterminado, no sustituye el original).
const RamisLogo(width: 180, height: 180)

// Variante compacta propuesta: el uso del emblema es explícito.
const RamisLogo(variant: RamisLogoVariant.compact, width: 48, height: 48)

// Lockups adaptados configurados intencionalmente por tema.
const RamisLogo(
  lightAssetPath: RamisAssets.logoLockupLight,
  darkAssetPath: RamisAssets.logoLockupDark,
  width: 240,
  height: 80,
)
```

### `RamisBackground` — `widgets/ramis_background.dart`

`const RamisBackground({required Widget child, RamisBackgroundVariant variant = login, String? assetPath, BoxFit fit = cover, AlignmentGeometry alignment = Alignment.center, double opacity = 1, Color? overlayColor, double overlayOpacity = 0, BorderRadiusGeometry? borderRadius, Key? key})`.

- `RamisBackgroundVariant.login` selecciona el fondo de login claro/oscuro.
- `welcome` y `banner` seleccionan el banner abstracto del tema.
- `dashboard` selecciona el fondo de dashboard del tema.
- `assetPath` permite proporcionar otro asset real de forma explícita. `fit`, alineación, opacidad, superposición y radio son configurables.
- Solo pinta el fondo donde la pantalla lo coloca como widget. Ningún Screen existente lo usa automáticamente.

Ejemplos:

```dart
RamisBackground(
  variant: RamisBackgroundVariant.login,
  child: const Center(child: Text('Formulario de acceso')),
)

RamisBackground(
  variant: RamisBackgroundVariant.welcome,
  fit: BoxFit.cover,
  child: const Center(child: Text('Bienvenido a RAMIS ERP')),
)
```

## 6. Configuración del tema

`RamisTheme.light` y `RamisTheme.dark` son los `ThemeData`; el `ThemeMode` se administra en `RamisThemeController`.

```dart
final controller = ref.watch(ramisThemeControllerProvider);
await ref.read(ramisThemeControllerProvider).setThemeMode(ThemeMode.dark);
await ref.read(ramisThemeControllerProvider).setThemeMode(ThemeMode.light);
await ref.read(ramisThemeControllerProvider).setThemeMode(ThemeMode.system);
```

La opción inicial es `ThemeMode.system`. Se guarda Light/Dark con `flutter_secure_storage`; System borra el valor persistido. La app espera la lectura antes de `runApp`. Si almacenamiento falla al iniciar, se usa System; si falla al cambiarlo, el cambio en memoria ya se aplicó y el error de persistencia se propaga al caller.

Colores: `Theme.of(context).colorScheme.primary` / `.surface` / `.onSurface`; extensión: `context.ramis.brandEmerald`, `.textSecondary`, `.success`, `.warning`, `.error`, `.border`. `RamisThemeExtension` implementa `copyWith` y `lerp`, y se adapta al tema activo. `RamisSystemUiOverlay` actualiza brillo de iconos y color de la barra de navegación Android según el tema ya resuelto, incluso con System.

No existe aún una pantalla de configuración del tema. Para añadir el selector más adelante, la pantalla debe invocar `setThemeMode`; la selección y persistencia ya están preparadas.

## 7. Dependencias

- **Inter empaquetada localmente.** No requiere `google_fonts` ni red en runtime. Se añadió el TTF variable oficial y se conservó su licencia OFL 1.1.
- **Sin dependencias nuevas de estado/persistencia.** Reutiliza `flutter_riverpod` y `flutter_secure_storage`, que ya estaban en `pubspec.yaml`.
- No se añadió `shared_preferences`, `flutter_svg` ni un paquete de iconos.

## 8. Integración

`lib/main.dart` conserva `ProviderScope`, `OCSApp`, la selección de pantalla por estado/rol de autenticación, título y `home`. Cambió solamente el inicio para cargar la preferencia local antes de arrancar y la configuración de `MaterialApp` para añadir `theme`, `darkTheme`, `themeMode` y `RamisSystemUiOverlay`.

Una pantalla migrada puede sustituir su `Scaffold` visual por `RamisScaffold`, usar componentes de la barrel import y continuar observando sus mismos providers y servicios. No debe mover peticiones de Dio ni reglas de negocio a los componentes universales.

## 9. Ejemplo de Screen

Este ejemplo es documentación; no se añadió a rutas de producción.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';

class DesignSystemExampleScreen extends ConsumerStatefulWidget {
  const DesignSystemExampleScreen({super.key});

  @override
  ConsumerState<DesignSystemExampleScreen> createState() =>
      _DesignSystemExampleScreenState();
}

class _DesignSystemExampleScreenState
    extends ConsumerState<DesignSystemExampleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RamisScaffold(
      title: 'Ejemplo RAMIS',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: RamisSpacing.screenPadding,
          children: [
            RamisCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Solicitud', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: RamisSpacing.medium),
                  RamisTextField(
                    label: 'Nombre',
                    controller: _nameController,
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Ingresa un nombre' : null,
                  ),
                  const SizedBox(height: RamisSpacing.medium),
                  const RamisStatusChip(
                    label: 'Pendiente',
                    status: RamisStatus.pending,
                  ),
                  const SizedBox(height: RamisSpacing.medium),
                  RamisButton(
                    label: 'Continuar',
                    icon: Icons.arrow_forward,
                    fullWidth: true,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Formulario válido')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 10. Validación

Se prepararon pruebas en `test/core/design_system/ramis_design_system_test.dart` para verificar temas/extensions, composición de componentes en ambas apariencias y callback deshabilitado.

`dart format` se ejecutó sobre el Design System, `main.dart` y las pruebas. Formateó los archivos, pero el comando terminó con error al intentar actualizar una sesión de telemetría fuera del workspace. `dart pub get --offline` mostró **Got dependencies!** y aceptó la configuración de assets/fuentes; también terminó con el mismo error de telemetría/permisos. `dart analyze lib/core/design_system lib/main.dart test/core/design_system` reportó **No issues found**; el código de salida fue 0 aunque imprimió el error de telemetría al final. La prueba específica `flutter test test/core/design_system/ramis_design_system_test.dart --no-pub` se intentó dos veces; no produjo salida tras 40–45 segundos y se interrumpió, así que no se considera validada. La invocación de `flutter --version` tampoco terminó dentro del tiempo de espera. No se ejecutó `flutter analyze`; rendering Android y persistencia mediante canal nativo quedan pendientes. Flutter 3.44.1/Dart 3.12.1 fueron identificados leyendo el metadata local del SDK. Los contrastes estáticos calculados para botones y estados son mayores a 4.5:1.

Los widgets universales no importan ni invocan servicios HTTP/backend. La paleta usa pares semánticos de estados; se recomienda verificar contraste con herramienta automatizada y visualmente en dispositivo antes de publicar.

## 11. Compatibilidad con pantallas existentes

- No se migraron préstamos, requerimientos, flota, EPP, dashboard, autenticación u otras pantallas.
- No se cambiaron endpoints, modelos, repositorios, autenticación, guards ni contratos de navegación.
- `AppTheme` y sus helpers se conservan para pantallas legacy. Los colores estáticos que esas pantallas importan directamente aún no son dark-aware; se actualizarán al migrarlas individualmente.
- La única integración visual global está en `MaterialApp`. El `home` y la lógica de selección por rol/estado permanecen.
- La secuencia de arranque espera una lectura local de tema para evitar un cambio visual posterior; si la plataforma tarda, la primera presentación del árbol de widgets también se retrasa hasta finalizar esa lectura.

## 12. Guía obligatoria de migración para ChatGPT

Al recibir el código de un Screen:

1. Devuelve el archivo completo migrado, no fragmentos sueltos.
2. Conserva la lógica de negocio, endpoints, providers, servicios, validaciones, errores, estados, callbacks y contratos de navegación existentes.
3. No elimines funcionalidades y no cambies nombres/parámetros de navegación sin necesidad demostrable.
4. Cambia únicamente la presentación visual. Usa `RamisScaffold`, `RamisAppBar`, `RamisCard`, `RamisButton`, `RamisTextField`, `RamisStatusChip`, `RamisEmptyState`, `RamisLoading` y `RamisErrorView` donde encajen.
5. Usa `Theme.of(context).colorScheme`, `Theme.of(context).textTheme`, `context.ramis`, `RamisSpacing` y `RamisRadius`; no agregues colores ni dimensiones equivalentes codificados directamente.
6. Asegúrate de que la pantalla funcione con `RamisTheme.light` y `RamisTheme.dark`, y conserva el escalado de texto y targets táctiles.
7. Si un patrón requiere un componente universal que no existe, informa la necesidad y propón añadirlo al Design System; no copies ni inventes otro componente equivalente dentro de la pantalla.
8. No modifiques servicios, repositorios, modelos, rutas de backend o navegación global durante una migración visual.
9. Mantén todos los flujos y estados existentes, incluso estados vacíos, carga, error, permisos, confirmaciones y callbacks secundarios.
