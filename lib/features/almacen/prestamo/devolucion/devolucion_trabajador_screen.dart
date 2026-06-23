import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';
import 'current_user_provider.dart';
import 'prestamo_provider.dart';
import 'detalle_prestamo_screen.dart';

class DevolucionTrabajadorScreen extends ConsumerWidget {
  const DevolucionTrabajadorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Mis Préstamos',
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
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return _buildErrorState(
              icon: LucideIcons.userX,
              message: 'No autenticado',
            );
          }

          final prestamosAsync = ref.watch(prestamosProvider(user.id));

          return prestamosAsync.when(
            data: (prestamos) {
              if (prestamos.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: prestamos.length,
                itemBuilder: (context, index) {
                  final p = prestamos[index];
                  return _buildPrestamoCard(p, context);
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color.fromARGB(255, 20, 15, 125)),
            ),
            error: (e, _) => _buildErrorState(
              icon: LucideIcons.alertCircle,
              message: 'Error: $e',
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color.fromARGB(255, 20, 15, 125)),
        ),
        error: (e, _) => _buildErrorState(
          icon: LucideIcons.alertCircle,
          message: 'Error usuario: $e',
        ),
      ),
    );
  }

  Widget _buildPrestamoCard(Map<String, dynamic> prestamo, BuildContext context) {
    final fecha = prestamo['fecha_prestamo'] ?? '';
    String fechaFormateada = '';
    try {
      if (fecha.isNotEmpty) {
        fechaFormateada = DateFormat('dd/MM/yyyy').format(DateTime.parse(fecha));
      }
    } catch (_) {}

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetallePrestamoScreen(prestamo: prestamo),
          ),
        );
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
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono del préstamo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 20, 15, 125),
                      Color.fromARGB(255, 45, 35, 180),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  LucideIcons.fileText,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prestamo['codigo_unico'] ?? 'Sin código',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 20, 15, 125),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(LucideIcons.calendar, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          fechaFormateada,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(LucideIcons.package, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${prestamo['items']?.length ?? 0} artículos',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Flecha
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.chevronRight,
                  color: const Color.fromARGB(255, 20, 15, 125),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.inbox,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes préstamos',
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

  Widget _buildErrorState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}