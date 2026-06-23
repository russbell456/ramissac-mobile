import 'package:flutter/material.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';
import 'package:sistema_ocs/data/models/rq_model.dart';
import 'package:sistema_ocs/features/ordenes_compra/screens/seleccionar_items_oc_screen.dart';
import 'package:intl/intl.dart';

class RQDetailScreen extends StatelessWidget {
  final RQResponse rq;

  const RQDetailScreen({super.key, required this.rq});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.textPrimary,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppTheme.background),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: AppTheme.borderRadiusSmall,
                  border: Border.all(color: AppTheme.primary),
                ),
                child: Icon(Icons.description, color: AppTheme.primary, size: AppTheme.iconSizeMedium),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Text(
                'RQ: ${rq.nroRq}',
                style: AppTheme.titleLarge.copyWith(
                  color: AppTheme.background,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AppCard(
              backgroundColor: AppTheme.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.spacingXL),
                topRight: Radius.circular(AppTheme.spacingXL),
              ),
              padding: EdgeInsets.zero,
              showShadow: false,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                indicator: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: AppTheme.borderRadiusMedium,
                ),
                labelColor: AppTheme.background,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: AppTheme.labelMedium.copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: AppTheme.labelMedium,
                tabs: [
                  Tab(
                    icon: Icon(Icons.inventory_2_outlined, size: AppTheme.iconSizeMedium),
                    text: 'ÍTEMS SOLICITADOS',
                  ),
                  Tab(
                    icon: Icon(Icons.history_toggle_off_outlined, size: AppTheme.iconSizeMedium),
                    text: 'HISTORIAL',
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildItemsTab(context),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildStatusHeader(),
          const SizedBox(height: AppTheme.spacingL),
          _buildGeneralDataCard(),
          const SizedBox(height: AppTheme.spacingXL),
          _buildItemsTable(context),
          const SizedBox(height: AppTheme.spacingXL),
          _buildActionButton(context),
          const SizedBox(height: AppTheme.spacingXXL),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingL),
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTheme.borderRadiusLarge,
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ESTADO DEL REQUERIMIENTO',
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.background.withOpacity(0.9),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  AppBadge(
                    text: rq.estado,
                    color: _getStatusColor(rq.estado),
                    isUpperCase: true,
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  if (rq.progresoCompra > 0)
                    AppBadge(
                      text: '${rq.progresoCompra.toStringAsFixed(0)}% PROCESADO',
                      color: _getProgressColor(),
                      isUpperCase: true,
                    ),
                ],
              ),
            ],
          ),
          _buildProgressCircle(),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: CircularProgressIndicator(
            value: rq.progresoCompra / 100,
            strokeWidth: 8,
            backgroundColor: AppTheme.background.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(_getProgressColor()),
          ),
        ),
        Text(
          '${rq.progresoCompra.toStringAsFixed(0)}%',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.background,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralDataCard() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: AppCard(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.work_outline,
                    title: 'PROYECTO',
                    value: rq.proyecto,
                    color: AppTheme.secondary,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingL),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.person_outline,
                    title: 'SOLICITANTE',
                    value: rq.solicitante,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            const Divider(height: 1, color: AppTheme.divider),
            const SizedBox(height: AppTheme.spacingL),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.calendar_today_outlined,
                    title: 'FECHA DE EMISIÓN',
                    value: dateFormat.format(rq.fechaEmision),
                    color: AppTheme.warning,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingL),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.timeline_outlined,
                    title: 'ESTADO COMPRA',
                    value: rq.estadoCompra.replaceAll('_', ' ').toUpperCase(),
                    color: _getProgressColor(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTable(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
              child: Row(
                children: [
                  Icon(Icons.list_alt_outlined, color: AppTheme.textPrimary, size: AppTheme.iconSizeLarge),
                  const SizedBox(width: AppTheme.spacingM),
                  Text(
                    'DETALLE DE ÍTEMS (${rq.items.length})',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.1),
                      borderRadius: AppTheme.borderRadiusMedium,
                      border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${rq.items.length} ÍTEMS',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.divider),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 60,
                dataRowHeight: 60,
                columnSpacing: AppTheme.spacingXL,
                horizontalMargin: AppTheme.spacingL,
                dividerThickness: 0,
                headingTextStyle: AppTheme.labelMedium.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                columns: [
                  DataColumn(
                    label: Row(
                      children: [
                        Text('# ', style: TextStyle(color: AppTheme.primary)),
                        Icon(Icons.tag_outlined, size: 14, color: AppTheme.primary),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      children: [
                        Text('CÓDIGO ', style: TextStyle(color: AppTheme.primary)),
                        Icon(Icons.code_outlined, size: 14, color: AppTheme.primary),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      children: [
                        Text('DESCRIPCIÓN ', style: TextStyle(color: AppTheme.primary)),
                        Icon(Icons.description_outlined, size: 14, color: AppTheme.primary),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      children: [
                        Text('CANTIDAD ', style: TextStyle(color: AppTheme.primary)),
                        Icon(Icons.numbers_outlined, size: 14, color: AppTheme.primary),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      children: [
                        Text('UNIDAD ', style: TextStyle(color: AppTheme.primary)),
                        Icon(Icons.square_foot_outlined, size: 14, color: AppTheme.primary),
                      ],
                    ),
                  ),
                ],
                rows: rq.items.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingS),
                          decoration: BoxDecoration(
                            color: index % 2 == 0 
                              ? AppTheme.secondary.withOpacity(0.1)
                              : AppTheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            index.toString(),
                            style: AppTheme.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: index % 2 == 0 
                                ? AppTheme.secondary
                                : AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          item.codigo,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Text(
                            item.descripcion,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                            vertical: AppTheme.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: AppTheme.borderRadiusMedium,
                            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                          ),
                          child: Text(
                            item.cantidad.toStringAsFixed(0),
                            style: AppTheme.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                            vertical: AppTheme.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.textPrimary.withOpacity(0.05),
                            borderRadius: AppTheme.borderRadiusMedium,
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(
                            item.unidad,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: AppButton(
        text: 'AGREGAR ÍTEMS A ORDEN DE COMPRA',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SeleccionarItemsOCScreen(rq: rq),
            ),
          );
        },
        backgroundColor: AppTheme.primary,
        textColor: AppTheme.background,
        icon: Icons.add_shopping_cart_outlined,
        isFullWidth: true,
        isElevated: true,
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off_outlined,
            color: AppTheme.textPrimary.withOpacity(0.2),
            size: 80,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          Text(
            'HISTORIAL EN DESARROLLO',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Funcionalidad próxima a implementar',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textDisabled,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingL,
              vertical: AppTheme.spacingM,
            ),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.1),
              borderRadius: AppTheme.borderRadiusMedium,
              border: Border.all(color: AppTheme.secondary),
            ),
            child: Text(
              'VERSIÓN ${DateFormat('yyyy').format(DateTime.now())}',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.secondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    return AppTheme.getStatusColor(status);
  }

  Color _getProgressColor() {
    return AppTheme.getProgressColor(rq.progresoCompra);
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: AppTheme.borderRadiusMedium,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: AppTheme.iconSizeSmall),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                title,
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            value,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}