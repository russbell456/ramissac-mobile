import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';
import 'package:sistema_ocs/features/almacen/prestamos/widgets/evidence_photo_field.dart';
import 'package:sistema_ocs/features/almacen/prestamos/services/prestamo_multipart.dart';
import 'package:sistema_ocs/features/transportes/data/save_download.dart';

class RegistrarDevolucionScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> prestamo;

  const RegistrarDevolucionScreen({super.key, required this.prestamo});

  @override
  ConsumerState<RegistrarDevolucionScreen> createState() =>
      _RegistrarDevolucionScreenState();
}

class _RegistrarDevolucionScreenState
    extends ConsumerState<RegistrarDevolucionScreen> {
  final _signature = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final Map<int, TextEditingController> _quantities = {};
  final Map<int, String> _photos = {};
  bool _saving = false;

  List<Map<String, dynamic>> get _details =>
      (widget.prestamo['detalles'] as List? ?? [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where((item) =>
              item['requiere_devolucion'] == true &&
              ((item['cantidad_pendiente'] as num?)?.toInt() ?? 0) > 0)
          .toList();

  @override
  void initState() {
    super.initState();
    for (final item in _details) {
      final id = (item['id'] as num).toInt();
      _quantities[id] = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    _signature.dispose();
    for (final controller in _quantities.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<String?> _signatureBase64() async {
    if (_signature.isEmpty) return null;
    final image = await _signature.toImage();
    if (image == null) return null;
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data == null
        ? null
        : 'data:image/png;base64,${base64Encode(data.buffer.asUint8List())}';
  }

  Future<void> _submit() async {
    final items = <Map<String, dynamic>>[];
    for (final detail in _details) {
      final id = (detail['id'] as num).toInt();
      final quantity = int.tryParse(_quantities[id]?.text.trim() ?? '') ?? 0;
      if (quantity <= 0) continue;
      if (quantity > ((detail['cantidad_pendiente'] as num?)?.toInt() ?? 0)) {
        _message(
            'La cantidad supera lo pendiente de ${detail['articulo_nombre']}.');
        return;
      }
      final requiresPhoto = detail['requiere_foto_devolucion'] == true;
      if (requiresPhoto && !_photos.containsKey(id)) {
        _message(
            'Agrega la foto de devolución de ${detail['articulo_nombre']}.');
        return;
      }
      items.add({
        'prestamo_detalle_id': id,
        'cantidad': quantity,
      });
    }

    if (items.isEmpty) {
      _message('Indica una cantidad para devolver.');
      return;
    }
    final signature = await _signatureBase64();
    if (signature == null) {
      _message('El trabajador debe firmar antes de confirmar.');
      return;
    }

    final data = widget.prestamo;
    final returnedDetailIds = items
        .map((item) => (item['prestamo_detalle_id'] as num).toInt())
        .toSet();
    final photosForReturn = Map<int, String>.fromEntries(
      _photos.entries.where((entry) => returnedDetailIds.contains(entry.key)),
    );
    final payload = {
      'trabajador_id': data['trabajador_id'],
      'codigo_unico':
          'DEV-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}',
      'dni': data['dni'],
      'nombres_completos': data['nombres_completos'],
      'cargo': data['cargo'],
      'prestamo_id': data['id'],
      'items': items,
    };

    setState(() => _saving = true);
    try {
      final response = await ref.read(dioProvider).post(
            '/almacen/registrar-devolucion-qr',
            data: buildEvidenceFormData(
              data: payload,
              signatureBase64: signature,
              photosById: photosForReturn,
              photoIdField: 'prestamo_detalle_id',
            ),
          );
      if (!mounted) return;
      final totalInformativo = response.data is Map
          ? response.data['importe_informativo_total']?.toString()
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Devolución registrada.'),
            backgroundColor: Colors.green),
      );
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Devolución registrada'),
          content: Text(
            'El PDF del préstamo fue actualizado con esta devolución.' +
                (totalInformativo == null
                    ? ''
                    : '\nImporte informativo de esta devolución: S/ $totalInformativo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cerrar'),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _abrirPdf((widget.prestamo['id'] as num).toInt());
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Abrir PDF'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on DioException catch (error) {
      final detail = error.response?.data is Map
          ? (error.response?.data['detail']?.toString() ??
              'No se pudo registrar la devolución.')
          : 'No se pudo conectar con el servidor.';
      _message(detail);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _abrirPdf(int loanId) async {
    try {
      final response = await ref.read(dioProvider).get<List<int>>(
        '/almacen/prestamo/$loanId/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null) throw StateError('El PDF no se pudo descargar.');
      await openDownloadedFile('prestamo_$loanId.pdf', bytes);
    } catch (error) {
      if (!mounted) return;
      _message('La devolución quedó registrada, pero no se pudo abrir el PDF: $error');
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar devolución')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Préstamo ${widget.prestamo['codigo_unico'] ?? ''}',
              style: Theme.of(context).textTheme.titleLarge),
          Text('Trabajador: ${widget.prestamo['nombres_completos'] ?? '-'}'),
          Text('DNI: ${widget.prestamo['dni'] ?? '-'} · ${widget.prestamo['cargo'] ?? ''}'),
          Text('Tipo: ${(widget.prestamo['tipo_prestamo'] ?? '').toString().toUpperCase()}'),
          const SizedBox(height: 12),
          ..._details.map((detail) {
            final id = (detail['id'] as num).toInt();
            final pending = (detail['cantidad_pendiente'] as num).toInt();
            final highValue = detail['requiere_foto_devolucion'] == true;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${detail['articulo_nombre']} · pendiente $pending'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _quantities[id],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Cantidad a devolver (0–$pending)'),
                      ),
                      if (highValue)
                        EvidencePhotoField(
                          key: ValueKey('return-photo-$id'),
                          title: 'Foto obligatoria del estado devuelto',
                          onChanged: (value) {
                            if (value == null) {
                              _photos.remove(id);
                            } else {
                              _photos[id] = value;
                            }
                          },
                        ),
                    ]),
              ),
            );
          }),
          const SizedBox(height: 16),
          const Text('Firma del trabajador',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 180,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Signature(
                  controller: _signature, backgroundColor: Colors.white),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _signature.clear,
              icon: const Icon(Icons.cleaning_services_outlined),
              label: const Text('Limpiar firma'),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.assignment_turned_in_outlined),
            label:
                Text(_saving ? 'Registrando…' : 'Confirmar devolución parcial'),
          ),
        ],
      ),
    );
  }
}
