import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';
import 'package:sistema_ocs/features/almacen/almacen_dashboard_screen.dart';
import 'package:sistema_ocs/features/dashboard/dashboard_screen.dart';
import 'package:sistema_ocs/features/login/auth_notifier.dart';
import 'package:sistema_ocs/features/login/login_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    ref.listen<AuthStatus>(authNotifierProvider, (previous, next) async {
      if (next == AuthStatus.authenticated) {
        final authService = ref.read(authServiceProvider);
        final user = await authService.getCurrentUser();
        final navigatorKey = ref.read(navigatorKeyProvider);

        if (user != null) {
          final role = user.role.toLowerCase();
          if (role == 'trabajador' || role == 'almacenero') {
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(builder: (_) => const AlmacenDashboardScreen()),
            );
          } else {
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          }
        } else {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      } else if (next == AuthStatus.unauthenticated && previous == AuthStatus.loading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Credenciales inválidas o error de servidor'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    });

    final isLoading = ref.watch(authNotifierProvider) == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión OCS'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/imagen1.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              AppTheme.primaryDark.withOpacity(0.55),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingXXXL),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingXXL),
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.92),
                borderRadius: AppTheme.borderRadiusLarge,
                boxShadow: [AppTheme.cardShadow],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    curve: Curves.elasticOut,
                    builder: (context, double value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: const Icon(
                      Icons.lock_person,
                      size: 80,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  Text(
                    'Sistema de Gestión OCS',
                    textAlign: TextAlign.center,
                    style: AppTheme.headlineSmall.copyWith(color: AppTheme.primary),
                  ),
                  const SizedBox(height: AppTheme.spacingXXXL),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: AppTheme.inputDecoration.copyWith(
                      labelText: 'Correo Electrónico',
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: AppTheme.inputDecoration.copyWith(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXXXL),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();

                            if (email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Por favor llena todos los campos'),
                                ),
                              );
                              return;
                            }

                            await ref
                                .read(authNotifierProvider.notifier)
                                .login(email, password);
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.textOnPrimary,
                            ),
                          )
                        : const Text('Iniciar Sesión', style: AppTheme.titleMedium),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
