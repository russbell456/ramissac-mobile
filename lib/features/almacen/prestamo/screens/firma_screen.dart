import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class FirmaScreen extends StatefulWidget {
  final Function(String base64) onFirmaConfirmada;

  const FirmaScreen({super.key, required this.onFirmaConfirmada});

  @override
  State<FirmaScreen> createState() => _FirmaScreenState();
}

class _FirmaScreenState extends State<FirmaScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  Future<void> _guardarFirma() async {
  if (_controller.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Debe firmar primero")),
    );
    return;
  }

  final ui.Image? image = await _controller.toImage();

  if (image == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error al generar la firma")),
    );
    return;
  }

  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  if (byteData == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error al convertir firma")),
    );
    return;
  }

  final bytes = byteData.buffer.asUint8List();
  final base64String = base64Encode(bytes);

  widget.onFirmaConfirmada(base64String);

  Navigator.pop(context);
}
  void _limpiarFirma() {
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firma del Trabajador"),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _limpiarFirma,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Signature(
              controller: _controller,
              backgroundColor: Colors.grey[200]!,
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _guardarFirma,
              child: const Text("Guardar Firma"),
            ),
          )
        ],
      ),
    );
  }
}