import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

String _compressEvidence(Uint8List original) {
  final decoded = img.decodeImage(original);
  if (decoded == null) {
    throw const FormatException('Formato de imagen inválido');
  }

  final resized = decoded.width > 1600 || decoded.height > 1600
      ? img.copyResize(
          decoded,
          width: decoded.width >= decoded.height ? 1600 : null,
          height: decoded.height > decoded.width ? 1600 : null,
          interpolation: img.Interpolation.average,
        )
      : decoded;
  final compressed = img.encodeJpg(resized, quality: 78);
  return 'data:image/jpeg;base64,${base64Encode(compressed)}';
}

/// Permite tomar o elegir una evidencia y la reduce antes de guardarla como
/// Data URL JPEG para enviarla en el JSON esperado por la API.
class EvidencePhotoField extends StatefulWidget {
  final String title;
  final String? initialValue;
  final ValueChanged<String?> onChanged;

  const EvidencePhotoField({
    super.key,
    required this.title,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<EvidencePhotoField> createState() => _EvidencePhotoFieldState();
}

class _EvidencePhotoFieldState extends State<EvidencePhotoField> {
  final _picker = ImagePicker();
  String? _value;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  Future<void> _select(ImageSource source) async {
    try {
      setState(() => _busy = true);
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      await _processPath(file.path);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar la foto: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _selectFromFiles() async {
    try {
      setState(() => _busy = true);
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      final path = result?.files.single.path;
      if (path != null) await _processPath(path);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la foto: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _processPath(String path) async {
    final original = await File(path).readAsBytes();
    final encoded = await compute(_compressEvidence, original);
    if (!mounted) return;
    setState(() => _value = encoded);
    widget.onChanged(encoded);
  }

  Future<void> _showOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _select(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir desde galería'),
              onTap: () {
                Navigator.pop(context);
                _select(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('Elegir desde archivos'),
              onTap: () {
                Navigator.pop(context);
                _selectFromFiles();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final encoded = _value?.split(',').last;
    final preview = encoded == null ? null : base64Decode(encoded);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (preview != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(preview,
                    height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busy ? null : _showOptions,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(preview == null
                      ? Icons.add_a_photo_outlined
                      : Icons.edit),
              label: Text(_busy
                  ? 'Optimizando foto…'
                  : preview == null
                      ? 'Agregar foto'
                      : 'Cambiar foto'),
            ),
            if (preview != null)
              TextButton.icon(
                onPressed: _busy
                    ? null
                    : () {
                        setState(() => _value = null);
                        widget.onChanged(null);
                      },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Quitar foto'),
              ),
          ],
        ),
      ),
    );
  }
}
