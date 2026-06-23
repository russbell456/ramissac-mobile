import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:sistema_ocs/features/almacen/prestamo_manual.dart';
import '../providers/trabajadores_provider.dart';
import '../providers/prestamo_manual_provider.dart';

class SeleccionarTrabajadorScreen extends ConsumerStatefulWidget {
  const SeleccionarTrabajadorScreen({super.key});

  @override
  ConsumerState<SeleccionarTrabajadorScreen> createState() =>
      _SeleccionarTrabajadorScreenState();
}

class _SeleccionarTrabajadorScreenState
    extends ConsumerState<SeleccionarTrabajadorScreen> {
  Map<String, dynamic>? _trabajadorSeleccionado;

  // Lista de imágenes disponibles
  final List<String> imagenes = const [
    'assets/images/persona1.jpg',
    'assets/images/persona2.jpg',
    'assets/images/persona3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final trabajadoresAsync = ref.watch(trabajadoresProvider);
    final tempPrestamo = ref.watch(prestamoTempProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Seleccionar Trabajador',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 20, 15, 125), // Azul oscuro
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
      body: trabajadoresAsync.when(
        data: (trabajadores) {
          if (trabajadores.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.users,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay trabajadores disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trabajadores.length,
                  itemBuilder: (context, index) {
                    final t = trabajadores[index];
                    final nombres = '${t['nombre']} ${t['apellidos']}';
                    final isSelected =
                        _trabajadorSeleccionado != null &&
                        _trabajadorSeleccionado!['id'] == t['id'];

                    // Asignar imagen basada en el índice para que sea consistente
                    final imagenIndex = index % imagenes.length;
                    final imagenPath = imagenes[imagenIndex];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _trabajadorSeleccionado = null; // Deseleccionar
                          } else {
                            _trabajadorSeleccionado = t; // Seleccionar solo uno
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                          border: isSelected
                              ? Border.all(color: Colors.green.shade600, width: 2.5)
                              : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Avatar con imagen (en lugar de iniciales)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  imagenPath,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback en caso de error al cargar la imagen
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color.fromARGB(255, 98, 174, 218),
                                            Color.fromRGBO(228, 228, 231, 1),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        child: Text(
                                          (t['nombre']?.isNotEmpty == true ? t['nombre'][0] : '') +
                                              (t['apellidos']?.isNotEmpty == true ? t['apellidos'][0] : ''),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Información del trabajador
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nombres,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromARGB(255, 20, 15, 125),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(LucideIcons.user, 'DNI: ${t['dni']}'),
                                    const SizedBox(height: 4),
                                    _buildInfoRow(LucideIcons.briefcase, 'Cargo: ${t['cargo']}'),
                                    const SizedBox(height: 4),
                                    _buildInfoRow(LucideIcons.mail, 'Email: ${t['email']}'),
                                  ],
                                ),
                              ),
                              // Indicador de selección
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    LucideIcons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                )
                              else
                                Icon(
                                  LucideIcons.chevronRight,
                                  color: Colors.grey[400],
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_trabajadorSeleccionado != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // JSON parcial con nombres de artículos
                      final jsonParcial = {
                        'trabajador_id': _trabajadorSeleccionado!['id'],
                        'dni': _trabajadorSeleccionado!['dni'] ?? '',
                        'nombres_completos':
                            '${_trabajadorSeleccionado!['nombre']} ${_trabajadorSeleccionado!['apellidos']}',
                        'cargo': _trabajadorSeleccionado!['cargo'] ?? '',
                        'fecha_prestamo': DateTime.now().toIso8601String(),
                        'fecha_devolucion_prevista':
                            tempPrestamo?['fecha_devolucion_prevista'] ??
                                DateTime.now()
                                    .add(const Duration(days: 30))
                                    .toIso8601String(),
                        'items': (tempPrestamo?['items'] ?? [])
                            .map((item) => {
                                  'articulo_id': item['articulo_id'],
                                  'articulo_nombre': item['articulo_nombre'],
                                  'cantidad': item['cantidad'],
                                })
                            .toList(),
                      };

                      // Navegamos a la pantalla de firma pasando el JSON parcial
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PrestamoFirmaScreen(
                            prestamoData: jsonParcial,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.arrowRightCircle, size: 24),
                    label: const Text(
                      'Continuar a Firma',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color.fromARGB(255, 20, 15, 125)),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.alertCircle, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error al cargar trabajadores',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}