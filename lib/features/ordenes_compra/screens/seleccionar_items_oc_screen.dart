import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';
import 'package:sistema_ocs/data/models/rq_item_model.dart';
import 'package:sistema_ocs/data/models/rq_model.dart';
import 'package:sistema_ocs/features/ordenes_compra/models/oc_item_model.dart';
import 'package:sistema_ocs/features/ordenes_compra/providers/oc_provider.dart';

class SeleccionarItemsOCScreen extends ConsumerStatefulWidget {
  final RQResponse rq;

  const SeleccionarItemsOCScreen({super.key, required this.rq});

  @override
  ConsumerState<SeleccionarItemsOCScreen> createState() =>
      _SeleccionarItemsOCScreenState();
}

class _SeleccionarItemsOCScreenState
    extends ConsumerState<SeleccionarItemsOCScreen> {
  final Map<int, bool> seleccionados = {};
  final Map<int, TextEditingController> cantidadCtrl = {};
  final Map<int, TextEditingController> costoCtrl = {};
  final Map<int, FocusNode> cantidadFocus = {};
  final Map<int, FocusNode> costoFocus = {};

  @override
  void initState() {
    super.initState();
    for (var item in widget.rq.items) {
      seleccionados[item.id] = false;
      cantidadCtrl[item.id] = TextEditingController();
      costoCtrl[item.id] = TextEditingController();
      cantidadFocus[item.id] = FocusNode();
      costoFocus[item.id] = FocusNode();
    }
  }

  @override
  void dispose() {
    for (var c in cantidadCtrl.values) {
      c.dispose();
    }
    for (var c in costoCtrl.values) {
      c.dispose();
    }
    for (var f in cantidadFocus.values) {
      f.dispose();
    }
    for (var f in costoFocus.values) {
      f.dispose();
    }
    super.dispose();
  }

  void _guardarItems() {
    final notifier = ref.read(ocProvider.notifier);
    int itemsAgregados = 0;

    for (var item in widget.rq.items) {
      if (seleccionados[item.id] == true) {
        final cantidad = double.tryParse(cantidadCtrl[item.id]!.text) ?? 0;
        final costo = double.tryParse(costoCtrl[item.id]!.text) ?? 0;
        
        if (cantidad > 0 && costo > 0) {
          notifier.addItem(
            OCItem(
              rqId: widget.rq.id,
              rqItemId: item.id,
              descripcion: item.descripcion,
              cantidadSolicitada: item.cantidad,
              cantidadComprada: cantidad,
              costoUnitario: costo,
            ),
          );
          itemsAgregados++;
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.secondary),
            const SizedBox(width: AppTheme.spacingS),
            Text(
              '$itemsAgregados ítem(s) agregado(s) a la OC',
              style: AppTheme.labelLarge.copyWith(color: AppTheme.background),
            ),
          ],
        ),
        backgroundColor: AppTheme.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.borderRadiusMedium,
          side: BorderSide(color: AppTheme.secondary, width: 1),
        ),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(AppTheme.spacingL),
      ),
    );

    Navigator.pop(context);
  }

  void _toggleAllItems(bool? value) {
    setState(() {
      for (var item in widget.rq.items) {
        seleccionados[item.id] = value ?? false;
      }
    });
  }

  Widget _buildHeader() {
    final selectedCount = seleccionados.values.where((v) => v).length;
    final totalCount = widget.rq.items.length;

    return AppCard(
      backgroundColor: AppTheme.background,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: AppTheme.borderRadiusMedium,
                  border: Border.all(color: AppTheme.primary, width: 1.5),
                ),
                child: Icon(
                  Icons.filter_list_rounded,
                  color: AppTheme.primary,
                  size: AppTheme.iconSizeLarge,
                ),
              ),
              const SizedBox(width: AppTheme.spacingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RQ ${widget.rq.nroRq}',
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      'Selección de Ítems para Orden de Compra',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXL),
          Row(
            children: [
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
                child: Row(
                  children: [
                    Icon(
                      Icons.checklist_rounded,
                      color: AppTheme.secondary,
                      size: AppTheme.iconSizeSmall,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      '$selectedCount/$totalCount SELECCIONADOS',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _toggleAllItems(selectedCount != totalCount),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingL,
                    vertical: AppTheme.spacingM,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: AppTheme.borderRadiusMedium,
                    border: Border.all(color: AppTheme.primary),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selectedCount == totalCount
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: AppTheme.primary,
                        size: AppTheme.iconSizeMedium,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        selectedCount == totalCount ? 'DESELECCIONAR TODOS' : 'SELECCIONAR TODOS',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(RQItemResponse item, int index) {
    final isSelected = seleccionados[item.id] ?? false;
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingM,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.secondary.withOpacity(0.05)
              : AppTheme.background,
          borderRadius: AppTheme.borderRadiusLarge,
          border: Border.all(
            color: isSelected
                ? AppTheme.secondary
                : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [AppTheme.cardShadow] : null,
        ),
        child: Column(
          children: [
            // Header del item
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXL,
                vertical: AppTheme.spacingL,
              ),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: AppTheme.borderRadiusMedium,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTheme.titleLarge.copyWith(
                      color: AppTheme.background,
                    ),
                  ),
                ),
              ),
              title: Text(
                item.codigo,
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                item.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              trailing: Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    seleccionados[item.id] = value ?? false;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderRadiusSmall,
                ),
                side: BorderSide(color: AppTheme.primary),
                activeColor: AppTheme.secondary,
                checkColor: AppTheme.background,
              ),
            ),
            
            // Información del item
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXL,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ItemInfo(
                      icon: Icons.scale_rounded,
                      label: 'SOLICITADO',
                      value: '${item.cantidad} ${item.unidad}',
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingL),
                  Expanded(
                    child: _ItemInfo(
                      icon: Icons.flag_rounded,
                      label: 'ESTADO',
                      value: isSelected ? 'SELECCIONADO' : 'PENDIENTE',
                      color: isSelected ? AppTheme.secondary : AppTheme.warning,
                    ),
                  ),
                ],
              ),
            ),
            
            // Campos de entrada (solo si está seleccionado)
            if (isSelected) ...[
              const SizedBox(height: AppTheme.spacingXL),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXL,
                ),
                child: Column(
                  children: [
                    _buildInputField(
                      controller: cantidadCtrl[item.id]!,
                      focusNode: cantidadFocus[item.id]!,
                      label: 'CANTIDAD A COMPRAR',
                      icon: Icons.numbers_rounded,
                      maxValue: item.cantidad,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildInputField(
                      controller: costoCtrl[item.id]!,
                      focusNode: costoFocus[item.id]!,
                      label: 'COSTO UNITARIO',
                      icon: Icons.attach_money_rounded,
                      isCurrency: true,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    _buildTotalPreview(item),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    double? maxValue,
    bool isCurrency = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: AppTheme.borderRadiusMedium,
            border: Border.all(
              color: focusNode.hasFocus ? AppTheme.secondary : AppTheme.border,
              width: focusNode.hasFocus ? 2 : 1,
            ),
            boxShadow: focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: AppTheme.secondary.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              const SizedBox(width: AppTheme.spacingL),
              Icon(
                icon,
                color: AppTheme.primary,
                size: AppTheme.iconSizeMedium,
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: isCurrency ? '0.00' : '0',
                    hintStyle: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textDisabled,
                    ),
                    suffixText: isCurrency ? 'USD' : null,
                    suffixStyle: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              if (maxValue != null)
                Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spacingL),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: AppTheme.borderRadiusSmall,
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Máx: ${maxValue.toStringAsFixed(0)}',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalPreview(RQItemResponse item) {
    final cantidad = double.tryParse(cantidadCtrl[item.id]!.text) ?? 0;
    final costo = double.tryParse(costoCtrl[item.id]!.text) ?? 0;
    final total = cantidad * costo;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: total > 0
            ? AppTheme.secondary.withOpacity(0.05)
            : AppTheme.background,
        borderRadius: AppTheme.borderRadiusMedium,
        border: Border.all(
          color: total > 0
              ? AppTheme.secondary.withOpacity(0.2)
              : AppTheme.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate_rounded,
                color: total > 0 ? AppTheme.secondary : AppTheme.textDisabled,
                size: AppTheme.iconSizeMedium,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'TOTAL ÍTEM',
                style: AppTheme.labelMedium.copyWith(
                  color: total > 0 ? AppTheme.secondary : AppTheme.textDisabled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: AppTheme.titleLarge.copyWith(
              color: total > 0 ? AppTheme.secondary : AppTheme.textDisabled,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    final selectedCount = seleccionados.values.where((v) => v).length;
    
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingXL),
      child: AppButton(
        text: 'AGREGAR $selectedCount ÍTEM(S)',
        onPressed: _guardarItems,
        backgroundColor: AppTheme.secondary,
        textColor: AppTheme.background,
        icon: Icons.check_circle_rounded,
        isFullWidth: true,
        isElevated: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.backgroundGradient,
                ),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: widget.rq.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.rq.items[index];
                    return _buildItemCard(item, index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingButton(),
    );
  }
}

class _ItemInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ItemInfo({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: AppTheme.borderRadiusMedium,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppTheme.iconSizeSmall,
            color: color,
          ),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value,
                  style: AppTheme.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}