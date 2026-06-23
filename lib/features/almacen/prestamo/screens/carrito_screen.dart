import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sistema_ocs/features/almacen/prestamo/providers/carrito_provider.dart';
import 'package:sistema_ocs/features/almacen/prestamo/providers/prestamo_manual_provider.dart';
import 'package:sistema_ocs/features/almacen/prestamo/screens/prestamo_preview_screen.dart';
import 'package:sistema_ocs/features/almacen/prestamo/screens/seleccion_trabajador_screen.dart'; // Import del screen

class CarritoScreen extends ConsumerStatefulWidget {
  const CarritoScreen({super.key});

  @override
  ConsumerState<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends ConsumerState<CarritoScreen> {
  DateTime? fechaDevolucion;
  String? userRole; // 👈 Nuevo: guardamos el role del usuario

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    // Leer role del secure storage
    const storage = FlutterSecureStorage();
    final role = await storage.read(key: 'user_role');
    setState(() {
      userRole = role?.toLowerCase(); // 'almacenero', 'trabajador', etc.
    });
  }

  Future<void> seleccionarFecha(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: "Selecciona fecha de devolución",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 22, 12, 120),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        fechaDevolucion = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final carrito = ref.watch(carritoProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Carrito de Préstamo',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 20, 15, 125),
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
      body: Column(
        children: [
          // 📅 SELECTOR DE FECHA MEJORADO
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 37, 91, 207).withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.calendar,
                    color: const Color.fromARGB(255, 2, 10, 13),
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
                          color: Color.fromARGB(255, 12, 13, 14),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fechaDevolucion == null
                            ? 'No seleccionada'
                            : DateFormat('dd/MM/yyyy').format(fechaDevolucion!),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: fechaDevolucion == null
                              ? Colors.grey[600]
                              : Colors.blueGrey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => seleccionarFecha(context),
                  icon: const Icon(LucideIcons.calendarPlus, size: 18),
                  label: const Text('Elegir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 15, 105, 185),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // NUEVO BOTÓN SOLO PARA ALMACENERO
          // Dentro de _CarritoScreenState, reemplaza el onPressed del botón SELECCIONAR TRABAJADOR:

            if (userRole == 'almacenero')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: fechaDevolucion == null || carrito.isEmpty
                    ? null // 🚫 Botón deshabilitado si no hay fecha o carrito vacío
                    : () {
                        // 📝 Armamos JSON temporal
                        final carritoMap = carrito.map((item) => {
                              'articulo_id': item.articulo.id,
                              'articulo_nombre': item.articulo.nombre,
                              'cantidad': item.cantidad,
                            }).toList();

                        final tempJson = {
                          'fecha_devolucion_prevista': fechaDevolucion!.toIso8601String(),
                          'items': carritoMap,
                        };

                        // Guardamos temporal en Riverpod
                        ref.read(prestamoTempProvider.notifier).state = tempJson;

                        // Navegamos a selección de trabajador
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SeleccionarTrabajadorScreen(),
                          ),
                        );
                      },
                icon: const Icon(LucideIcons.users, size: 20),
                label: const Text(
                  'SELECCIONAR TRABAJADOR',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: fechaDevolucion == null || carrito.isEmpty
                      ? Colors.grey // Gris si no se puede usar
                      : const Color.fromARGB(255, 15, 105, 185),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

          // 📦 LISTA DE ARTÍCULOS
          Expanded(
            child: carrito.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.shoppingCart,
                          size: 80,
                          color: const Color.fromARGB(255, 58, 161, 213),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'El carrito está vacío',
                          style: TextStyle(
                            fontSize: 18,
                            color: const Color.fromARGB(255, 34, 105, 137),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: carrito.length,
                    itemBuilder: (context, index) {
                      final item = carrito[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 10, 5, 104).withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  LucideIcons.package,
                                  color: Colors.blueGrey[800],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.articulo.nombre,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Código: ${item.articulo.codigoExcel}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Controles de cantidad
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blueGrey.shade200),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        LucideIcons.minus,
                                        size: 18,
                                        color: Colors.blueGrey[700],
                                      ),
                                      onPressed: () {
                                        ref
                                            .read(carritoProvider.notifier)
                                            .disminuirCantidad(index);
                                      },
                                      constraints: const BoxConstraints(
                                        minWidth: 36,
                                        minHeight: 36,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '${item.cantidad}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        LucideIcons.plus,
                                        size: 18,
                                        color: Colors.green[700],
                                      ),
                                      onPressed: () {
                                        ref
                                            .read(carritoProvider.notifier)
                                            .aumentarCantidad(index);
                                      },
                                      constraints: const BoxConstraints(
                                        minWidth: 36,
                                        minHeight: 36,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  LucideIcons.trash2,
                                  color: Colors.red[400],
                                  size: 22,
                                ),
                                onPressed: () {
                                  ref.read(carritoProvider.notifier).eliminar(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: carrito.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fechaDevolucion == null
                        ? Colors.grey[400]
                        : Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: fechaDevolucion == null ? 0 : 2,
                  ),
                  onPressed: fechaDevolucion == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PrestamoPreviewScreen(
                                carrito: carrito,
                                fechaDevolucion: fechaDevolucion!,
                              ),
                            ),
                          );
                        },
                  icon: Icon(
                    fechaDevolucion == null
                        ? LucideIcons.clock
                        : LucideIcons.checkCircle,
                    size: 20,
                  ),
                  label: Text(
                    fechaDevolucion == null
                        ? 'SELECCIONA FECHA'
                        : 'GENERAR PRÉSTAMO',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}