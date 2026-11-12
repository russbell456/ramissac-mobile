import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';
import 'package:sistema_ocs/features/almacen/prestamos/screens/devolucion_qr_screen.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';
import 'package:sistema_ocs/data/network/backend_url.dart';
import 'package:sistema_ocs/features/transportes/data/save_download.dart';

class DetallePrestamoScreen extends ConsumerWidget {
  final Map<String, dynamic> prestamo;

  const DetallePrestamoScreen({super.key, required this.prestamo});

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detalles = prestamo['detalles'] as List;
    final dio = ref.watch(dioProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Detalle de Préstamo',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primary, // Azul oscuro
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Tarjeta de cabecera con código y datos del trabajador
            _buildHeaderCard(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _descargarPdf(context, dio),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Abrir PDF actualizado del préstamo'),
              ),
            ),
            const SizedBox(height: 16),
            // Tarjeta de fechas
            _buildDatesCard(),
            const SizedBox(height: 16),
            // Tarjeta de artículos
            _buildItemsCard(detalles, dio),
            const SizedBox(height: 16),
            _buildHistoryCard(dio),
            if (prestamo['estado'] == 'abierto' &&
                detalles.any((item) =>
                    item is Map &&
                    item['requiere_devolucion'] == true &&
                    ((item['cantidad_pendiente'] as num?)?.toInt() ?? 0) >
                        0)) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    final payload = {
                      'operacion': 'devolucion',
                      'prestamo_id': prestamo['id'],
                      'trabajador_id': prestamo['trabajador_id'],
                      'codigo_unico': prestamo['codigo_unico'],
                    };
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DevolucionQrScreen(payload: payload),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assignment_return_outlined),
                  label: const Text('Registrar devolución parcial'),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Tarjeta de firma
            _buildSignatureCard(dio),
          ],
        ),
      ),
    );
  }

  Future<void> _descargarPdf(BuildContext context, dynamic dio) async {
    try {
      final id = (prestamo['id'] as num).toInt();
      final response = await dio.get<List<int>>(
        '/almacen/prestamo/$id/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null) throw StateError('El servidor no devolvió el PDF.');
      await openDownloadedFile('prestamo_$id.pdf', bytes);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No se pudo abrir el PDF: $error'),
      ));
    }
  }

  Widget _buildHistoryCard(dynamic dio) {
    final devoluciones = (prestamo['devoluciones'] as List? ?? [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trazabilidad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Registró/entregó: ${prestamo['almacenero_nombre'] ?? 'Pendiente de entrega'}'),
            if (devoluciones.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Aún no hay devoluciones registradas.'),
              ),
            ...devoluciones.map((devolucion) {
              final detallesDevolucion = (devolucion['detalles'] as List? ?? [])
                  .whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item));
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Text('Devolución ${devolucion['codigo_unico'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Fecha: ${_formatDate((devolucion['fecha_devolucion'] ?? '').toString())}'),
                    Text('Recibió: ${devolucion['almacenero_nombre'] ?? 'No registrado'}'),
                    if ((devolucion['firma_url'] ?? '').toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Image.network(
                          buildBackendUrl(dio, devolucion['firma_url'].toString()),
                          height: 70,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Text('No se pudo cargar la firma de devolución.'),
                        ),
                      ),
                    ...detallesDevolucion.map((detalle) {
                      final photo = detalle['foto_estado_fin_url']?.toString();
                      final detailId = (detalle['prestamo_detalle_id'] as num?)?.toInt();
                      var article = 'Artículo';
                      for (final rawDetail in (prestamo['detalles'] as List? ?? [])) {
                        if (rawDetail is Map &&
                            (rawDetail['id'] as num?)?.toInt() == detailId) {
                          article = rawDetail['articulo_nombre']?.toString() ?? article;
                          break;
                        }
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$article · devuelto: ${detalle['cantidad_devuelta'] ?? 0}'),
                          if (photo != null && photo.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Image.network(
                                buildBackendUrl(dio, photo),
                                height: 150,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Text('No se pudo cargar la foto de devolución.'),
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.fileText,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Código de préstamo',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      prestamo['codigo_unico'] ?? 'Sin código',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: prestamo['estado'] == 'abierto'
                      ? Colors.orange[50]
                      : Colors.green[50],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: prestamo['estado'] == 'abierto'
                        ? Colors.orange.shade200
                        : Colors.green.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      prestamo['estado'] == 'abierto'
                          ? LucideIcons.clock
                          : LucideIcons.checkCircle,
                      size: 14,
                      color: prestamo['estado'] == 'abierto'
                          ? Colors.orange[800]
                          : Colors.green[800],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      prestamo['estado']?.toUpperCase() ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: prestamo['estado'] == 'abierto'
                            ? Colors.orange[800]
                            : Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          _buildInfoRow(LucideIcons.user, 'Trabajador',
              prestamo['nombres_completos'] ?? ''),
          _buildInfoRow(LucideIcons.wallet, 'DNI', prestamo['dni'] ?? ''),
          _buildInfoRow(
              LucideIcons.briefcase, 'Cargo', prestamo['cargo'] ?? ''),
          _buildInfoRow(LucideIcons.userCog, 'Entregó', prestamo['almacenero_nombre'] ?? 'Pendiente'),
          _buildInfoRow(LucideIcons.package, 'Tipo', prestamo['tipo_prestamo'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildDatesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.calendar,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Fechas del préstamo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          _buildDateRow(
              LucideIcons.calendarPlus, 'Préstamo', prestamo['fecha_prestamo']),
          const SizedBox(height: 8),
          _buildDateRow(LucideIcons.calendarClock, 'Devolución prevista',
              prestamo['fecha_devolucion_prevista']),
        ],
      ),
    );
  }

  Widget _buildItemsCard(List detalles, dynamic dio) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.package,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Artículos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          ...detalles.map((item) => _buildItemRow(item, dio)).toList(),
        ],
      ),
    );
  }

  Widget _buildSignatureCard(dynamic dio) {
    final signature = prestamo['firma_url'] ?? prestamo['firma_base64'];
    final signatureText = signature?.toString();
    final isData = signatureText?.startsWith('data:') == true;
    final isFilePath = signatureText != null &&
        !isData &&
        !RegExp(r'^[A-Za-z0-9+/]+=*$').hasMatch(signatureText);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.penTool,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Firma del trabajador',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          if (signatureText != null && signatureText.isNotEmpty)
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isFilePath
                    ? Image.network(
                        buildBackendUrl(dio, signatureText),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text('No se pudo cargar la firma'),
                        ),
                      )
                    : Image.memory(
                        base64Decode(isData
                            ? signatureText.split(',').last
                            : signatureText),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text('Firma no disponible'),
                        ),
                      ),
              ),
            )
          else
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Sin firma',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(IconData icon, String label, String dateStr) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                _formatDate(dateStr),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item, dynamic dio) {
    final estaDevuelto = item['esta_devuelto'] ?? false;
    final cantidadPrestada = item['cantidad_prestada'] ?? 0;
    final cantidadDevuelta = item['cantidad_devuelta'] ?? 0;
    final pendiente = cantidadPrestada - cantidadDevuelta;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              LucideIcons.box,
              size: 20,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['articulo_nombre'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildQuantityChip(
                        'Prestado: $cantidadPrestada', Colors.blueGrey),
                    const SizedBox(width: 8),
                    _buildQuantityChip(
                        'Devuelto: $cantidadDevuelta', Colors.green),
                  ],
                ),
                if (pendiente > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(LucideIcons.alertTriangle,
                          size: 14, color: Colors.orange[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Pendiente: $pendiente',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                if ((item['foto_estado_inicio_url'] ?? '').toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Image.network(
                      buildBackendUrl(dio, item['foto_estado_inicio_url'].toString()),
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text('No se pudo cargar la foto inicial.'),
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            estaDevuelto ? LucideIcons.checkCircle : LucideIcons.clock,
            color: estaDevuelto ? Colors.green[700] : Colors.orange[700],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
