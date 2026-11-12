import 'dart:convert';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:signature/signature.dart';

// 👇 IMPORTA TU PROVIDER DE DIO
import 'package:sistema_ocs/data/network/dio_client.dart';
import 'package:sistema_ocs/features/almacen/prestamos/widgets/evidence_photo_field.dart';
import 'package:sistema_ocs/features/almacen/prestamos/providers/prestamo_provider.dart';
import 'package:sistema_ocs/features/transportes/data/save_download.dart';

class ConfirmarSolicitudPrestamoScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;

  const ConfirmarSolicitudPrestamoScreen({
    super.key,
    required this.data,
  });

  @override
  ConsumerState<ConfirmarSolicitudPrestamoScreen> createState() =>
      _ConfirmarSolicitudPrestamoScreenState();
}

class _ConfirmarSolicitudPrestamoScreenState
    extends ConsumerState<ConfirmarSolicitudPrestamoScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  String? firmaBase64;
  bool isLoading = false;
  final Map<int, String> _fotosInicio = {};

  List<Map<String, dynamic>> get _items =>
      (widget.data['items'] as List? ?? [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

  String formatDate(String date) {
    final d = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy HH:mm').format(d);
  }

  // ✅ CONVERTIR FIRMA A BASE64
  Future<void> _guardarFirma() async {
    if (_controller.isEmpty) return;

    final ui.Image? image = await _controller.toImage();
    if (image == null) return;

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    if (!mounted) return;

    final bytes = byteData.buffer.asUint8List();

    setState(() {
      firmaBase64 = base64Encode(bytes);
    });
  }

  // ✅ POST FINAL CON DIO + TOKEN
  Future<void> _registrarPrestamo() async {
    await _guardarFirma();
    if (!mounted) return;

    if (firmaBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debe firmar antes de confirmar"),
        ),
      );
      return;
    }

    final data = widget.data;
    final items = _items;
    final missingPhoto = items.any((item) =>
        (item['es_activo_alto_valor'] == true ||
            item['requiere_foto_devolucion'] == true) &&
        !_fotosInicio.containsKey((item['articulo_id'] as num).toInt()));
    if (missingPhoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Agrega una foto a cada artículo de alto valor.')),
      );
      return;
    }

    try {
      setState(() => isLoading = true);
      final registered = await ref.read(prestamoServiceProvider).confirmarSolicitud(
        prestamoId: (data['id'] as num).toInt(),
        signatureBase64: firmaBase64!,
        photosByArticle: _fotosInicio,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Préstamo registrado correctamente"),
          backgroundColor: Colors.green,
        ),
      );
      await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Préstamo confirmado'),
            content: const Text('Se descontó el stock y se generó el PDF del préstamo.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cerrar'),
              ),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _abrirPdf((registered['id'] as num).toInt());
                },
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Abrir PDF'),
              ),
            ],
          ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No se pudo confirmar el préstamo: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El préstamo se confirmó, pero no se pudo abrir el PDF: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final items = _items;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Detalle de Préstamo',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey[800],
        shape: const Border(
          bottom: BorderSide(color: Colors.blueGrey, width: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tarjeta de trabajador
            _buildCard(
              icon: LucideIcons.user,
              title: 'Trabajador',
              children: [
                _infoRow(LucideIcons.hash, 'Código', data['codigo_unico']),
                _infoRow(LucideIcons.user, 'Nombre', data['nombres_completos']),
                _infoRow(LucideIcons.contact, 'DNI', data['dni']),
                _infoRow(LucideIcons.briefcase, 'Cargo', data['cargo']),
                _infoRow(LucideIcons.package, 'Tipo', data['tipo_prestamo'] ?? 'interno'),
              ],
            ),

            const SizedBox(height: 20),

            // Tarjeta de fechas
            _buildCard(
              icon: LucideIcons.calendar,
              title: 'Fechas del préstamo',
              children: [
                _infoRow(LucideIcons.calendarPlus, 'Préstamo',
                    data['fecha_prestamo'] == null
                        ? 'Se registra al confirmar entrega'
                        : formatDate(data['fecha_prestamo'].toString())),
                _infoRow(LucideIcons.calendarClock, 'Devolución',
                    formatDate(data['fecha_devolucion_prevista'])),
              ],
            ),

            const SizedBox(height: 20),

            // Tarjeta de artículos (ahora en tabla)
            _buildCard(
              icon: LucideIcons.package,
              title: 'Artículos solicitados',
              children: [
                const SizedBox(height: 8),
                _buildItemsTable(items),
                ...items
                    .where((item) => item['es_activo_alto_valor'] == true ||
                        item['requiere_foto_devolucion'] == true)
                    .map((item) {
                  final id = (item['articulo_id'] as num).toInt();
                  return EvidencePhotoField(
                    key: ValueKey('loan-photo-$id'),
                    title:
                        'Foto obligatoria · ${item['articulo_nombre'] ?? 'Artículo $id'}',
                    onChanged: (value) {
                      if (value == null) {
                        _fotosInicio.remove(id);
                      } else {
                        _fotosInicio[id] = value;
                      }
                    },
                  );
                }),
              ],
            ),

            const SizedBox(height: 20),

            // Sección de firma
            _buildSectionHeader(
              icon: LucideIcons.penTool,
              title: 'Firma del trabajador',
            ),
            const SizedBox(height: 12),
            Container(
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey.shade300, width: 1.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _controller.clear(),
                  icon: const Icon(LucideIcons.eraser, size: 18),
                  label: const Text('Limpiar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blueGrey[700],
                    side: BorderSide(color: Colors.blueGrey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _guardarFirma,
                  icon: const Icon(LucideIcons.save, size: 18),
                  label: const Text('Guardar firma'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Botón de confirmación
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _registrarPrestamo,
                icon: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(LucideIcons.checkCircle),
                label: Text(
                  isLoading ? 'Registrando...' : 'CONFIRMAR PRÉSTAMO',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 UI HELPERS MEJORADOS

  Widget _buildCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[800],
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[800],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey[800], size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey[600]),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(List items) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(
              color: Colors.blueGrey.shade200,
              width: 1,
            ),
          ),
          columnWidths: const {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(2),
          },
          children: [
            // Cabecera
            TableRow(
              decoration: BoxDecoration(
                color: Colors.blueGrey[700],
              ),
              children: [
                _buildTableCell('Artículo', isHeader: true),
                _buildTableCell('Cantidad', isHeader: true),
              ],
            ),
            // Filas
            ...items.map((item) {
              return TableRow(
                children: [
                  _buildTableCell(item['articulo_nombre']),
                  _buildTableCell('${item['cantidad']}'),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.white : Colors.black87,
          fontSize: isHeader ? 14 : 13,
        ),
        textAlign: isHeader ? TextAlign.center : TextAlign.left,
      ),
    );
  }
}
