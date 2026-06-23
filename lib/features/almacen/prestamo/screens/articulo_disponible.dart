import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:sistema_ocs/features/almacen/prestamo/providers/articulo_provider.dart';
import 'package:sistema_ocs/features/almacen/prestamo/providers/carrito_provider.dart';
import 'package:sistema_ocs/features/almacen/prestamo/screens/carrito_screen.dart';

class ArticulosDisponiblesScreen extends ConsumerStatefulWidget {
  const ArticulosDisponiblesScreen({super.key});

  @override
  ConsumerState<ArticulosDisponiblesScreen> createState() =>
      _ArticulosDisponiblesScreenState();
}

class _ArticulosDisponiblesScreenState
    extends ConsumerState<ArticulosDisponiblesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articulosAsync = ref.watch(articulosProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Equipos Disponibles',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 22, 12, 120), // Azul claro
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 3, 31, 78).withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white24),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o código...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(LucideIcons.search, color: Colors.white70),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ),
      body: articulosAsync.when(
        data: (articulos) {
          final filteredArticulos = articulos.where((art) {
            final nombre = art.nombre.toLowerCase();
            final codigo = art.codigoExcel.toLowerCase();
            return nombre.contains(_searchQuery) ||
                codigo.contains(_searchQuery);
          }).toList();

          if (filteredArticulos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.packageX, size: 80, color: Colors.blue[200]),
                  const SizedBox(height: 16),
                  Text(
                    "No hay resultados",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredArticulos.length,
            itemBuilder: (context, index) {
              final articulo = filteredArticulos[index];

              return GestureDetector(
                onTap: () => _mostrarDialogoCantidad(articulo),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.package,
                            color: Colors.blue[800],
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                articulo.nombre,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Código: ${articulo.codigoExcel}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: articulo.stockActual > 0
                                ? Colors.green[50]
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: articulo.stockActual > 0
                                  ? Colors.green.shade200
                                  : Colors.red.shade200,
                            ),
                          ),
                          child: Text(
                            'Stock: ${articulo.stockActual}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: articulo.stockActual > 0
                                  ? Colors.green[800]
                                  : Colors.red[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.alertCircle, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error: $err',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, _) {
          final carrito = ref.watch(carritoProvider);

          if (carrito.isEmpty) return const SizedBox();

          return FloatingActionButton.extended(
            backgroundColor: Colors.green[300], // Verde claro
            icon: const Icon(LucideIcons.shoppingCart, color: Colors.white),
            label: Text(
              '${carrito.length}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CarritoScreen(),
                ),
              );
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          );
        },
      ),
    );
  }

  // Diálogo mejorado para seleccionar cantidad
  void _mostrarDialogoCantidad(articulo) {
    int cantidad = 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(LucideIcons.package, color: Colors.blue[800]),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  articulo.nombre,
                  style: const TextStyle(fontSize: 18),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Selecciona la cantidad:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _botonCircular(
                        icon: LucideIcons.minus,
                        onPressed: () {
                          if (cantidad > 1) {
                            setState(() => cantidad--);
                          }
                        },
                        color: Colors.blue[300]!,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$cantidad',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _botonCircular(
                        icon: LucideIcons.plus,
                        onPressed: () {
                          setState(() => cantidad++);
                        },
                        color: Colors.green[300]!,
                      ),
                    ],
                  ),
                  if (articulo.stockActual < cantidad)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Stock disponible: ${articulo.stockActual}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[800],
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (cantidad > articulo.stockActual) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Stock insuficiente (máx: ${articulo.stockActual})'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                ref.read(carritoProvider.notifier).agregar(articulo, cantidad);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[300],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Agregar'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }

  Widget _botonCircular({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}