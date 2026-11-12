import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';
import 'package:sistema_ocs/features/dashboard/dashboard_screen.dart';
import 'package:sistema_ocs/features/almacen/prestamos/screens/escanear_qr_screen.dart';
import 'package:sistema_ocs/features/almacen/prestamos/screens/articulos_disponibles_screen.dart';
import 'package:sistema_ocs/features/almacen/prestamos/screens/mis_prestamos_screen.dart';

/// Pantalla principal del módulo Almacén / Préstamos.
/// Conserva las reglas de acceso y las rutas originales.
class AlmacenDashboardScreen extends ConsumerStatefulWidget {
  const AlmacenDashboardScreen({super.key});

  @override
  ConsumerState<AlmacenDashboardScreen> createState() =>
      _AlmacenDashboardScreenState();
}

class _AlmacenDashboardScreenState
    extends ConsumerState<AlmacenDashboardScreen> {
  late final Future<String?> _roleFuture;

  @override
  void initState() {
    super.initState();
    // Evita repetir la lectura del almacenamiento cuando cambia el tema.
    _roleFuture = const FlutterSecureStorage().read(key: 'user_role');
  }

  void _volverAlDashboard() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _abrir(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _showProximamente() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad en desarrollo - Próximamente disponible'),
        duration: Duration(seconds: 2),
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    return RamisScaffold(
      title: 'Almacén y préstamos',
      leading: IconButton(
        tooltip: 'Volver al dashboard',
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: _volverAlDashboard,
      ),
      body: FutureBuilder<String?>(
        future: _roleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const RamisLoading(label: 'Cargando módulo de almacén...');
          }

          // Como en la pantalla original, si no se consigue leer el rol
          // se aplica 'user' y no se conceden permisos adicionales.
          final role = (snapshot.data ?? 'user').trim().toLowerCase();
          final esTrabajador = role == 'trabajador';
          final esAdmin = role == 'admin';
          final esAlmacenero = role == 'almacenero';
          
          final esResponsable = esAlmacenero || esAdmin;
          
          // Tanto trabajadores, almaceneros como administradores pueden gestionar devoluciones
          final puedeDevolverPropios = esTrabajador || esAlmacenero || esAdmin;
          final puedeVerModulo = puedeDevolverPropios || esResponsable;

          return SafeArea(
            child: ListView(
              padding: RamisSpacing.screenPadding,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildWelcomeCard(context, role),
                        const SizedBox(height: RamisSpacing.medium),
                        if (esTrabajador) ...[
                          _buildSectionHeader(
                            context,
                            'Tus operaciones',
                            'Solicita y devuelve equipos de forma segura.',
                          ),
                          const SizedBox(height: RamisSpacing.medium),
                          _buildActionCard(
                            context,
                            icon: Icons.add_circle_outline_rounded,
                            title: 'Solicitar préstamo',
                            subtitle: 'Elige equipos y genera QR para el almacenero',
                            useSecondaryColor: false,
                            onTap: () => _abrir(const ArticulosDisponiblesScreen()),
                          ),
                          const SizedBox(height: RamisSpacing.medium),
                          _buildActionCard(
                            context,
                            icon: Icons.assignment_return_outlined,
                            title: 'Devolver equipos',
                            subtitle: 'Revisa tus pendientes y genera QR de devolución',
                            useSecondaryColor: true,
                            onTap: () => _abrir(const MisPrestamosScreen()),
                          ),
                        ],
                        if (esResponsable) ...[
                          _buildSectionHeader(
                            context,
                            'Operaciones de almacén',
                            'Gestiona entregas, devoluciones y consultas.',
                          ),
                          const SizedBox(height: RamisSpacing.medium),
                          _buildActionCard(
                            context,
                            icon: Icons.qr_code_scanner_rounded,
                            title: 'Escanear QR',
                            subtitle: 'Confirma préstamos o devoluciones escaneando',
                            useSecondaryColor: false,
                            onTap: () => _abrir(const ScanQRScreen()),
                          ),
                          const SizedBox(height: RamisSpacing.medium),
                          _buildActionCard(
                            context,
                            icon: Icons.person_add_alt_1_rounded,
                            title: 'Préstamo manual',
                            subtitle: 'Para trabajadores sin celular o app',
                            useSecondaryColor: true,
                            onTap: () => _abrir(const ArticulosDisponiblesScreen()),
                          ),
                          const SizedBox(height: RamisSpacing.medium),
                          _buildActionCard(
                            context,
                            icon: Icons.manage_search_rounded,
                            title: 'Buscar artículo / trabajador',
                            subtitle: 'Ver estado o préstamos actuales',
                            useSecondaryColor: false,
                            onTap: _showProximamente,
                          ),
                        ],
                        if (esAdmin || esAlmacenero) ...[
                          const SizedBox(height: RamisSpacing.medium),
                          _buildSectionHeader(
                            context,
                            'Gestión de devoluciones',
                            'Acceso operativo para devoluciones y control.',
                          ),
                          const SizedBox(height: RamisSpacing.medium),
                          _buildActionCard(
                            context,
                            icon: Icons.assignment_return_outlined,
                            title: 'Devolver equipos',
                            subtitle: 'Revisa o procesa los préstamos y devoluciones',
                            useSecondaryColor: true,
                            onTap: () => _abrir(const MisPrestamosScreen()),
                          ),
                        ],
                        if (!puedeVerModulo)
                          const RamisErrorView(
                            title: 'Acceso no disponible',
                            description:
                                'No tienes acceso al módulo de Almacén.\n'
                                'Contacta al administrador.',
                          ),
                        const SizedBox(height: RamisSpacing.medium),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String role) {
    final colors = Theme.of(context).colorScheme;
    final isWorker = role == 'trabajador';

    return RamisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const RamisLogo(width: 72, height: 72),
              const SizedBox(width: RamisSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CORPORACIÓN RAMIS S.A.C.',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: context.ramis.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bienvenido a Almacén',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RamisSpacing.medium),
          Row(
            children: [
              Icon(
                isWorker ? Icons.person_outline_rounded : Icons.admin_panel_settings_outlined,
                color: colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Rol: ${role.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.ramis.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.ramis.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool useSecondaryColor,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    final accent = useSecondaryColor ? colors.secondary : colors.primary;
    final accentBackground = useSecondaryColor
        ? colors.secondaryContainer
        : colors.primaryContainer;
    final accentForeground = useSecondaryColor
        ? colors.onSecondaryContainer
        : colors.onPrimaryContainer;

    return RamisCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accentBackground,
              borderRadius: RamisRadius.medium,
            ),
            child: Icon(icon, color: accentForeground, size: 28),
          ),
          const SizedBox(width: RamisSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.ramis.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: accent),
        ],
      ),
    );
  }
}
