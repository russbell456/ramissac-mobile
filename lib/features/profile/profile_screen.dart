
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';
import 'package:sistema_ocs/data/models/user_model.dart';
import 'package:sistema_ocs/data/network/backend_url.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';
import 'package:sistema_ocs/features/profile/profile_provider.dart';
import 'package:sistema_ocs/features/profile/signature_capture_screen.dart';
import 'package:sistema_ocs/features/profile/widgets/profile_ui_widgets.dart';
import 'package:sistema_ocs/features/workers/workers_screen.dart';
import 'package:sistema_ocs/features/account/change_password_screen.dart';
import 'package:sistema_ocs/features/users/user_data_screen.dart';
import 'package:sistema_ocs/features/users/user_edit_screen.dart';
import 'package:sistema_ocs/features/users/users_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) {
        ref.read(profileProvider.notifier).load();
      }
    });
  }

  // =====================================================
  // OPERACIONES EXISTENTES
  // =====================================================

  Future<void> _refresh() {
    return ref.read(profileProvider.notifier).load();
  }

  void _showMessage(String message, {required bool success}) {
    if (!mounted) return;

    final scheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            success ? context.ramis.success : scheme.error,
        content: Text(message),
      ),
    );
  }

  Future<void> _selectPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'webp',
      ],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    if (!mounted) return;

    final file = result.files.single;

    final uploaded = await ref
        .read(profileProvider.notifier)
        .uploadPhoto(file);

    if (!mounted) return;

    _showMessage(
      uploaded
          ? 'Foto actualizada correctamente.'
          : 'No se pudo actualizar la foto. '
              'Verifica la conexión con el servidor.',
      success: uploaded,
    );
  }

  Future<void> _editSignature() async {
    final base64 = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const SignatureCaptureScreen(),
      ),
    );

    if (base64 == null || !mounted) {
      return;
    }

    final saved = await ref
        .read(profileProvider.notifier)
        .saveSignature(base64);

    if (!mounted) return;

    _showMessage(
      saved
          ? 'Firma guardada correctamente.'
          : 'No se pudo guardar la firma. '
              'Verifica la conexión con el servidor.',
      success: saved,
    );
  }

  // =====================================================
  // NAVEGACIÓN
  // =====================================================

  void _openScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  // =====================================================
  // SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final user = state.user;

    return RamisScaffold(
      appBar: const RamisAppBar(
        title: 'Mi perfil',
        showBackButton: true,
      ),
      body: state.loading
          ? const RamisLoading(
              label: 'Cargando perfil...',
            )
          : user == null
              ? RamisErrorView(
                  title: 'No se pudo cargar el perfil',
                  description: state.errorMessage ??
                      'No se pudo cargar el perfil.',
                  onRetry: _refresh,
                )
              : _buildContent(
                  user,
                  state,
                  ref.read(dioProvider),
                ),
    );
  }

  Widget _buildContent(
    UserModel user,
    ProfileState state,
    Dio dio,
  ) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(user),

                  const SizedBox(height: 16),

                  _buildPhotoSection(
                    user.fotoUrl,
                    dio,
                    state.uploadingPhoto,
                  ),

                  const SizedBox(height: 16),

                  _buildPersonalInformation(user),

                  const SizedBox(height: 16),

                  _buildEmploymentInformation(user),

                  const SizedBox(height: 16),

                  _buildAccountInformation(user),

                  const SizedBox(height: 16),

                  _buildSignatureSection(state),

                  const SizedBox(height: 16),

                  _buildRoleActions(user),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ENCABEZADO DEL PERFIL
  // =====================================================

  Widget _buildProfileHeader(UserModel user) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final role = user.role.trim().toLowerCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: RamisRadius.large,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.onPrimary.withValues(alpha: 0.28),
              ),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 32,
              color: scheme.onPrimary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.nombre} ${user.apellidos}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  user.email,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onPrimary.withValues(
                      alpha: 0.85,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withValues(
                      alpha: 0.13,
                    ),
                    borderRadius: RamisRadius.large,
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // FOTO
  // =====================================================

  Widget _buildPhotoSection(
    String? photoPath,
    Dio dio,
    bool uploading,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final photoUrl = buildBackendUrl(dio, photoPath);

    return ProfileSection(
      title: 'Foto de perfil',
      icon: Icons.account_circle_outlined,
      children: [
        Center(
          child: CircleAvatar(
            radius: 64,
            backgroundColor: scheme.primaryContainer,
            backgroundImage: photoUrl.isEmpty
                ? null
                : NetworkImage(photoUrl),
            child: photoUrl.isEmpty
                ? Icon(
                    Icons.person_outline_rounded,
                    size: 64,
                    color: scheme.onPrimaryContainer,
                  )
                : null,
          ),
        ),

        const SizedBox(height: 16),

        Center(
          child: RamisButton(
            label: uploading ? 'Subiendo...' : 'Cambiar foto',
            icon: Icons.photo_camera_outlined,
            isLoading: uploading,
            onPressed: uploading ? null : _selectPhoto,
            variant: RamisButtonVariant.secondary,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // INFORMACIÓN PERSONAL
  // =====================================================

  Widget _buildPersonalInformation(UserModel user) {
    return ProfileSection(
      title: 'Información personal',
      icon: Icons.person_outline_rounded,
      children: [
        ProfileInfoRow(label: 'Nombre', value: user.nombre),
        ProfileInfoRow(
          label: 'Apellidos',
          value: user.apellidos,
        ),
        ProfileInfoRow(
          label: 'Tipo documento',
          value: user.tipoDocumento,
        ),
        ProfileInfoRow(label: 'DNI', value: user.dni),
        ProfileInfoRow(label: 'Género', value: user.genero),
        ProfileInfoRow(
          label: 'Fecha nacimiento',
          value: user.fechaNacimiento,
        ),
        ProfileInfoRow(
          label: 'Teléfono',
          value: user.telefono,
        ),
        ProfileInfoRow(
          label: 'Teléfono secundario',
          value: user.telefonoSecundario,
        ),
        ProfileInfoRow(
          label: 'Dirección',
          value: user.direccion,
        ),
      ],
    );
  }

  // =====================================================
  // INFORMACIÓN LABORAL
  // =====================================================

  Widget _buildEmploymentInformation(UserModel user) {
    return ProfileSection(
      title: 'Información laboral',
      icon: Icons.work_outline_rounded,
      children: [
        ProfileInfoRow(
          label: 'Código único',
          value: user.codigoUnico,
        ),
        ProfileInfoRow(label: 'Cargo', value: user.cargo),
        ProfileInfoRow(label: 'Área', value: user.area),
        ProfileInfoRow(
          label: 'Fecha ingreso',
          value: user.fechaIngreso,
        ),
        ProfileInfoRow(
          label: 'Fecha baja',
          value: user.fechaBaja,
        ),
        ProfileInfoRow(
          label: 'Estado laboral',
          value: user.estadoLaboral,
        ),
        ProfileInfoRow(
          label: 'Supervisor ID',
          value: user.supervisorId?.toString(),
        ),
      ],
    );
  }

  // =====================================================
  // INFORMACIÓN DE CUENTA
  // =====================================================

  Widget _buildAccountInformation(UserModel user) {
    return ProfileSection(
      title: 'Información de cuenta',
      icon: Icons.manage_accounts_outlined,
      children: [
        ProfileInfoRow(label: 'Correo', value: user.email),
        ProfileInfoRow(label: 'Rol', value: user.role),
        ProfileInfoRow(
          label: 'Activo',
          value: user.activo ? 'Sí' : 'No',
        ),
        ProfileInfoRow(
          label: 'Último acceso',
          value: user.ultimoAcceso,
        ),
        ProfileInfoRow(
          label: 'Fecha creación',
          value: user.fechaCreacion,
        ),
        ProfileInfoRow(
          label: 'Última actualización',
          value: user.fechaActualizacion,
        ),
      ],
    );
  }

  // =====================================================
  // FIRMA DIGITAL
  // =====================================================

  Widget _buildSignatureSection(ProfileState state) {
    final scheme = Theme.of(context).colorScheme;
    final signatureUrl = state.signatureImageUrl;

    return ProfileSection(
      title: 'Firma digital',
      icon: Icons.draw_outlined,
      children: [
        if (signatureUrl != null && signatureUrl.isNotEmpty)
          Container(
            height: 140,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border.all(
                color: context.ramis.border,
              ),
              borderRadius: RamisRadius.medium,
            ),
            child: Image.network(
              signatureUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    'No se pudo mostrar la firma.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: RamisRadius.medium,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: scheme.secondary,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'No tienes una firma registrada.',
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        RamisButton(
          label: state.savingSignature
              ? 'Guardando...'
              : signatureUrl == null
                  ? 'Registrar firma'
                  : 'Actualizar firma',
          icon: Icons.draw_outlined,
          variant: RamisButtonVariant.secondary,
          isLoading: state.savingSignature,
          onPressed: state.savingSignature
              ? null
              : _editSignature,
        ),
      ],
    );
  }

  // =====================================================
  // ACCIONES SEGÚN EL ROL ORIGINAL
  // =====================================================

  Widget _buildRoleActions(UserModel user) {
    final role = user.role.trim().toLowerCase();

    final isAdmin = role == 'admin';
    final isAlmacenero = role == 'almacenero';

    return ProfileSection(
      title: 'Acciones disponibles',
      icon: Icons.dashboard_customize_outlined,
      children: [
        // TODOS LOS ROLES
        ProfileActionTile(
          icon: Icons.edit_outlined,
          title: 'Editar mis datos de contacto',
          subtitle: 'Modificar teléfono y dirección',
          onPressed: () {
            _openScreen(const UserDataScreen());
          },
        ),

        ProfileActionTile(
          icon: Icons.lock_outline_rounded,
          title: 'Cambiar contraseña',
          subtitle: 'Actualizar contraseña de acceso',
          onPressed: () {
            _openScreen(const ChangePasswordScreen());
          },
        ),

        // ADMINISTRADOR Y ALMACENERO
        if (isAdmin || isAlmacenero) ...[
          const SizedBox(height: 12),
          _sectionLabel('Gestión de trabajadores'),

          ProfileActionTile(
            icon: Icons.badge_outlined,
            title: 'Trabajadores',
            subtitle: 'Listar trabajadores y almaceneros',
            onPressed: () {
              _openScreen(const WorkersScreen());
            },
          ),
        ],

        // SOLO ADMINISTRADOR
        if (isAdmin) ...[
          const SizedBox(height: 12),
          _sectionLabel('Administración'),

          ProfileActionTile(
            icon: Icons.manage_accounts_outlined,
            title: 'Gestión de usuarios',
            subtitle: 'Listar y administrar usuarios',
            onPressed: _openUsers,
          ),

          ProfileActionTile(
            icon: Icons.person_add_alt_1_outlined,
            title: 'Registrar usuario',
            subtitle: 'Registrar user o trabajador',
            onPressed: () {
              _openScreen(const UserEditScreen());
            },
          ),

          ProfileActionTile(
            icon: Icons.edit_note_outlined,
            title: 'Editar usuarios',
            subtitle: 'Modificar información de usuarios',
            onPressed: _openUsers,
          ),

          ProfileActionTile(
            icon: Icons.toggle_on_outlined,
            title: 'Cambiar estado',
            subtitle: 'Activar, suspender o cesar usuarios',
            onPressed: _openUsers,
          ),

          ProfileActionTile(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Gestionar roles',
            subtitle: 'Administrar roles de usuarios',
            onPressed: _openUsers,
          ),
        ],
      ],
    );
  }

  void _openUsers() {
    _openScreen(const UsersScreen());
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
