import 'dart:convert';
import 'dart:io'; // 💡 IMPORTANTE para File
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';
import 'package:sistema_ocs/features/ordenes_compra/providers/oc_provider.dart';
import 'package:sistema_ocs/features/ordenes_compra/models/orden_compra_request.dart';
import 'package:sistema_ocs/data/services/orden_compra_service.dart';

class CrearOCFormScreen extends ConsumerStatefulWidget {
  const CrearOCFormScreen({super.key});

  @override
  ConsumerState<CrearOCFormScreen> createState() => _CrearOCFormScreenState();
}

class _CrearOCFormScreenState extends ConsumerState<CrearOCFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para el JSON completo
  final _proveedorCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController(text: "ALMACEN CENTRAL");
  final _costoEnvioCtrl = TextEditingController(text: "0.0");
  final _notasCtrl = TextEditingController();
  String _tipoCompra = "FISICA"; // O "ENVIO"

  void _guardarLocalmente() {
    if (!_formKey.currentState!.validate()) return;

    final itemsCarrito = ref.read(ocProvider);
    
    final nuevaOC = OrdenCompraRequest(
      idLocal: DateTime.now().millisecondsSinceEpoch.toString(),
      estado: "comprado",
      proveedor: _proveedorCtrl.text,
      ubicacionEnvio: _ubicacionCtrl.text,
      tipoCompra: _tipoCompra,
      costoEnvio: double.tryParse(_costoEnvioCtrl.text) ?? 0.0,
      notas: _notasCtrl.text,
      fecha: DateTime.now().toIso8601String().split('T')[0],
      itemsComprados: itemsCarrito,
      comprobantes: [], // Se llenará en el paso de "Mandar"
    );

    // Guardar en la lista de borradores
    ref.read(listaOrdenesLocalesProvider.notifier).guardarOrden(nuevaOC);
    
    // Limpiar carrito temporal
    ref.read(ocProvider.notifier).clearOC();

    // Regresar al inicio (Dashboard)
    Navigator.of(context).popUntil((route) => route.isFirst);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📦 Orden guardada en 'Mis Compras'"))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Finalizar Datos de Orden")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _proveedorCtrl, decoration: const InputDecoration(labelText: "Proveedor")),
            DropdownButtonFormField<String>(
              value: _tipoCompra,
              items: ["FISICA", "ENVIO"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _tipoCompra = val!),
              decoration: const InputDecoration(labelText: "Tipo de Compra"),
            ),
            if (_tipoCompra == "ENVIO")
              TextFormField(controller: _costoEnvioCtrl, decoration: const InputDecoration(labelText: "Costo de Envío"), keyboardType: TextInputType.number),
            TextFormField(controller: _ubicacionCtrl, decoration: const InputDecoration(labelText: "Ubicación de Envío")),
            TextFormField(controller: _notasCtrl, decoration: const InputDecoration(labelText: "Notas"), maxLines: 3),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardarLocalmente,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text("GUARDAR LOCALMENTE"),
            )
          ],
        ),
      ),
    );
  }
}