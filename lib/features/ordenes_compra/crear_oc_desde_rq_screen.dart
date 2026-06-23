import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';
import 'package:sistema_ocs/data/models/rq_model.dart';
import 'package:sistema_ocs/features/ordenes_compra/models/oc_item_model.dart';
import 'package:sistema_ocs/features/ordenes_compra/models/orden_compra_request.dart';
import 'package:sistema_ocs/features/ordenes_compra/providers/oc_provider.dart';

class CrearOCDesdeRQScreen extends ConsumerStatefulWidget {
  final RQResponse rq;
  const CrearOCDesdeRQScreen({super.key, required this.rq});

  @override
  ConsumerState<CrearOCDesdeRQScreen> createState() => _CrearOCDesdeRQScreenState();
}

class _CrearOCDesdeRQScreenState extends ConsumerState<CrearOCDesdeRQScreen> {
  final TextEditingController _proveedorCtrl = TextEditingController();
  final TextEditingController _notasCtrl = TextEditingController();
  final TextEditingController _ubicacionCtrl = TextEditingController();
  String _tipoCompra = "FISICA"; // FISICA o ENVIO
  
  // Lista temporal para manejar archivos seleccionados localmente
  List<ComprobanteLocal> _comprobantesSeleccionados = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OC desde RQ ${widget.rq.nroRq}')),
      body: SingleChildScrollView( // Cambiado para evitar desbordamiento
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildItemsSeleccionables(),
            const Divider(),
            _buildDatosOrden(),
            const SizedBox(height: 20),
            _buildSeccionArchivos(), // 💡 NUEVO: Selección de comprobantes
            const SizedBox(height: 20),
            _buildCrearButton(),
          ],
        ),
      ),
    );
  }

  // 1️⃣ Items con campos para cantidad y costo
  Widget _buildItemsSeleccionables() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.rq.items.length,
      itemBuilder: (context, index) {
        final item = widget.rq.items[index];
        return Card(
          child: ExpansionTile(
            title: Text(item.descripcion),
            subtitle: Text('Solicitado: ${item.cantidad}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(child: TextField(
                      decoration: const InputDecoration(labelText: 'Cant. Compra'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _actualizarItemCarrito(item, cant: val),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(
                      decoration: const InputDecoration(labelText: 'Costo Unit.'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _actualizarItemCarrito(item, precio: val),
                    )),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // 2️⃣ Datos básicos + Tipo de Compra
  Widget _buildDatosOrden() {
    return Column(
      children: [
        TextField(controller: _proveedorCtrl, decoration: const InputDecoration(labelText: 'Proveedor')),
        DropdownButtonFormField<String>(
          value: _tipoCompra,
          items: const [
            DropdownMenuItem(value: "FISICA", child: Text("Compra Física")),
            DropdownMenuItem(value: "ENVIO", child: Text("Compra por Envío")),
          ],
          onChanged: (val) => setState(() => _tipoCompra = val!),
          decoration: const InputDecoration(labelText: 'Modalidad de Compra'),
        ),
        if (_tipoCompra == "ENVIO")
          TextField(controller: _ubicacionCtrl, decoration: const InputDecoration(labelText: 'Ubicación de Envío')),
      ],
    );
  }

  // 💡 NUEVO: Selector de archivos usando file_picker
  Widget _buildSeccionArchivos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Comprobantes (Fotos/PDF)", style: TextStyle(fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          onPressed: _seleccionarArchivo,
          icon: const Icon(Icons.attach_file),
          label: const Text("Adjuntar Comprobante"),
        ),
        ..._comprobantesSeleccionados.map((c) => ListTile(
          title: Text(c.tipoDocumento),
          subtitle: Text(c.archivoRuta!.split('/').last),
          trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () {
            setState(() => _comprobantesSeleccionados.remove(c));
          }),
        )),
      ],
    );
  }

  // 3️⃣ BOTÓN FINALIZAR (Guarda Borrador Local)
  Widget _buildCrearButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
        onPressed: _guardarComoBorrador,
        child: const Text('Guardar como Borrador', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // --- LÓGICA DE SOPORTE ---

  void _actualizarItemCarrito(dynamic itemRq, {String? cant, String? precio}) {
    final nuevoItem = OCItem(
      rqId: widget.rq.id,
      rqItemId: itemRq.id,
      descripcion: itemRq.descripcion,
      cantidadSolicitada: itemRq.cantidad.toDouble(),
      cantidadComprada: double.tryParse(cant ?? "0") ?? 0,
      costoUnitario: double.tryParse(precio ?? "0") ?? 0,
    );
    ref.read(ocProvider.notifier).addItem(nuevoItem);
  }

  Future<void> _seleccionarArchivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      // Aquí podrías abrir un diálogo para preguntar si es MERCADERIA_COMPROBANTE o GUIA_REMISION
      setState(() {
        _comprobantesSeleccionados.add(ComprobanteLocal(
          tipoDocumento: "MERCADERIA_COMPROBANTE", 
          archivoRuta: result.files.single.path,
        ));
      });
    }
  }

  void _guardarComoBorrador() {
    final itemsCarrito = ref.read(ocProvider);
    if (itemsCarrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Agrega al menos un ítem")));
      return;
    }

    final nuevaOrden = OrdenCompraRequest(
      idLocal: DateTime.now().millisecondsSinceEpoch.toString(), // ID ÚNICO LOCAL
      estado: "pendiente",
      proveedor: _proveedorCtrl.text,
      tipoCompra: _tipoCompra,
      fecha: DateTime.now().toIso8601String().split('T')[0],
      ubicacionEnvio: _ubicacionCtrl.text,
      itemsComprados: itemsCarrito,
      comprobantes: _comprobantesSeleccionados,
    );

    // Guardar en la lista de borradores
    ref.read(listaOrdenesLocalesProvider.notifier).guardarOrden(nuevaOrden);
    
    // Limpiar carrito temporal y volver
    ref.read(ocProvider.notifier).clearOC();
    Navigator.pop(context); 
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Borrador guardado correctamente")));
  }
}