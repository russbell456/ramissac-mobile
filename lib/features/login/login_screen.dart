import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';
import 'package:sistema_ocs/features/login/auth_notifier.dart';
import 'package:sistema_ocs/features/users/user_edit_screen.dart';

/// Inicio de sesión RAMIS ERP: Emerald Tech (Light / Dark / System).
/// La autenticación y el flujo de registro conservan sus contratos originales.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (ref.read(authNotifierProvider) == AuthStatus.loading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    await ref.read(authNotifierProvider.notifier).login(email, password);
  }

  void _registrar() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const UserEditScreen(publicRegistration: true),
      ),
    );
  }

  void _onAuthChange(AuthStatus? previous, AuthStatus next) {
    if (next != AuthStatus.unauthenticated ||
        previous != AuthStatus.loading ||
        !mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ref.read(authNotifierProvider.notifier).lastError ??
              'Credenciales inválidas o error de servidor',
        ),
        backgroundColor: context.ramis.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthStatus>(authNotifierProvider, _onAuthChange);
    final isLoading = ref.watch(authNotifierProvider) == AuthStatus.loading;

    return RamisScaffold(
      safeArea: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900 && constraints.maxHeight >= 600) {
            return _wideLayout(context, isLoading);
          }
          return _mobileLayout(context, isLoading);
        },
      ),
    );
  }

  Widget _mobileLayout(BuildContext context, bool isLoading) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RamisBackground(
      variant: RamisBackgroundVariant.login,
      overlayColor: scheme.surface,
      overlayOpacity: isDark ? 0.80 : 0.84,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) => SingleChildScrollView(
            padding: RamisSpacing.screenPadding,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewport.maxHeight - 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: RamisSpacing.large),
                  const RamisLogo(width: 150, height: 150),
                  const SizedBox(height: RamisSpacing.medium),
                  Text(
                    'RAMIS ERP',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: RamisSpacing.small),
                  Text(
                    'Gestión integral de operaciones',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.ramis.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: RamisSpacing.large),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: _loginCard(context, isLoading),
                  ),
                  const SizedBox(height: RamisSpacing.large),
                  _footer(context),
                  const SizedBox(height: RamisSpacing.medium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wideLayout(BuildContext context, bool isLoading) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: RamisBackground(
            variant: RamisBackgroundVariant.welcome,
            overlayColor: scheme.surface,
            overlayOpacity: isDark ? 0.82 : 0.78,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(RamisSpacing.large),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RamisLogo(width: 155, height: 155),
                    const Spacer(),
                    Text(
                      'Tu operación,\nbajo control.',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                    ),
                    const SizedBox(height: RamisSpacing.medium),
                    Text(
                      'Préstamos, requerimientos de campo, flota y EPP '
                      'en una sola plataforma.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: context.ramis.textSecondary,
                          ),
                    ),
                    const SizedBox(height: RamisSpacing.large),
                    _feature(context, Icons.assignment_outlined,
                        'Requerimientos y préstamos'),
                    _feature(context, Icons.local_shipping_outlined,
                        'Gestión de flota'),
                    _feature(context, Icons.health_and_safety_outlined,
                        'Control de EPP'),
                    const Spacer(),
                    _footer(context),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(RamisSpacing.large),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: _loginCard(context, isLoading),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _feature(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: RamisSpacing.medium),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: RamisSpacing.medium),
          Flexible(
            child: Text(title, style: theme.textTheme.titleSmall),
          ),
        ],
      ),
    );
  }

  Widget _loginCard(BuildContext context, bool isLoading) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return RamisCard(
      padding: const EdgeInsets.all(RamisSpacing.large),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.lock_person_outlined, color: scheme.primary, size: 28),
                const SizedBox(width: RamisSpacing.medium),
                Expanded(
                  child: Text(
                    'Bienvenido',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: RamisSpacing.small),
            Text(
              'Ingresa tus credenciales para acceder al sistema.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.ramis.textSecondary,
              ),
            ),
            const SizedBox(height: RamisSpacing.large),
            // Se mantienen TextField nativos para conservar onSubmitted,
            // callback que RamisTextField V1.0 todavía no expone.
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
              onSubmitted: (_) => _passwordFocus.requestFocus(),
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: RamisSpacing.medium),
            TextField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: _ocultarPassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) {
                if (!isLoading) _login();
              },
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _ocultarPassword
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
                  icon: Icon(_ocultarPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () {
                    setState(() => _ocultarPassword = !_ocultarPassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: RamisSpacing.large),
            RamisButton(
              label: 'Iniciar sesión',
              icon: Icons.login_rounded,
              isLoading: isLoading,
              fullWidth: true,
              onPressed: isLoading ? null : _login,
            ),
            const SizedBox(height: RamisSpacing.large),
            Row(
              children: [
                Expanded(child: Divider(color: context.ramis.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RamisSpacing.small,
                  ),
                  child: Text(
                    '¿Aún no tienes cuenta?',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.ramis.textSecondary,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: context.ramis.border)),
              ],
            ),
            const SizedBox(height: RamisSpacing.medium),
            RamisButton(
              label: 'Registrar',
              icon: Icons.person_add_alt_1_rounded,
              variant: RamisButtonVariant.outlined,
              fullWidth: true,
              onPressed: isLoading ? null : _registrar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Text(
      '© Corporación Ramis S.A.C.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.ramis.textSecondary,
          ),
      textAlign: TextAlign.center,
    );
  }
}
