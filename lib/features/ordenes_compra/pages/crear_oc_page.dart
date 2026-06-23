import 'package:flutter/material.dart';
import 'package:sistema_ocs/features/ordenes_compra/models/rq_item_modeloc.dart';
import '../models/orden_compra_request.dart';
import 'package:sistema_ocs/data/services/orden_compra_service.dart';
import '../widgets/rq_item_card.dart';

class CrearOCPage extends StatefulWidget {
  const CrearOCPage({super.key});

  @override
  State<CrearOCPage> createState() => _CrearOCPageState();
}

class _CrearOCPageState extends State<CrearOCPage> {
  final service = OrdenCompraService();

  final List<RqItemModeloc> items = [
    RqItemModeloc(id: 1, producto: 'Laptop', cantidadSolicitada: 10),
    RqItemModeloc(id: 2, producto: 'Mouse', cantidadSolicitada: 20),
  ];

  void crearOrden() async {
    final seleccionados = items
        .where((i) => i.seleccionado && i.cantidadComprar > 0)
        .map(
          (i) => ItemCompraRequest(
            rqItemId: i.id,
            cantidadComprada: i.cantidadComprar,
          ),
        )
        .toList();

    if (seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione al menos un ítem')),
      );
      return;
    }

    final request = OrdenCompraRequest(
      tipoCompra: 'FISICA',
      items: seleccionados,
    );

    await service.crearOrden(request);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Orden creada correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Orden de Compra')),
      body: ListView(
        children: [
          ...items.map(
            (item) => RqItemCard(
              item: item,
              onSelect: (value) {
                setState(() => item.seleccionado = value);
              },
              onCantidadChanged: (value) {
                item.cantidadComprar = int.tryParse(value) ?? 0;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: crearOrden,
              child: const Text('Crear OC'),
            ),
          ),
        ],
      ),
    );
  }
}
