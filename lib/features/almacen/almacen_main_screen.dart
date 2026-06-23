// lib/features/almacen/almacen_main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';
import 'package:sistema_ocs/features/almacen/alamacenero/escanear_qr_screen.dart';
import 'package:sistema_ocs/features/almacen/escanear_qr_screen.dart';
import 'package:sistema_ocs/features/almacen/prestamo/devolucion/devolucion_trabajador_screen.dart';
import 'package:sistema_ocs/features/almacen/prestamo/screens/articulo_disponible.dart';
import 'package:sistema_ocs/features/almacen/prestamo/widgets/formulario_cantidades_dialog.dart';

class AlmacenMainScreen extends ConsumerWidget {
  const AlmacenMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String?>(
      future: const FlutterSecureStorage().read(key: 'user_role'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 20, 15, 125),
              ),
            ),
          );
        }

        final role = (snapshot.data ?? 'user').toLowerCase();

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true, // Para que el fondo se vea detrás del AppBar
          appBar: AppBar(
            title: Row(
              children: [
                // Avatar con imagen de almacenero
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/almacenero.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Almacén - Préstamos',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 20, 15, 125).withOpacity(0.9),
                    const Color.fromARGB(255, 45, 35, 180).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/almacen.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.1),
                  BlendMode.dstATop,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tarjeta de bienvenida con vidrio esmerilado
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.warehouse,
                                color: const Color.fromARGB(255, 20, 15, 125),
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Módulo de Almacén',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(255, 20, 15, 125),
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Text(
                              'Rol: ${role.toUpperCase()}',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Opciones según rol
                    Expanded(
                      child: ListView(
                        children: [
                          if (role == 'trabajador' || role == 'admin') ...[
                            _buildCardOption(
                              context,
                              icon: LucideIcons.plusCircle,
                              title: 'Solicitar Préstamo',
                              subtitle: 'Elige equipos y genera QR para el almacenero',
                              color: const Color.fromARGB(255, 20, 15, 125),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ArticulosDisponiblesScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildCardOption(
                              context,
                              icon: LucideIcons.rotateCcw,
                              title: 'Devolver Equipos',
                              subtitle: 'Ve tus pendientes y genera QR de devolución',
                              color: Colors.green[700]!,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DevolucionTrabajadorScreen(),
                                  ),
                                );
                              },
                            ),
                          ],

                          if (role == 'almacenero' || role == 'admin') ...[
                            const SizedBox(height: 16),
                            _buildCardOption(
                              context,
                              icon: LucideIcons.qrCode,
                              title: 'Escanear QR',
                              subtitle: 'Confirma préstamos o devoluciones escaneando',
                              color: Colors.deepPurple,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ScanQRScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                          if (role == 'almacenero' || role == 'admin') ...[

                          const SizedBox(height: 16),
                          _buildCardOption(
                            context,
                            icon: LucideIcons.fileText,
                            title: 'Préstamo Manual',
                            subtitle: 'Genera un préstamo sin QR',
                            color: Colors.teal[700]!,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ArticulosDisponiblesScreen(),
                                ),
                              );
                            },
                          ),
                          ],

                          if (role != 'trabajador' && role != 'almacenero' && role != 'admin')
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Text(
                                  'No tienes permisos para acceder al módulo de Almacén.\nContacta al administrador.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.95),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.arrowRight, color: color, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProximamente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad en desarrollo - Próximamente disponible'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}