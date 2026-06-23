import 'package:flutter/material.dart';
import 'package:sistema_ocs/features/ordenes_compra/models/rq_item_modeloc.dart';

class RqItemCard extends StatelessWidget {
  final RqItemModeloc item;
  final Function(bool) onSelect;
  final Function(String) onCantidadChanged;
  final Function(String) onCostoChanged; // 💡 NUEVO

  const RqItemCard({
    super.key,
    required this.item,
    required this.onSelect,
    required this.onCantidadChanged,
    required this.onCostoChanged, // 💡 NUEVO
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          CheckboxListTile(
            title: Text(item.producto, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Solicitado: ${item.cantidadSolicitada}'),
            value: item.seleccionado,
            onChanged: (value) => onSelect(value ?? false),
          ),
          if (item.seleccionado)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Campo Cantidad
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cant. comprar',
                        prefixIcon: Icon(Icons.shopping_cart),
                      ),
                      onChanged: onCantidadChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 💡 NUEVO: Campo Costo Unitario
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Costo Unit.',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      onChanged: onCostoChanged,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}