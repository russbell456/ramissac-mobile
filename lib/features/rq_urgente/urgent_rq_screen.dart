import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:sistema_ocs/core/database/db_helper.dart';
import 'package:sistema_ocs/features/rq_urgente/models/rq_local_model.dart';
import 'package:sistema_ocs/features/rq_urgente/services/urgent_rq_service.dart';

class UrgentRQScreen extends StatefulWidget {
  final RQLocal? rqExistente;
  const UrgentRQScreen({super.key, this.rqExistente});

  @override
  State<UrgentRQScreen> createState() => _UrgentRQScreenState();
}

class _UrgentRQScreenState extends State<UrgentRQScreen> {
  final UrgentRQService _service = UrgentRQService();
  final TextEditingController _servicioController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _productosSeleccionados = [];
  List<dynamic> _sugerencias = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.rqExistente != null) {
      _servicioController.text = widget.rqExistente!.servicio;
      _productosSeleccionados = jsonDecode(widget.rqExistente!.productosJson);
    }
  }

  Future<void> _guardarLocalmente() async {
    if (_servicioController.text.isEmpty || _productosSeleccionados.isEmpty) {
      _showSnack("Complete el nombre y agregue productos", isError: true);
      return;
    }

    final nuevoRQ = RQLocal(
      id: widget.rqExistente?.id,
      servicio: _servicioController.text,
      productosJson: jsonEncode(_productosSeleccionados),
      fecha: DateTime.now().toString(),
      enviado: 0,
    );

    if (widget.rqExistente == null) {
      await DBHelper.insertarRQ(nuevoRQ);
    } else {
      await DBHelper.actualizarRQ(nuevoRQ);
    }

    _showSnack("✅ Guardado en borradores");
    Navigator.pop(context, true);
  }

  void _updateCantidad(int index, double delta) {
    setState(() {
      double current = double.tryParse(_productosSeleccionados[index]['cantidad'].toString()) ?? 1.0;
      _productosSeleccionados[index]['cantidad'] = (current + delta).clamp(1.0, 999.0);
    });
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      decoration: BoxDecoration(
        color: AppTheme.textPrimary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                widget.rqExistente == null ? "NUEVO RQ" : "EDITAR RQ",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Complete los detalles del requerimiento urgente",
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildServicioInput() {
    return TextField(
      controller: _servicioController,
      decoration: InputDecoration(
        labelText: "PROYECTO / SERVICIO",
        prefixIcon: const Icon(LucideIcons.briefcase),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildSearchInput() {
    return TextField(
      controller: _searchController,
      onChanged: (val) async {
        if (val.length > 2) {
          setState(() => _isSearching = true);
          final res = await _service.buscarProductos(val);
          setState(() { _sugerencias = res; _isSearching = false; });
        } else {
          setState(() => _sugerencias = []);
        }
      },
      decoration: InputDecoration(
        hintText: "Buscar materiales...",
        prefixIcon: const Icon(LucideIcons.search),
        suffixIcon: _isSearching ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2)) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildSugerencias() {
    return Card(
      elevation: 4,
      child: Column(
        children: _sugerencias.map((s) => ListTile(
          title: Text(s['nombre']),
          subtitle: Text("Unidad: ${s['unidad']}"),
          trailing: const Icon(LucideIcons.plusCircle, color: Colors.green),
          onTap: () {
            setState(() {
              _productosSeleccionados.add({"nombre": s['nombre'], "unidad": s['unidad'], "cantidad": 1.0});
              _sugerencias = [];
              _searchController.clear();
            });
          },
        )).toList(),
      ),
    );
  }

  // ✅ CORRECCIÓN AQUÍ: DISEÑO FLEXIBLE PARA EL NOMBRE DEL PRODUCTO
  Widget _buildListaProductos() {
    if (_productosSeleccionados.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("No hay productos agregados", style: TextStyle(color: Colors.grey)),
      ));
    }

    return Column(
      children: _productosSeleccionados.asMap().entries.map((entry) {
        int i = entry.key;
        var p = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // 1. Nombre y Unidad (Ocupa todo el espacio disponible)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['nombre'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Unidad: ${p['unidad']}",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 10),

              // 2. Controles de Cantidad
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(LucideIcons.minus, size: 18, color: Colors.red),
                      onPressed: () => _updateCantidad(i, -1),
                    ),
                    Text(
                      "${p['cantidad']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(LucideIcons.plus, size: 18, color: Colors.green),
                      onPressed: () => _updateCantidad(i, 1),
                    ),
                  ],
                ),
              ),

              // 3. Botón Eliminar
              IconButton(
                icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 20),
                onPressed: () => setState(() => _productosSeleccionados.removeAt(i)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServicioInput(),
                  const SizedBox(height: 20),
                  _buildSearchInput(),
                  if (_sugerencias.isNotEmpty) _buildSugerencias(),
                  const SizedBox(height: 25),
                  const Text("PRODUCTOS SELECCIONADOS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 15),
                  _buildListaProductos(),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _guardarLocalmente,
                      icon: const Icon(LucideIcons.save, color: Colors.white),
                      label: const Text("GUARDAR BORRADOR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}