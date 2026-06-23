import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/features/ordenes_compra/crear_oc_form_screen.dart';
import 'package:sistema_ocs/features/ordenes_compra/providers/oc_provider.dart';
import 'package:sistema_ocs/features/ordenes_compra/models/oc_item_model.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';

class ResumenOCScreen extends ConsumerWidget {
  const ResumenOCScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(ocProvider);
    final notifier = ref.read(ocProvider.notifier);

    return Scaffold(
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
              child: Icon(
                Icons.shopping_cart_checkout_rounded,
                color: AppTheme.primary,
                size: AppTheme.iconSizeMedium,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Text(
              'Resumen Orden de Compra',
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.background,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.1),
              borderRadius: AppTheme.borderRadiusMedium,
              border: Border.all(color: AppTheme.error.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.delete_forever_rounded,
                color: AppTheme.error,
                size: AppTheme.iconSizeMedium,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AppCard(
                    backgroundColor: AppTheme.background,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.error,
                          size: 48,
                        ),
                        const SizedBox(height: AppTheme.spacingL),
                        Text(
                          '¿Eliminar toda la OC?',
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Text(
                          'Esta acción eliminará todos los ítems de la orden de compra actual.',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXL),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppTheme.borderRadiusMedium,
                                  ),
                                  side: BorderSide(color: AppTheme.border),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppTheme.spacingM,
                                  ),
                                ),
                                child: Text(
                                  'Cancelar',
                                  style: AppTheme.labelLarge.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingM),
                            Expanded(
                              child: AppButton(
                                text: 'Eliminar Todo',
                                onPressed: () {
                                  notifier.clearOC();
                                  Navigator.of(ctx).pop();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.check_circle_rounded,
                                              color: AppTheme.background),
                                          const SizedBox(width: AppTheme.spacingS),
                                          Text(
                                            'Orden de compra eliminada',
                                            style: AppTheme.labelLarge.copyWith(
                                              color: AppTheme.background,
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: AppTheme.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: AppTheme.borderRadiusMedium,
                                      ),
                                    ),
                                  );
                                },
                                backgroundColor: AppTheme.error,
                                textColor: AppTheme.background,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: AppTheme.textDisabled,
                    size: 64,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    'No hay ítems en la Orden de Compra',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Agrega ítems desde un requerimiento',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textDisabled,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.backgroundGradient,
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final OCItem item = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                          child: _buildItemCard(item, notifier),
                        );
                      },
                    ),
                  ),
                ),
                _buildTotalSection(notifier, items.length, context),
              ],
            ),
    );
  }

  Widget _buildItemCard(OCItem item, OCNotifier notifier) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.descripcion,
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                            vertical: AppTheme.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: AppTheme.borderRadiusSmall,
                          ),
                          child: Text(
                            'RQ ID: ${item.rqId}',
                            style: AppTheme.labelSmall.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: AppTheme.borderRadiusMedium,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.error,
                    size: AppTheme.iconSizeMedium,
                  ),
                  onPressed: () => notifier.removeItem(item.rqItemId),
                  tooltip: 'Eliminar ítem',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CANTIDAD',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                            vertical: AppTheme.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: AppTheme.borderRadiusSmall,
                            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                          ),
                          child: Text(
                            '${item.cantidadComprada.toStringAsFixed(0)}',
                            style: AppTheme.titleSmall.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          '/',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textDisabled,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          '${item.cantidadSolicitada.toStringAsFixed(0)} solicitados',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COSTO UNITARIO',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      'S/ ${item.costoUnitario.toStringAsFixed(2)}',
                      style: AppTheme.titleSmall.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'SUBTOTAL',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      'S/ ${item.subtotal.toStringAsFixed(2)}',
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(OCNotifier notifier, int itemCount, BuildContext context) {
    final total = notifier.total;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL A PAGAR',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$itemCount ítem(s)',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textDisabled,
                    ),
                  ),
                ],
              ),
              Text(
                'S/ ${total.toStringAsFixed(2)}',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          AppButton(
            text: 'Continuar con Orden de Compra',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CrearOCFormScreen(),
                ),
              );
            },
            backgroundColor: AppTheme.primary,
            textColor: AppTheme.background,
            icon: Icons.arrow_forward_rounded,
            isFullWidth: true,
            isElevated: true,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Revisa los detalles antes de continuar',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}