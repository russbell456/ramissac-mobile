
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_ocs/core/design_system/ramis_design_system.dart';
import 'package:sistema_ocs/data/models/articulo_model.dart';
import 'package:sistema_ocs/features/almacen/articulos/articulo_provider.dart';
import 'package:sistema_ocs/features/almacen/articulos/widgets/articulo_detail_widgets.dart';

class ArticuloFormScreen extends ConsumerStatefulWidget {
  final ArticuloModel? articulo;

  const ArticuloFormScreen({
    super.key,
    this.articulo,
  });

  bool get esEdicion => articulo != null;

  @override
  ConsumerState<ArticuloFormScreen> createState() =>
      _ArticuloFormScreenState();
}

class _ArticuloFormScreenState
    extends ConsumerState<ArticuloFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreController;
  late final TextEditingController _marcaController;
  late final TextEditingController _modeloController;
  late final TextEditingController _serieController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _categoriaController;
  late final TextEditingController _unidadController;
  late final TextEditingController _codigoController;
  late final TextEditingController _stockTotalController;
  late final TextEditingController _stockActualController;
  late final TextEditingController _costoHoraController;
  late final TextEditingController _costoDiaController;
  late final TextEditingController _costoReposicionController;
  late final TextEditingController _estadoFisicoController;

  String _tipo = 'EQUIPO';
  bool _esActivoAltoValor = false;
  bool _guardando = false;
  final List<PlatformFile> _imagenesPendientes = [];

  static const _maxImageBytes = 5 * 1024 * 1024;

  static const _tipos = [
    'EQUIPO',
    'HERRAMIENTA',
    'CONSUMIBLE',
  ];

  // =====================================================
  // INICIALIZACIÓN
  // =====================================================

  @override
  void initState() {
    super.initState();

    final articulo = widget.articulo;

    _nombreController = TextEditingController(
      text: articulo?.nombre ?? '',
    );

    _marcaController = TextEditingController(
      text: articulo?.marca ?? '',
    );

    _modeloController = TextEditingController(
      text: articulo?.modelo ?? '',
    );

    _serieController = TextEditingController(
      text: articulo?.serie ?? '',
    );

    _descripcionController = TextEditingController(
      text: articulo?.descripcion ?? '',
    );

    _categoriaController = TextEditingController(
      text: articulo?.categoria ?? '',
    );

    _unidadController = TextEditingController(
      text: articulo?.unidadMedida ?? '',
    );

    _codigoController = TextEditingController(
      text: articulo?.codigoExcel ?? '',
    );

    _stockTotalController = TextEditingController(
      text: articulo?.stockTotal.toString() ?? '0',
    );

    _stockActualController = TextEditingController(
      text: articulo?.stockActual.toString() ?? '0',
    );

    _costoHoraController = TextEditingController(
      text: articulo?.costoHora?.toString() ?? '',
    );

    _costoDiaController = TextEditingController(
      text: articulo?.costoDia?.toString() ?? '',
    );

    _costoReposicionController = TextEditingController(
      text: articulo?.costoReposicion?.toString() ?? '',
    );

    _estadoFisicoController = TextEditingController(
      text: articulo?.estadoFisico ?? '',
    );

    if (articulo != null) {
      _tipo = articulo.tipo.toUpperCase();
      _esActivoAltoValor = articulo.esActivoAltoValor;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _serieController.dispose();
    _descripcionController.dispose();
    _categoriaController.dispose();
    _unidadController.dispose();
    _codigoController.dispose();
    _stockTotalController.dispose();
    _stockActualController.dispose();
    _costoHoraController.dispose();
    _costoDiaController.dispose();
    _costoReposicionController.dispose();
    _estadoFisicoController.dispose();

    super.dispose();
  }

  // =====================================================
  // HELPERS DE DATOS
  // =====================================================

  int _parseInt(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  double? _parseDouble(String value) {
    final text = value.trim();

    if (text.isEmpty) return null;

    return double.tryParse(
      text.replaceAll(',', '.'),
    );
  }

  String? _nullableText(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  String _tipoLabel(String tipo) {
    switch (tipo) {
      case 'EQUIPO':
        return 'Equipo';
      case 'HERRAMIENTA':
        return 'Herramienta';
      case 'CONSUMIBLE':
        return 'Consumible';
      default:
        return tipo;
    }
  }

  Future<void> _seleccionarImagenes() async {
    if (_guardando) return;

    try {
      final selection = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
        allowMultiple: true,
      );
      if (!mounted || selection == null) return;

      final currentPaths = _imagenesPendientes
          .map((image) => image.path)
          .whereType<String>()
          .toSet();
      final validImages = <PlatformFile>[];
      final rejectedImages = <String>[];

      for (final image in selection.files) {
        final path = image.path;
        if (path == null || path.isEmpty) {
          rejectedImages.add(image.name);
          continue;
        }
        if (image.size > _maxImageBytes) {
          rejectedImages.add('${image.name} (supera 5 MB)');
          continue;
        }
        if (currentPaths.add(path)) validImages.add(image);
      }

      if (validImages.isNotEmpty) {
        setState(() => _imagenesPendientes.addAll(validImages));
      }

      if (rejectedImages.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se agregaron: ${rejectedImages.join(', ')}. '
              'Usa JPG, PNG o WEBP de hasta 5 MB.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron seleccionar las imágenes: $error')),
      );
    }
  }

  void _quitarImagenPendiente(PlatformFile image) {
    setState(() => _imagenesPendientes.remove(image));
  }

  // =====================================================
  // GUARDAR - LÓGICA ORIGINAL
  // =====================================================

  Future<void> _guardar() async {
    if (_guardando) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _guardando = true;
    });

    try {
      final esEdicion = widget.esEdicion;

      final articulo = ArticuloModel(
        id: widget.articulo?.id ?? 0,

        nombre: _nombreController.text.trim(),
        marca: _nullableText(_marcaController.text),
        modelo: _nullableText(_modeloController.text),
        serie: _nullableText(_serieController.text),

        descripcion: _nullableText(
          _descripcionController.text,
        ),

        categoria: _nullableText(
          _categoriaController.text,
        ),

        unidadMedida: _unidadController.text.trim(),
        tipo: _tipo,

        codigoExcel: _nullableText(
          _codigoController.text,
        ),

        // El stock sigue siendo inmutable
        // desde la edición del artículo.
        stockTotal: esEdicion
            ? widget.articulo!.stockTotal
            : _parseInt(_stockTotalController.text),

        stockActual: esEdicion
            ? widget.articulo!.stockActual
            : _parseInt(_stockActualController.text),

        enPrestamo: widget.articulo?.enPrestamo ?? 0,

        estadoFisico: _nullableText(
          _estadoFisicoController.text,
        ),

        costoHora: _parseDouble(
          _costoHoraController.text,
        ),

        costoDia: _parseDouble(
          _costoDiaController.text,
        ),

        costoReposicion: _parseDouble(
          _costoReposicionController.text,
        ),

        requiereFotoPrestamo: _esActivoAltoValor,
        requiereFotoDevolucion: _esActivoAltoValor,
        esActivoAltoValor: _esActivoAltoValor,

        activo: widget.articulo?.activo ?? true,
        fechaBaja: widget.articulo?.fechaBaja,
        imagenes: widget.articulo?.imagenes ?? const [],
      );

      final notifier =
          ref.read(articulosListProvider.notifier);

      final ArticuloModel guardado;
      if (esEdicion) {
        guardado = await notifier.actualizar(
          widget.articulo!.id,
          articulo.toUpdateJson(),
        );
      } else {
        guardado = await notifier.crear(
          articulo.toCreateJson(),
        );
      }

      final imagePaths = _imagenesPendientes
          .map((image) => image.path)
          .whereType<String>()
          .toList();
      final imageFailures = imagePaths.isEmpty
          ? <String, String>{}
          : await notifier.subirImagenes(guardado.id, imagePaths);

      if (!mounted) return;

      if (imageFailures.isNotEmpty) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Artículo guardado con imágenes pendientes'),
            content: Text(
              'No se pudieron subir: ${imageFailures.keys.map((path) => path.split(Platform.pathSeparator).last).join(', ')}. '
              'Puedes volver a intentarlo desde la edición del artículo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Continuar'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              esEdicion
                  ? 'Artículo actualizado correctamente'
                  : 'Artículo creado correctamente',
            ),
          ),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor:
              Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  // =====================================================
  // COMPONENTE LOCAL: CAMPO ESTANDARIZADO
  // =====================================================

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return RamisTextField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: icon == null
          ? null
          : Icon(icon, size: 20),
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: !_guardando,
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            }
          : null,
    );
  }

  // =====================================================
  // LAYOUT ADAPTABLE PARA DOS CAMPOS
  // =====================================================

  Widget _fieldPair({
    required Widget first,
    required Widget second,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 500;

        if (!isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              first,
              const SizedBox(height: 12),
              second,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ],
        );
      },
    );
  }

  // =====================================================
  // SCREEN PRINCIPAL
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.esEdicion;

    return RamisScaffold(
      appBar: RamisAppBar(
        title: esEdicion
            ? 'Editar artículo'
            : 'Nuevo artículo',
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 800,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                40,
              ),
              children: [
                _buildIntroduction(context),

                const SizedBox(height: 16),

                _buildGeneralInformation(),

                const SizedBox(height: 16),

                _buildArticleType(),

                const SizedBox(height: 16),

                _buildIdentification(),

                const SizedBox(height: 16),

                _buildImages(),

                const SizedBox(height: 16),

                _buildStock(),

                const SizedBox(height: 16),

                _buildCosts(),

                const SizedBox(height: 16),

                _buildPhysicalState(),

                const SizedBox(height: 16),

                _buildConfiguration(),

                const SizedBox(height: 24),

                RamisButton(
                  label: _guardando
                      ? 'Guardando...'
                      : esEdicion
                          ? 'Guardar cambios'
                          : 'Crear artículo',
                  icon: Icons.save_outlined,
                  onPressed: _guardando ? null : _guardar,
                  isLoading: _guardando,
                  fullWidth: true,
                  height: 52,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // PRESENTACIÓN DEL FORMULARIO
  // =====================================================

  Widget _buildIntroduction(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return RamisCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: RamisRadius.medium,
            ),
            child: Icon(
              widget.esEdicion
                  ? Icons.edit_note_rounded
                  : Icons.add_box_outlined,
              color: scheme.onPrimaryContainer,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.esEdicion
                      ? 'Actualizar artículo'
                      : 'Registrar artículo',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  widget.esEdicion
                      ? 'Modifica los datos del artículo '
                          'y guarda los cambios.'
                      : 'Completa los datos para agregar un '
                          'artículo al inventario.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.ramis.textSecondary,
                    height: 1.5,
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
  // INFORMACIÓN GENERAL
  // =====================================================

  Widget _buildGeneralInformation() {
    return ArticuloDetailSection(
      title: 'Información general',
      icon: Icons.inventory_2_outlined,
      children: [
        _field(
          controller: _nombreController,
          label: 'Nombre',
          hint: 'Nombre del artículo',
          icon: Icons.inventory_2_outlined,
          isRequired: true,
        ),

        const SizedBox(height: 12),

        _fieldPair(
          first: _field(
            controller: _marcaController,
            label: 'Marca',
            icon: Icons.business_outlined,
          ),
          second: _field(
            controller: _modeloController,
            label: 'Modelo',
            icon: Icons.category_outlined,
          ),
        ),

        const SizedBox(height: 12),

        _field(
          controller: _categoriaController,
          label: 'Categoría',
          icon: Icons.folder_outlined,
        ),

        const SizedBox(height: 12),

        _field(
          controller: _descripcionController,
          label: 'Descripción',
          hint: 'Describe las características del artículo',
          icon: Icons.description_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  // =====================================================
  // TIPO DE ARTÍCULO
  // =====================================================

  Widget _buildArticleType() {
    final tiposDisponibles = [
      ..._tipos,
      if (!_tipos.contains(_tipo)) _tipo,
    ];

    return ArticuloDetailSection(
      title: 'Tipo de artículo',
      icon: Icons.category_outlined,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _tipo,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Tipo',
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items: tiposDisponibles.map((tipo) {
            return DropdownMenuItem<String>(
              value: tipo,
              child: Text(
                _tipoLabel(tipo),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: _guardando
              ? null
              : (value) {
                  if (value == null) return;

                  setState(() {
                    _tipo = value;
                  });
                },
        ),
      ],
    );
  }

  // =====================================================
  // IDENTIFICACIÓN
  // =====================================================

  Widget _buildIdentification() {
    return ArticuloDetailSection(
      title: 'Identificación',
      icon: Icons.qr_code_rounded,
      children: [
        _field(
          controller: _codigoController,
          label: 'Código Excel',
          hint: 'Código interno del artículo',
          icon: Icons.qr_code_rounded,
        ),

        const SizedBox(height: 12),

        _field(
          controller: _serieController,
          label: 'Número de serie',
          icon: Icons.tag_outlined,
        ),

        const SizedBox(height: 12),

        _field(
          controller: _unidadController,
          label: 'Unidad de medida',
          hint: 'Ejemplo: UND, KG, LT',
          icon: Icons.straighten_outlined,
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildImages() {
    final theme = Theme.of(context);

    return ArticuloDetailSection(
      title: 'Imágenes del artículo',
      icon: Icons.photo_library_outlined,
      children: [
        Text(
          'Selecciona fotos para identificar el artículo. '
          'JPG, PNG o WEBP; máximo 5 MB por imagen.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: context.ramis.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        RamisButton(
          label: 'Agregar imágenes',
          variant: RamisButtonVariant.outlined,
          icon: Icons.add_photo_alternate_outlined,
          fullWidth: true,
          isDisabled: _guardando,
          onPressed: _seleccionarImagenes,
        ),
        if (_imagenesPendientes.isEmpty) ...[
          const SizedBox(height: 12),
          const Text('Aún no has seleccionado imágenes.'),
        ] else ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _imagenesPendientes.map((image) {
              final path = image.path;
              return SizedBox(
                width: 118,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: RamisRadius.small,
                      child: SizedBox(
                        height: 96,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (path != null)
                              Image.file(
                                File(path),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const ColoredBox(
                                  color: Color(0x11000000),
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              )
                            else
                              const ColoredBox(
                                color: Color(0x11000000),
                                child: Icon(Icons.image_not_supported_outlined),
                              ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Material(
                                color: Colors.black54,
                                shape: const CircleBorder(),
                                child: IconButton(
                                  tooltip: 'Quitar imagen',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: _guardando
                                      ? null
                                      : () => _quitarImagenPendiente(image),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      image.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // =====================================================
  // STOCK
  // =====================================================

  Widget _buildStock() {
    return ArticuloDetailSection(
      title: 'Stock',
      icon: Icons.inventory_outlined,
      children: [
        if (widget.esEdicion)
          const ArticuloInfoBanner(
            icon: Icons.info_outline_rounded,
            title: 'Stock protegido',
            message:
                'El stock no se modifica desde la edición '
                'del artículo.',
            severity: ArticuloBannerSeverity.info,
          )
        else
          _fieldPair(
            first: _field(
              controller: _stockTotalController,
              label: 'Stock total',
              icon: Icons.inventory_outlined,
              keyboardType: TextInputType.number,
              isRequired: true,
            ),
            second: _field(
              controller: _stockActualController,
              label: 'Stock actual',
              icon: Icons.inventory_2_outlined,
              keyboardType: TextInputType.number,
              isRequired: true,
            ),
          ),
      ],
    );
  }

  // =====================================================
  // COSTOS
  // =====================================================

  Widget _buildCosts() {
    const decimalKeyboard = TextInputType.numberWithOptions(
      decimal: true,
    );

    return ArticuloDetailSection(
      title: 'Costos',
      icon: Icons.payments_outlined,
      children: [
        _fieldPair(
          first: _field(
            controller: _costoHoraController,
            label: 'Costo / hora',
            icon: Icons.schedule_outlined,
            keyboardType: decimalKeyboard,
          ),
          second: _field(
            controller: _costoDiaController,
            label: 'Costo / día',
            icon: Icons.today_outlined,
            keyboardType: decimalKeyboard,
          ),
        ),

        const SizedBox(height: 12),

        _field(
          controller: _costoReposicionController,
          label: 'Costo de reposición',
          icon: Icons.price_change_outlined,
          keyboardType: decimalKeyboard,
        ),
      ],
    );
  }

  // =====================================================
  // ESTADO FÍSICO
  // =====================================================

  Widget _buildPhysicalState() {
    return ArticuloDetailSection(
      title: 'Estado físico',
      icon: Icons.build_outlined,
      children: [
        _field(
          controller: _estadoFisicoController,
          label: 'Estado físico',
          hint: 'Ejemplo: Bueno, regular, malo',
          icon: Icons.build_circle_outlined,
        ),
      ],
    );
  }

  // =====================================================
  // CONFIGURACIÓN
  // =====================================================

  Widget _buildConfiguration() {
    final theme = Theme.of(context);

    return ArticuloDetailSection(
      title: 'Configuración',
      icon: Icons.settings_outlined,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(
            Icons.workspace_premium_outlined,
            color: theme.colorScheme.primary,
          ),
          title: const Text('Activo de alto valor'),
          subtitle: const Text(
            'Identifica artículos que requieren mayor control.',
          ),
          value: _esActivoAltoValor,
          onChanged: _guardando
              ? null
              : (value) {
                  setState(() {
                    _esActivoAltoValor = value;
                  });
                },
        ),

        Divider(
          color: context.ramis.border,
        ),

        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(
            Icons.add_a_photo_outlined,
          ),
          title: const Text('Requiere foto en préstamo'),
          subtitle: const Text(
            'Se activa automáticamente para artículos '
            'de alto valor.',
          ),
          value: _esActivoAltoValor,
          onChanged: null,
        ),

        Divider(
          color: context.ramis.border,
        ),

        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(
            Icons.photo_camera_back_outlined,
          ),
          title: const Text('Requiere foto en devolución'),
          subtitle: const Text(
            'Se activa automáticamente para artículos '
            'de alto valor.',
          ),
          value: _esActivoAltoValor,
          onChanged: null,
        ),
      ],
    );
  }
}
