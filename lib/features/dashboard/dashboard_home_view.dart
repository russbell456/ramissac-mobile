import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';

/// Inicio del panel RAMIS.
///
/// Las métricas y el gráfico siguen siendo valores ilustrativos, igual que en
/// la pantalla original. Las acciones sin implementación se dejan intactas.
class DashboardHomeView extends StatelessWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return RamisScaffold(
      safeArea: true,
      floatingActionButton: FloatingActionButton(
        // Conservado del original: aún no tiene acción implementada.
        onPressed: () {},
        tooltip: 'Mensajes',
        child: const Icon(LucideIcons.messageCircle),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 600
              ? RamisSpacing.large
              : RamisSpacing.medium;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              RamisSpacing.medium,
              horizontalPadding,
              112,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _welcomeHeader(context),
                    const SizedBox(height: RamisSpacing.large),
                    _sectionTitle(context, 'Resumen operativo',
                        'Indicadores generales del sistema'),
                    const SizedBox(height: RamisSpacing.medium),
                    _metrics(context),
                    const SizedBox(height: RamisSpacing.large),
                    _weeklyProduction(context),
                    const SizedBox(height: RamisSpacing.large),
                    _quickActions(context),
                    const SizedBox(height: RamisSpacing.small),
                    Text(
                      'Los indicadores mostrados son valores de ejemplo.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.ramis.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _welcomeHeader(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ClipRRect(
      borderRadius: RamisRadius.large,
      child: RamisBackground(
        variant: RamisBackgroundVariant.banner,
        overlayColor: scheme.surface,
        overlayOpacity: 0.83,
        child: Padding(
          padding: const EdgeInsets.all(RamisSpacing.large),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const RamisLogo(width: 78, height: 78),
              const SizedBox(width: RamisSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido a',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.ramis.textSecondary,
                      ),
                    ),
                    const SizedBox(height: RamisSpacing.small),
                    Text(
                      'Corporación Ramis',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: RamisSpacing.small),
                    Text(
                      'Panel de control',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: RamisSpacing.small),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: context.ramis.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _metrics(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = [
      _Metric(LucideIcons.activity, '5', 'Operaciones', scheme.primary),
      _Metric(LucideIcons.truck, '12', 'Equipos', scheme.secondary),
      _Metric(LucideIcons.trendingUp, '98%', 'Eficiencia', scheme.primary),
      _Metric(LucideIcons.users, '340', 'Colaboradores', scheme.secondary),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        final width = (constraints.maxWidth -
                (columns - 1) * RamisSpacing.medium) /
            columns;
        return Wrap(
          spacing: RamisSpacing.medium,
          runSpacing: RamisSpacing.medium,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: _metricCard(context, item),
              ),
          ],
        );
      },
    );
  }

  Widget _metricCard(BuildContext context, _Metric item) {
    final theme = Theme.of(context);
    return RamisCard(
      padding: const EdgeInsets.all(RamisSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(RamisSpacing.small),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.10),
              borderRadius: RamisRadius.medium,
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(height: RamisSpacing.medium),
          Text(
            item.value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: RamisSpacing.small),
          Text(
            item.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: context.ramis.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _weeklyProduction(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bars = [
      _Bar('L', 40, scheme.secondary),
      _Bar('M', 60, scheme.secondary),
      _Bar('M', 35, scheme.secondary),
      _Bar('J', 80, scheme.primary),
      _Bar('V', 55, scheme.primary),
      _Bar('S', 45, scheme.primary),
    ];

    return RamisCard(
      padding: const EdgeInsets.all(RamisSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Producción semanal',
                    style: theme.textTheme.titleMedium),
              ),
              Icon(LucideIcons.barChart3, color: scheme.secondary, size: 22),
            ],
          ),
          const SizedBox(height: RamisSpacing.small),
          Text(
            'Representación ilustrativa',
            style: theme.textTheme.bodySmall?.copyWith(
              color: context.ramis.textSecondary,
            ),
          ),
          const SizedBox(height: RamisSpacing.large),
          SizedBox(
            height: 112,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final bar in bars) _buildBar(context, bar),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, _Bar bar) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: bar.height,
          decoration: BoxDecoration(
            color: bar.color.withValues(alpha: 0.8),
            borderRadius: RamisRadius.small,
          ),
        ),
        const SizedBox(height: RamisSpacing.small),
        Text(bar.day, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }

  Widget _quickActions(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return RamisCard(
      padding: const EdgeInsets.all(RamisSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.zap, color: scheme.primary, size: 22),
              const SizedBox(width: RamisSpacing.small),
              Expanded(
                child: Text('Acciones rápidas',
                    style: theme.textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: RamisSpacing.medium),
          _quickAction(
            context,
            icon: LucideIcons.filePlus,
            label: 'Nuevo reporte',
            color: scheme.primary,
            onTap: () {},
          ),
          const SizedBox(height: RamisSpacing.small),
          _quickAction(
            context,
            icon: LucideIcons.alertTriangle,
            label: 'Registrar incidente',
            color: scheme.secondary,
            onTap: () {},
          ),
          const SizedBox(height: RamisSpacing.small),
          _quickAction(
            context,
            icon: LucideIcons.calendar,
            label: 'Planificar',
            color: scheme.primary,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: color.withValues(alpha: 0.07),
      borderRadius: RamisRadius.medium,
      child: InkWell(
        onTap: onTap,
        borderRadius: RamisRadius.medium,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RamisSpacing.medium,
            vertical: RamisSpacing.medium,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: RamisSpacing.medium),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(LucideIcons.chevronRight, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric {
  const _Metric(this.icon, this.value, this.label, this.color);
  final IconData icon;
  final String value;
  final String label;
  final Color color;
}

class _Bar {
  const _Bar(this.day, this.height, this.color);
  final String day;
  final double height;
  final Color color;
}
