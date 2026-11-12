import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sistema_ocs/features/almacen/prestamos/providers/carrito_provider.dart';
import 'package:sistema_ocs/features/almacen/prestamos/providers/prestamo_manual_provider.dart';
import 'package:sistema_ocs/features/almacen/prestamos/screens/solicitud_prestamo_qr_screen.dart';
import 'package:sistema_ocs/features/almacen/prestamos/screens/seleccionar_trabajador_screen.dart'; // Import del screen
import 'package:sistema_ocs/data/network/dio_client.dart';

class CarritoScreen extends ConsumerStatefulWidget {
  const CarritoScreen({super.key});

  @override
  ConsumerState<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends ConsumerState<CarritoScreen> {
  DateTime? fechaDevolucion;
  String? userRole; // 👈 Nuevo: guardamos el role del usuario
  String _tipoPrestamo = 'interno';
  int? _obraId;
  List<Map<String, dynamic>> _obras = [];
  final _ruc = TextEditingController();
  final _empresa = TextEditingController();
  final _dniResponsable = TextEditingController();
  final _responsable = TextEditingController();
  final _telefono = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadObras();
  }

  @override
  void dispose() {
    _ruc.dispose();
    _empresa.dispose();
    _dniResponsable.dispose();
    _responsable.dispose();
    _telefono.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    // Leer role del secure storage
    const storage = FlutterSecureStorage();
    final role = await storage.read(key: 'user_role');
    if (!mounted) return;
    setState(() {
      userRole = role?.toLowerCase(); // 'almacenero', 'trabajador', etc.
    });
  }

  Future<void> _loadObras() async {
    try {
      final response = await ref.read(dioProvider).get('/almacen/obra/');
      if (!mounted || response.data is! List) return;
      setState(() {
        _obras = (response.data as List)
            .whereType<Map>()
            .map((obra) => Map<String, dynamic>.from(obra))
            .toList();
      });
    } catch (_) {}
  }

  Future<void> _crearObra() async {
    final nombre = TextEditingController();
    final descripcion = TextEditingController();
    final cliente = TextEditingController();
    final ubicacion = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Crear obra'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombre, decoration: const InputDecoration(labelText: 'Nombre *')),
              TextField(controller: cliente, decoration: const InputDecoration(labelText: 'Cliente')),
              TextField(controller: ubicacion, decoration: const InputDecoration(labelText: 'Ubicación')),
              TextField(controller: descripcion, decoration: const InputDecoration(labelText: 'Descripción')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Guardar')),
        ],
      ),
    );
    if (accepted != true || nombre.text.trim().isEmpty) return;
    try {
      await ref.read(dioProvider).post('/almacen/obra/', data: {
        'nombre': nombre.text.trim(),
        'descripcion': descripcion.text.trim(),
        'cliente': cliente.text.trim(),
        'ubicacion': ubicacion.text.trim(),
      });
      await _loadObras();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Obra registrada. Selecciónala para continuar.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo crear la obra: $error')),
        );
      }
    } finally {
      nombre.dispose();
      descripcion.dispose();
      cliente.dispose();
      ubicacion.dispose();
    }
  }

  bool get _esAlmacenero => userRole == 'almacenero' || userRole == 'admin';

  Map<String, dynamic>? _datosAsociacion() {
    if (_tipoPrestamo == 'obra' && _obraId == null) return null;
    if (_tipoPrestamo == 'externo') {
      if ([_ruc, _empresa, _dniResponsable, _responsable, _telefono]
          .any((controller) => controller.text.trim().isEmpty)) return null;
      if (_ruc.text.trim().length != 11 || _dniResponsable.text.trim().length != 8) return null;
    }
    String? obraNombre;
    for (final obra in _obras) {
      if (obra['id'] == _obraId) obraNombre = obra['nombre']?.toString();
    }
    return {
      'tipo_prestamo': _tipoPrestamo,
      if (_tipoPrestamo == 'obra') 'obra_id': _obraId,
      if (_tipoPrestamo == 'obra') 'obra_nombre': obraNombre,
      if (_tipoPrestamo == 'externo') ...{
        'empresa_ruc': _ruc.text.trim(),
        'empresa_nombre': _empresa.text.trim(),
        'persona_dni': _dniResponsable.text.trim(),
        'persona_nombres': _responsable.text.trim(),
        'persona_telefono': _telefono.text.trim(),
      },
    };
  }

  void _continuarPrestamo(List<dynamic> carrito) {
    final association = _datosAsociacion();
    if (fechaDevolucion == null || carrito.isEmpty || association == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Completa fecha, artículos y datos de asociación del préstamo.'),
      ));
      return;
    }
    if (_esAlmacenero) {
      ref.read(prestamoTempProvider.notifier).state = {
        'fecha_devolucion_prevista': fechaDevolucion!.toIso8601String(),
        ...association,
        'items': carrito.map((item) => {
          'articulo_id': item.articulo.id,
          'articulo_nombre': item.articulo.nombre,
          'cantidad': item.cantidad,
          'es_activo_alto_valor': item.articulo.esActivoAltoValor,
        }).toList(),
      };
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => const SeleccionarTrabajadorScreen(),
      ));
    } else {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => SolicitudPrestamoQrScreen(
          carrito: carrito,
          fechaDevolucion: fechaDevolucion!,
          solicitudData: association,
        ),
      ));
    }
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
      body: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  color:
                      const Color.fromARGB(255, 37, 91, 207).withOpacity(0.1),
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

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Asociación del préstamo', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _tipoPrestamo,
                    decoration: const InputDecoration(labelText: 'Tipo de préstamo'),
                    items: const [
                      DropdownMenuItem(value: 'interno', child: Text('Interno')),
                      DropdownMenuItem(value: 'obra', child: Text('Obra')),
                      DropdownMenuItem(value: 'externo', child: Text('Externo')),
                    ],
                    onChanged: (value) => setState(() {
                      _tipoPrestamo = value ?? 'interno';
                      _obraId = null;
                    }),
                  ),
                  if (_tipoPrestamo == 'obra') ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: _obraId,
                      decoration: const InputDecoration(labelText: 'Obra'),
                      items: _obras.map((obra) => DropdownMenuItem<int>(
                        value: (obra['id'] as num).toInt(),
                        child: Text(obra['nombre']?.toString() ?? 'Obra'),
                      )).toList(),
                      onChanged: (value) => setState(() => _obraId = value),
                    ),
                    if (_obras.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('No hay obras registradas. El almacenero debe crear una obra primero.'),
                      ),
                    if (_esAlmacenero)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _crearObra,
                          icon: const Icon(Icons.add_business),
                          label: const Text('Crear obra'),
                        ),
                      ),
                  ],
                  if (_tipoPrestamo == 'externo') ...[
                    const SizedBox(height: 8),
                    TextField(controller: _ruc, keyboardType: TextInputType.number, maxLength: 11, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'RUC de empresa')),
                    TextField(controller: _empresa, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Nombre de empresa')),
                    TextField(controller: _dniResponsable, keyboardType: TextInputType.number, maxLength: 8, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'DNI del responsable')),
                    TextField(controller: _responsable, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Nombre del responsable')),
                    TextField(controller: _telefono, keyboardType: TextInputType.phone, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Teléfono del responsable')),
                  ],
                ],
              ),
            ),
          ),

          // Botón para la casuística de préstamo manual del almacenero.
          // Dentro de _CarritoScreenState, reemplaza el onPressed del botón SELECCIONAR TRABAJADOR:

          if (_esAlmacenero && carrito.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: fechaDevolucion == null || carrito.isEmpty || _datosAsociacion() == null
                    ? null
                    : () => _continuarPrestamo(carrito),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

          // 📦 LISTA DE ARTÍCULOS
          carrito.isEmpty
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
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                              color: const Color.fromARGB(255, 10, 5, 104)
                                  .withOpacity(0.1),
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
                                  border: Border.all(
                                      color: Colors.blueGrey.shade200),
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
                                  ref
                                      .read(carritoProvider.notifier)
                                      .eliminar(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ],
      )),
      bottomNavigationBar: carrito.isEmpty || _esAlmacenero
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
                    backgroundColor: fechaDevolucion == null || _datosAsociacion() == null || userRole == null
                        ? Colors.grey[400]
                        : Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: fechaDevolucion == null || _datosAsociacion() == null || userRole == null ? 0 : 2,
                  ),
                  onPressed: fechaDevolucion == null || _datosAsociacion() == null || userRole == null
                      ? null
                      : () => _continuarPrestamo(carrito),
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
