import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';

class SignatureCaptureScreen extends StatefulWidget {
  const SignatureCaptureScreen({super.key});

  @override
  State<SignatureCaptureScreen> createState() => _SignatureCaptureScreenState();
}

class _SignatureCaptureScreenState extends State<SignatureCaptureScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, realiza tu firma antes de guardar.')),
      );
      return;
    }

    final image = await _controller.toImage();
    final data = await image?.toByteData(format: ui.ImageByteFormat.png);
    if (!mounted) return;
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo generar la imagen de la firma.')),
      );
      return;
    }
    Navigator.of(context).pop(base64Encode(data.buffer.asUint8List()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar firma')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppTheme.border),
                    borderRadius: AppTheme.borderRadiusMedium,
                  ),
                  child: Signature(
                    controller: _controller,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _controller.clear,
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar'),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _confirm,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar firma'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
