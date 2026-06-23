import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:signature/signature.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';

class PrestamoFirmaScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> prestamoData;

  const PrestamoFirmaScreen({super.key, required this.prestamoData});

  @override
  ConsumerState<PrestamoFirmaScreen> createState() =>
      _PrestamoFirmaScreenState();
}

class _PrestamoFirmaScreenState extends ConsumerState<PrestamoFirmaScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  String? firmaBase64;
  bool isLoading = false;

  String formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy HH:mm').format(d);
    } catch (_) {
      return '-';
    }
  }

  Future<void> _guardarFirma() async {
    if (_controller.isEmpty) return;

    final ui.Image? image = await _controller.toImage();
    if (image == null) return;

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final bytes = byteData.buffer.asUint8List();
    setState(() {
      firmaBase64 = base64Encode(bytes);
    });
  }

  Future<void> _registrarPrestamo() async {
    await _guardarFirma();

    if (firmaBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debe firmar antes de confirmar"),
        ),
      );
      return;
    }

    final data = widget.prestamoData;
    final items = (data['items'] as List?) ?? [];

    // Generar código único si no existe
    final String codigoUnico = data['codigo_unico'] ??
        'PRE-${DateTime.now().toIso8601String().substring(0, 10).replaceAll('-', '')}-${Random().nextInt(999).toString().padLeft(3, '0')}';

    final jsonPrestamo = {
      'trabajador_id': data['trabajador_id'] ?? 0,
      'codigo_unico': codigoUnico,
      'dni': data['dni'] ?? '',
      'nombres_completos': data['nombres_completos'] ?? '',
      'cargo': data['cargo'] ?? '',
      'fecha_prestamo': DateTime.now().toIso8601String(),
      'fecha_devolucion_prevista': data['fecha_devolucion_prevista'] ??
          DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'items': items
          .map((item) => {
                'articulo_id': item['articulo_id'] ?? 0,
                'articulo_nombre': item['articulo_nombre'] ?? '',
                'cantidad': item['cantidad'] ?? 0,
              })
          .toList(),
      'firma_base64': firmaBase64 ?? '',
    };

    try {
      setState(() => isLoading = true);
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/almacen/registrar-prestamo-qr',
        data: jsonPrestamo,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Préstamo registrado correctamente"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } on DioException catch (e) {
      print("❌ Error backend: ${e.response?.data}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Error: ${e.response?.statusCode ?? 'Sin conexión'}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.prestamoData;
    final items = (data['items'] as List?) ?? [];

    // Código único garantizado
    final String codigoUnico = data['codigo_unico'] ??
        'PRE-${DateTime.now().toIso8601String().substring(0, 10).replaceAll('-', '')}-${Random().nextInt(999).toString().padLeft(3, '0')}';

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
            _buildCard(
              icon: LucideIcons.user,
              title: 'Trabajador',
              children: [
                _infoRow(LucideIcons.hash, 'Código', codigoUnico),
                _infoRow(LucideIcons.user, 'Nombre', data['nombres_completos'] ?? '-'),
                _infoRow(LucideIcons.contact, 'DNI', data['dni'] ?? '-'),
                _infoRow(LucideIcons.briefcase, 'Cargo', data['cargo'] ?? '-'),
              ],
            ),
            const SizedBox(height: 20),
            _buildCard(
              icon: LucideIcons.calendar,
              title: 'Fechas del préstamo',
              children: [
                _infoRow(LucideIcons.calendarPlus, 'Préstamo',
                    formatDate(data['fecha_prestamo'] ?? DateTime.now().toIso8601String())),
                _infoRow(LucideIcons.calendarClock, 'Devolución',
                    formatDate(data['fecha_devolucion_prevista'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String())),
              ],
            ),
            const SizedBox(height: 20),
            _buildCard(
              icon: LucideIcons.package,
              title: 'Artículos solicitados',
              children: [
                const SizedBox(height: 8),
                _buildItemsTable(items),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionHeader(
                icon: LucideIcons.penTool, title: 'Firma del trabajador'),
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
            TableRow(
              decoration: BoxDecoration(
                color: Colors.blueGrey[700],
              ),
              children: [
                _buildTableCell('Artículo', isHeader: true),
                _buildTableCell('Cantidad', isHeader: true),
              ],
            ),
            ...items.map((item) {
              return TableRow(
                children: [
                  _buildTableCell(item['articulo_nombre'] ?? ''),
                  _buildTableCell('${item['cantidad'] ?? 0}'),
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