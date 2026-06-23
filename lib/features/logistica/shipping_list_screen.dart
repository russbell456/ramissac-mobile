// lib/features/logistica/shipping_list_screen.dart

import 'package:flutter/material.dart';

class ShippingListScreen extends StatelessWidget {
  const ShippingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Muestra la lista de ítems en tránsito y recepciones pendientes (Módulo 9)
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text('MÓDULO DE LOGÍSTICA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Lista de Envíos y Recepciones Pendientes'),
        ],
      ),
    );
  }
}