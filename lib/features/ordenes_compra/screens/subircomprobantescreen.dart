import 'package:flutter/material.dart';
import 'package:sistema_ocs/features/ordenes_compra/models/orden_compra_request.dart';

class SubirComprobantesScreen extends StatefulWidget {
  final int ordenId;
  final OrdenCompraRequest ordenLocal;

  const SubirComprobantesScreen({
    super.key,
    required this.ordenId,
    required this.ordenLocal,
  });

  @override
  State<SubirComprobantesScreen> createState() =>
      _SubirComprobantesScreenState();
}

class _SubirComprobantesScreenState extends State<SubirComprobantesScreen> {

  Future<void> _subirArchivo(String tipo) async {
    // PASO SIGUIENTE:
    // 1. FilePicker / ImagePicker
    // 2. Llamar servicio:
    //
    // await service.subirComprobante(
    //   ordenId: widget.ordenId,
    //   file: archivo,
    //   tipoDocumento: tipo,
    //   numeroComprobante: "F001-123",
    //   esFactura: true,
    //   fecha: "2026-01-20"
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subir comprobantes OC #${widget.ordenId}"),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Selecciona los comprobantes requeridos para finalizar la Orden de Compra",
            ),
          ),

          ListTile(
            title: const Text("Comprobante de Mercadería"),
            trailing: const Icon(Icons.camera_alt),
            onTap: () => _subirArchivo("MERCADERIA_COMPROBANTE"),
          ),

          if (widget.ordenLocal.tipoCompra == "ENVIO")
            ListTile(
              title: const Text("Comprobante de Envío"),
              trailing: const Icon(Icons.camera_alt),
              onTap: () => _subirArchivo("ENVIO_COMPROBANTE"),
            ),

          if (widget.ordenLocal.tipoCompra == "ENVIO")
            ListTile(
              title: const Text("Guía de Remisión"),
              trailing: const Icon(Icons.camera_alt),
              onTap: () => _subirArchivo("GUIA_REMISION"),
            ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Aquí luego:
                  // ref.read(ocProvider.notifier).marcarEnviada(...)
                  Navigator.pop(context);
                },
                child: const Text("FINALIZAR"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
