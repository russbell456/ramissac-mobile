import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';
import 'package:sistema_ocs/data/models/user_model.dart';
import 'package:sistema_ocs/features/workers/workers_provider.dart';

class WorkersScreen extends ConsumerStatefulWidget {
  const WorkersScreen({
    super.key,
  });

  @override
  ConsumerState<WorkersScreen> createState() =>
      _WorkersScreenState();
}

class _WorkersScreenState
    extends ConsumerState<WorkersScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _search = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => ref
          .read(workersProvider.notifier)
          .load(),
    );

    _searchController.addListener(() {
      setState(() {
        _search =
            _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ===========================================================
  // FILTRAR
  // ===========================================================

  List<UserModel> _filteredWorkers(
    List<UserModel> workers,
  ) {
    if (_search.isEmpty) {
      return workers;
    }

    return workers.where((user) {
      final nombre =
          '${user.nombre} ${user.apellidos}'
              .toLowerCase();

      final dni = (user.dni ?? '').toLowerCase();

      final codigo =
          (user.codigoUnico ?? '')
              .toLowerCase();

      final cargo =
          (user.cargo ?? '')
              .toLowerCase();

      final area =
          (user.area ?? '')
              .toLowerCase();

      final email =
          user.email.toLowerCase();

      final role =
          user.role.toLowerCase();

      return nombre.contains(_search) ||
          dni.contains(_search) ||
          codigo.contains(_search) ||
          cargo.contains(_search) ||
          area.contains(_search) ||
          email.contains(_search) ||
          role.contains(_search);
    }).toList();
  }

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workersProvider);

    final workers =
        _filteredWorkers(state.workers);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trabajadores',
        ),
        elevation: 0,
      ),
      body: state.loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(workersProvider.notifier)
                  .load(),
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(
                  AppTheme.spacingL,
                ),
                children: [
                  _buildHeader(
                    state.workers.length,
                  ),
                  const SizedBox(
                    height: AppTheme.spacingL,
                  ),
                  _buildSearch(),
                  const SizedBox(
                    height: AppTheme.spacingL,
                  ),
                  if (state.errorMessage != null)
                    _buildError(
                      state.errorMessage!,
                    ),
                  if (state.errorMessage == null &&
                      workers.isEmpty)
                    _buildEmpty(),
                  if (workers.isNotEmpty)
                    ...workers.map(
                      _buildWorkerCard,
                    ),
                ],
              ),
            ),
    );
  }

  // ===========================================================
  // HEADER
  // ===========================================================

  Widget _buildHeader(
    int total,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            AppTheme.statusHeaderGradient,
        borderRadius:
            AppTheme.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.primary.withOpacity(
              0.18,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(
        AppTheme.spacingL,
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(
                0.18,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.badge_outlined,
              color:
                  AppTheme.textOnPrimary,
              size: 32,
            ),
          ),
          const SizedBox(
            width: AppTheme.spacingM,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal activo',
                  style: AppTheme.titleLarge
                      .copyWith(
                    color:
                        AppTheme.textOnPrimary,
                  ),
                ),
                const SizedBox(
                  height: AppTheme.spacingXS,
                ),
                Text(
                  '$total registros disponibles',
                  style: AppTheme.bodySmall
                      .copyWith(
                    color: AppTheme
                        .textOnPrimary
                        .withOpacity(
                      0.85,
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

  // ===========================================================
  // BUSCADOR
  // ===========================================================

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      textInputAction:
          TextInputAction.search,
      decoration: InputDecoration(
        labelText: 'Buscar trabajador',
        hintText:
            'Nombre, DNI, código, cargo...',
        prefixIcon: const Icon(
          Icons.search,
          color: AppTheme.primary,
        ),
        suffixIcon:
            _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(
                      Icons.clear,
                    ),
                  )
                : null,
        border: OutlineInputBorder(
          borderRadius:
              AppTheme.borderRadiusSmall,
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              AppTheme.borderRadiusSmall,
          borderSide: const BorderSide(
            color: AppTheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // CARD TRABAJADOR
  // ===========================================================

  Widget _buildWorkerCard(
    UserModel user,
  ) {
    final role =
        user.role.toLowerCase();

    final isAlmacenero =
        role == 'almacenero';

    final fullName =
        '${user.nombre} ${user.apellidos}'
            .trim();

    return Card(
      margin: const EdgeInsets.only(
        bottom: AppTheme.spacingM,
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppTheme.spacingM,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildAvatar(
                  user,
                ),
                const SizedBox(
                  width: AppTheme.spacingM,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: AppTheme.titleMedium,
                      ),
                      const SizedBox(
                        height: AppTheme.spacingXS,
                      ),
                      _buildRoleBadge(
                        role,
                        isAlmacenero,
                      ),
                      const SizedBox(
                        height: AppTheme.spacingS,
                      ),
                      if (user.cargo != null &&
                          user.cargo!
                              .trim()
                              .isNotEmpty)
                        _smallInfo(
                          Icons.work_outline,
                          user.cargo!,
                        ),
                      if (user.area != null &&
                          user.area!
                              .trim()
                              .isNotEmpty)
                        _smallInfo(
                          Icons.business_outlined,
                          user.area!,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: AppTheme.spacingM,
            ),
            const Divider(
              color: AppTheme.divider,
            ),
            const SizedBox(
              height: AppTheme.spacingS,
            ),
            Row(
              children: [
                Expanded(
                  child: _infoColumn(
                    'DNI',
                    user.dni ?? 'No registrado',
                  ),
                ),
                Expanded(
                  child: _infoColumn(
                    'Código',
                    user.codigoUnico ??
                        'No registrado',
                  ),
                ),
              ],
            ),
            if (user.telefono != null &&
                user.telefono!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(
                height: AppTheme.spacingS,
              ),
              _smallInfo(
                Icons.phone_outlined,
                user.telefono!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // AVATAR
  // ===========================================================

  Widget _buildAvatar(
    UserModel user,
  ) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person_outline,
        color: AppTheme.primary,
        size: 32,
      ),
    );
  }

  // ===========================================================
  // BADGE ROLE
  // ===========================================================

  Widget _buildRoleBadge(
    String role,
    bool isAlmacenero,
  ) {
    final label =
        isAlmacenero
            ? 'ALMACENERO'
            : 'TRABAJADOR';

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isAlmacenero
            ? AppTheme.secondary
                .withOpacity(0.15)
            : AppTheme.primaryLight,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: isAlmacenero
              ? AppTheme.secondary
              : AppTheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===========================================================
  // INFORMACIÓN PEQUEÑA
  // ===========================================================

  Widget _smallInfo(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 3,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primary,
          ),
          const SizedBox(
            width: 6,
          ),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: AppTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // COLUMNA INFORMACIÓN
  // ===========================================================

  Widget _infoColumn(
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 3,
        ),
        Text(
          value,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: AppTheme.bodyMedium,
        ),
      ],
    );
  }

  // ===========================================================
  // ERROR
  // ===========================================================

  Widget _buildError(
    String message,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppTheme.spacingL,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.error,
            ),
            const SizedBox(
              height: AppTheme.spacingM,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AppTheme.spacingM,
            ),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(
                    workersProvider
                        .notifier,
                  )
                  .load(),
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Reintentar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // VACÍO
  // ===========================================================

  Widget _buildEmpty() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppTheme.spacingXXL,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.people_outline,
              size: 60,
              color: AppTheme.primary,
            ),
            const SizedBox(
              height: AppTheme.spacingM,
            ),
            const Text(
              'No se encontraron trabajadores.',
              textAlign: TextAlign.center,
              style: AppTheme.titleMedium,
            ),
            const SizedBox(
              height: AppTheme.spacingS,
            ),
            Text(
              _search.isEmpty
                  ? 'No hay trabajadores o almaceneros activos.'
                  : 'No existen coincidencias con tu búsqueda.',
              textAlign: TextAlign.center,
              style: AppTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}