import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/features/ordenes_compra/models/orden_compra_request.dart';
import 'package:sistema_ocs/features/ordenes_compra/providers/oc_provider.dart';
import 'package:sistema_ocs/data/services/orden_compra_service.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';
import 'package:sistema_ocs/features/ordenes_compra/screens/subircomprobantescreen.dart';

class OrdenesListaScreen extends ConsumerWidget {
  const OrdenesListaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordenesLocales = ref.watch(listaOrdenesLocalesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Órdenes (Borradores)')),
      body: ListView.builder(
        itemCount: ordenesLocales.length,
        itemBuilder: (context, index) {
          final orden = ordenesLocales[index];
          final esEnviado = orden.estado == 'enviado';

          return Card(
            child: ListTile(
              title: Text(orden.proveedor),
              subtitle: Text("Total: S/ ${orden.total.toStringAsFixed(2)}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // BOTÓN ELIMINAR
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => ref.read(listaOrdenesLocalesProvider.notifier).eliminarOrden(orden.idLocal!),
                  ),
                  // BOTÓN MANDAR (PALOMITA)
                  IconButton(
                    icon: Icon(esEnviado ? Icons.check_circle : Icons.send, 
                          color: esEnviado ? Colors.green : Colors.blue),
                    onPressed: esEnviado ? null : () => _procesoEnvioCompleto(context, ref, orden),
                  ),
                ],
              ),
              onTap: esEnviado ? null : () {
                // AQUÍ IRÍA LA LÓGICA DE EDITAR (Reabrir el formulario con datos)
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _procesoEnvioCompleto(BuildContext context, WidgetRef ref, OrdenCompraRequest orden) async {
    final service = OrdenCompraService();
    
    try {
      // 1. Enviar JSON al servidor
      final int ordenId = await service.crearOrden(orden);

      // 2. Abrir Formulario de Fotos (Paso Obligatorio)
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubirComprobantesScreen(ordenId: ordenId, ordenLocal: orden),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}