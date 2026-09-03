import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';
import 'package:sistema_ocs/features/almacen/articulos/articulo_provider.dart';

enum _TipoArticulo { insumo, equipo }

class ArticuloFormScreen extends ConsumerStatefulWidget {
  final ArticuloModel? articulo;

  const ArticuloFormScreen({super.key, this.articulo});

  bool get isEdit => articulo != null;

  @override
  ConsumerState<ArticuloFormScreen> createState() => _ArticuloFormScreenState();
}

class _ArticuloFormScreenState extends ConsumerState<ArticuloFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _unidadController;
  late final TextEditingController _codigoController;
  late final TextEditingController _serieController;
  late _TipoArticulo _tipo;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.articulo;
    _nombreController = TextEditingController(text: a?.nombre ?? '');
    _unidadController = TextEditingController(text: a?.unidadMedida ?? '');
    _codigoController = TextEditingController(text: a?.codigoExcel ?? '');
    _serieController = TextEditingController(text: a?.serie ?? '');
    _tipo = (a != null && a.esEquipo)
        ? _TipoArticulo.equipo
        : _TipoArticulo.insumo;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _unidadController.dispose();
    _codigoController.dispose();
    _serieController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final data = {
      'nombre': _nombreController.text.trim(),
      'unidad_medida': _unidadController.text.trim(),
      'tipo': _tipo.name,
      'codigo_excel': _codigoController.text.trim(),
      'serie': _serieController.text.trim(),
    };

    try {
      final notifier = ref.read(articulosListProvider.notifier);
      if (widget.isEdit) {
        await notifier.actualizar(widget.articulo!.id, data);
      } else {
        await notifier.crear(data);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Editar Artículo' : 'Nuevo Artículo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Información del artículo',
                  style: AppTheme.titleMedium),
              const SizedBox(height: AppTheme.spacingL),

              TextFormField(
                controller: _nombreController,
                decoration: AppTheme.inputDecoration.copyWith(
                  labelText: 'Nombre *',
                  hintText: 'Ej: Laptop HP Pavilion',
                  prefixIcon: const Icon(LucideIcons.package),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingrese el nombre'
                    : null,
              ),
              const SizedBox(height: AppTheme.spacingL),

              TextFormField(
                controller: _unidadController,
                decoration: AppTheme.inputDecoration.copyWith(
                  labelText: 'Unidad de medida',
                  hintText: 'Ej: unidad, caja, m²',
                  prefixIcon: const Icon(LucideIcons.ruler),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),

              TextFormField(
                controller: _codigoController,
                decoration: AppTheme.inputDecoration.copyWith(
                  labelText: 'Código (excel)',
                  prefixIcon: const Icon(LucideIcons.barcode),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),

              TextFormField(
                controller: _serieController,
                decoration: AppTheme.inputDecoration.copyWith(
                  labelText: 'Número de serie',
                  prefixIcon: const Icon(LucideIcons.hash),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),

              Text('Tipo de artículo', style: AppTheme.titleMedium),
              const SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _tipoSelector(
                      tipo: _TipoArticulo.insumo,
                      icon: LucideIcons.package,
                      label: 'Insumo',
                      subtitle: 'Tiene stock múltiple',
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _tipoSelector(
                      tipo: _TipoArticulo.equipo,
                      icon: LucideIcons.laptop,
                      label: 'Equipo',
                      subtitle: 'Stock = 1 (por serie)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingXXXL),

              AppButton(
                text: widget.isEdit ? 'Guardar cambios' : 'Crear artículo',
                icon: LucideIcons.save,
                isFullWidth: true,
                onPressed: _saving ? () {} : _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipoSelector({
    required _TipoArticulo tipo,
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    final selected = _tipo == tipo;
    return InkWell(
      borderRadius: AppTheme.borderRadiusLarge,
      onTap: () => setState(() => _tipo = tipo),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryLight : AppTheme.surface,
          borderRadius: AppTheme.borderRadiusLarge,
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? AppTheme.primary : AppTheme.textDisabled,
                size: AppTheme.iconSizeExtraLarge),
            const SizedBox(height: AppTheme.spacingS),
            Text(label,
                style: AppTheme.labelLarge.copyWith(
                  color: selected ? AppTheme.primary : AppTheme.textPrimary,
                )),
            const SizedBox(height: AppTheme.spacingXS),
            Text(subtitle,
                textAlign: TextAlign.center, style: AppTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
