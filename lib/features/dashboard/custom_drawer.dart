import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';
import 'package:sistema_ocs/data/models/user_model.dart';
import 'package:sistema_ocs/features/almacen/almacen_dashboard_screen.dart';
import 'package:sistema_ocs/features/almacen/articulos/articulos_list_screen.dart';
import 'package:sistema_ocs/features/login/auth_notifier.dart';
import 'package:sistema_ocs/features/login/login_provider.dart';
import 'package:sistema_ocs/features/profile/profile_screen.dart';
import 'package:sistema_ocs/features/users/users_screen.dart';
import 'package:sistema_ocs/features/users/user_edit_screen.dart';
import 'package:sistema_ocs/features/workers/workers_screen.dart';
import 'package:sistema_ocs/features/transportes/presentation/screens/asignacion_jornada_screen.dart';
import 'package:sistema_ocs/features/transportes/presentation/screens/conductor_jornada_screen.dart';
import 'package:sistema_ocs/features/transportes/presentation/screens/admin_transportes_screen.dart';
const _storage = FlutterSecureStorage();

class _DrawerData {
  final UserModel? user;
  final String role;

  const _DrawerData({required this.user, required this.role});
}

/// Menú lateral único para RAMIS ERP.
/// Conserva exactamente las reglas de acceso y los destinos del drawer anterior.
class CustomDrawer extends ConsumerWidget {
  final Function(int) onMenuItemTap;

  const CustomDrawer({super.key, required this.onMenuItemTap});

  Future<_DrawerData> _loadDrawerData(WidgetRef ref) async {
    UserModel? user;
    String? storedRole;

    try {
      user = await ref.read(authServiceProvider).getCurrentUser();
    } catch (_) {
      // Fallback al rol almacenado si el servicio no responde.
    }

    try {
      storedRole = await _storage.read(key: 'user_role');
    } catch (_) {
      // Fallback al rol del UserModel.
    }

    final role = (user?.role ?? storedRole ?? 'user').trim().toLowerCase();
    return _DrawerData(user: user, role: role);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: scheme.surface,
      child: FutureBuilder<_DrawerData>(
        future: _loadDrawerData(ref),
        builder: (context, snapshot) {
          final user = snapshot.data?.user;
          final currentRole = snapshot.data?.role ?? 'user';

          final isAdmin = currentRole.contains('admin');
          final isAlmacenero = currentRole.contains('almacenero');
          final isTrabajador = currentRole.contains('trabajador');
          final isConductor = currentRole.contains('conductor');

          final canViewWarehouse = isAdmin || isAlmacenero || isTrabajador;
          final canManageArticles = isAdmin || isAlmacenero;
          final canViewTransportes = isAdmin || isConductor;

          final userName = user?.nombresCompletos ?? currentRole.toUpperCase();
          final userEmail = user?.email ?? 'Sin correo';

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _header(context, userName: userName, email: userEmail, role: currentRole),
              const SizedBox(height: RamisSpacing.small),
              _sectionLabel(context, 'GENERAL'),
              _menuTile(
                context,
                icon: Icons.space_dashboard_outlined,
                title: 'Dashboard',
                onTap: () {
                  Navigator.pop(context);
                  onMenuItemTap(0);
                },
              ),
              if (canViewTransportes) ...[
                _sectionDivider(context),
                _sectionLabel(context, 'OPERACIONES'),
                _transportesTile(context, isAdmin: isAdmin),
              ],
              if (canViewWarehouse) ...[
                if (!canViewTransportes) ...[
                  _sectionDivider(context),
                  _sectionLabel(context, 'OPERACIONES'),
                ],
                _menuTile(
                  context,
                  icon: Icons.warehouse_outlined,
                  title: 'Almacén / Préstamos de Equipos',
                  subtitle: 'Solicitar, devolver, confirmar',
                  onTap: () => _open(context, const AlmacenDashboardScreen()),
                ),
              ],
              if (canManageArticles)
                _menuTile(
                  context,
                  icon: Icons.inventory_2_outlined,
                  title: 'Artículos (CRUD)',
                  subtitle: 'Gestionar artículos de almacén',
                  onTap: () => _open(context, const ArticulosListScreen()),
                ),
              if (isAdmin) ...[
                _sectionDivider(context),
                _sectionLabel(context, 'ADMINISTRACIÓN'),
                _menuTile(
                  context,
                  icon: Icons.people_outline_rounded,
                  title: 'Usuarios',
                  subtitle: 'Listar y administrar usuarios',
                  onTap: () => _open(context, const UsersScreen()),
                ),
                _menuTile(
                  context,
                  icon: Icons.badge_outlined,
                  title: 'Trabajadores',
                  subtitle: 'Listar trabajadores y almaceneros',
                  onTap: () => _open(context, const WorkersScreen()),
                ),
                _menuTile(
                  context,
                  icon: Icons.person_add_alt_1_outlined,
                  title: 'Registrar usuario',
                  subtitle: 'Registrar user o trabajador',
                  onTap: () => _open(context, const UserEditScreen()),
                ),
                _menuTile(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Gestionar roles',
                  subtitle: 'Administrar roles de usuarios',
                  onTap: () => _open(context, const UsersScreen()),
                ),
                _menuTile(
                  context,
                  icon: Icons.toggle_on_outlined,
                  title: 'Estados de usuarios',
                  subtitle: 'Activar, suspender o cesar',
                  onTap: () => _open(context, const UsersScreen()),
                ),
              ],
              _sectionDivider(context),
              _sectionLabel(context, 'MI CUENTA'),
              _menuTile(
                context,
                icon: Icons.account_circle_outlined,
                title: 'Mi perfil',
                subtitle: 'Foto y firma digital',
                onTap: () => _open(context, const ProfileScreen()),
              ),
              _menuTile(
                context,
                icon: Icons.logout_rounded,
                title: 'Cerrar Sesión',
                destructive: true,
                onTap: () => _logout(context, ref),
              ),
              const SizedBox(height: RamisSpacing.large),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: RamisSpacing.medium),
                child: Text(
                  'RAMIS ERP  •  Emerald Tech',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.ramis.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: RamisSpacing.large),
            ],
          );
        },
      ),
    );
  }

  Widget _header(
    BuildContext context, {
    required String userName,
    required String email,
    required String role,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + RamisSpacing.large,
        left: RamisSpacing.medium,
        right: RamisSpacing.medium,
        bottom: RamisSpacing.large,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: RamisRadius.large,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Referencia de marca real, no el emblema alternativo propuesto.
              const RamisLogo(width: 64, height: 64),
              const SizedBox(width: RamisSpacing.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RAMIS ERP',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Corporación Ramis S.A.C.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.ramis.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RamisSpacing.large),
          Text(
            userName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: RamisSpacing.small),
          Text(
            email,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: context.ramis.textSecondary,
            ),
          ),
          const SizedBox(height: RamisSpacing.small),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: RamisSpacing.medium,
              vertical: RamisSpacing.small,
            ),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.10),
              borderRadius: RamisRadius.medium,
              border: Border.all(color: scheme.primary.withValues(alpha: 0.22)),
            ),
            child: Text(
              'Rol: $role',
              style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RamisSpacing.medium,
        RamisSpacing.small,
        RamisSpacing.medium,
        RamisSpacing.small,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.ramis.textSecondary,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _sectionDivider(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: RamisSpacing.small),
        child: Divider(color: context.ramis.border, height: 1),
      );

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = destructive ? scheme.error : scheme.onSurface;
    final iconColor = destructive ? scheme.error : scheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: RamisSpacing.small,
        vertical: RamisSpacing.small,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: RamisRadius.medium),
        contentPadding: const EdgeInsets.symmetric(horizontal: RamisSpacing.medium),
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.ramis.textSecondary,
                ),
              ),
        trailing: Icon(Icons.chevron_right_rounded, color: context.ramis.textSecondary),
        onTap: onTap,
      ),
    );
  }

  Widget _transportesTile(BuildContext context, {required bool isAdmin}) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RamisSpacing.small),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: RamisRadius.medium),
        collapsedShape: RoundedRectangleBorder(borderRadius: RamisRadius.medium),
        leading: Icon(Icons.local_shipping_outlined, color: scheme.primary),
        title: Text('Transportes', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        initiallyExpanded: !isAdmin,
        childrenPadding: const EdgeInsets.only(left: RamisSpacing.medium),
        children: isAdmin
            ? [
                _subTile(context, Icons.assignment_ind_outlined, 'Asignar Jornada',
                    () => _open(context, const AsignacionJornadaScreen())),
                _subTile(context, Icons.dashboard_customize_outlined, 'Gestión de Flota',
                    () => _open(context, const AdminTransportesScreen())),
                _subTile(context, Icons.people_alt_outlined, 'Conductores',
                    () => _open(context, const AdminTransportesScreen(initialIndex: 5))),
              ]
            : [
                _subTile(context, Icons.route_outlined, 'Mi Jornada',
                    () => _open(context, const ConductorJornadaScreen())),
                _subTile(context, Icons.badge_outlined, 'Mis Documentos',
                    () => _open(context, const ConductorJornadaScreen(initialIndex: 2))),
              ],
      ),
    );
  }

  Widget _subTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: RamisRadius.medium),
      leading: Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      onTap: onTap,
    );
  }

  void _open(BuildContext context, Widget destination) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.isDrawerOpen == true) {
      scaffold!.closeDrawer();
    }
    try {
      await ref.read(authNotifierProvider.notifier).logout();
    } catch (error, stackTrace) {
      // AuthNotifier has already switched the app to the login screen; log any
      // secure-storage failure without trying to use the closing drawer context.
      debugPrint('No se pudo limpiar completamente la sesión: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
