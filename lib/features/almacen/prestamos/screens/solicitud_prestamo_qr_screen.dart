import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:sistema_ocs/features/login/auth_notifier.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';
import 'package:sistema_ocs/features/almacen/prestamos/providers/prestamo_provider.dart';
import 'package:sistema_ocs/features/almacen/prestamos/providers/carrito_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SolicitudPrestamoQrScreen extends ConsumerStatefulWidget {
  final List<dynamic> carrito;
  final DateTime fechaDevolucion;
  final Map<String, dynamic> solicitudData;

  const SolicitudPrestamoQrScreen({
    super.key,
    required this.carrito,
    required this.fechaDevolucion,
    this.solicitudData = const {},
  });

  @override
  ConsumerState<SolicitudPrestamoQrScreen> createState() =>
      _SolicitudPrestamoQrScreenState();
}

class _SolicitudPrestamoQrScreenState
    extends ConsumerState<SolicitudPrestamoQrScreen> {
  Map<String, dynamic>? jsonPrestamo;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _armarJson();
  }

  Future<void> _armarJson() async {
    final authService = ref.read(authServiceProvider);
    final user = await authService.getCurrentUser();

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final request = <String, dynamic>{
        'fecha_devolucion_prevista': widget.fechaDevolucion.toIso8601String(),
        'tipo_prestamo': widget.solicitudData['tipo_prestamo'] ?? 'interno',
        'items': widget.carrito.map((item) => {
          'articulo_id': item.articulo.id,
          'cantidad': item.cantidad,
        }).toList(),
        ...widget.solicitudData,
      };
      request.remove('obra_nombre');
      final created = await ref.read(prestamoServiceProvider).crearSolicitud(request);
      if (!mounted) return;
      ref.read(carritoProvider.notifier).clear();
      setState(() {
        jsonPrestamo = {
          ...created,
          'trabajador_id': user.id,
          'dni': user.dni ?? '',
          'nombres_completos': user.nombresCompletos,
          'cargo': user.cargo ?? '',
          'fecha_devolucion_prevista': widget.fechaDevolucion.toIso8601String(),
          'items': widget.carrito.map((item) => {
            'articulo_nombre': item.articulo.nombre,
            'articulo_id': item.articulo.id,
            'cantidad': item.cantidad,
            'es_activo_alto_valor': item.articulo.esActivoAltoValor,
          }).toList(),
          ...widget.solicitudData,
        };
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Resumen de Préstamo',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 14, 105, 158), // Azul oscuro
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 40, 36, 116)),
            )
          : jsonPrestamo == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.alertCircle,
                          size: 60, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage ?? 'Error al generar el QR',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Tarjeta del QR
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 2,
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.qrCode,
                                  color: const Color.fromARGB(255, 20, 15, 125),
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Código QR de Préstamo',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromARGB(255, 32, 124, 163),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 30, thickness: 1),
                            Text('Solicitud: ${jsonPrestamo!['codigo_unico'] ?? ''}'),
                            Text('Tipo: ${(jsonPrestamo!['tipo_prestamo'] ?? 'interno').toString().toUpperCase()}'),
                            Center(
                              child: QrImageView(
                                data: jsonEncode({
                                  'operacion': 'prestamo',
                                  'prestamo_id': jsonPrestamo!['id'],
                                  'codigo_unico': jsonPrestamo!['codigo_unico'],
                                }),
                                size: 260,
                                backgroundColor: Colors.white,
                                foregroundColor:
                                    const Color.fromARGB(255, 20, 15, 125),
                                padding: const EdgeInsets.all(10),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(30),
                                border:
                                    Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.info,
                                    size: 18,
                                    color: Colors.green[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Muestra este QR al almacenero',
                                    style: TextStyle(
                                      color: Colors.green[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Datos del trabajador', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Nombre: ${jsonPrestamo!['nombres_completos'] ?? ''}'),
                              Text('DNI: ${jsonPrestamo!['dni'] ?? ''}'),
                              Text('Cargo: ${jsonPrestamo!['cargo'] ?? ''}'),
                              Text('Tipo: ${(jsonPrestamo!['tipo_prestamo'] ?? 'interno').toString().toUpperCase()}'),
                              if (jsonPrestamo!['obra_nombre'] != null)
                                Text('Obra: ${jsonPrestamo!['obra_nombre']}'),
                              if (jsonPrestamo!['empresa_nombre'] != null)
                                Text('Empresa externa: ${jsonPrestamo!['empresa_nombre']}'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tarjeta de resumen de artículos
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.package,
                                  color: const Color.fromARGB(255, 20, 15, 125),
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Artículos solicitados',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        const Color.fromARGB(255, 20, 15, 125),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            ...widget.carrito.map((item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.articulo.nombre,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${item.cantidad}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total artículos:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  '${widget.carrito.length}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tarjeta de fecha de devolución
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                LucideIcons.calendarClock,
                                color: const Color.fromARGB(255, 20, 15, 125),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Fecha de devolución',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(widget.fechaDevolucion),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
