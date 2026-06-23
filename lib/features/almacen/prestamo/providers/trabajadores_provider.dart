import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/data/services/auth_service.dart';
import 'package:sistema_ocs/features/login/auth_notifier.dart';

final trabajadoresProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final authService = ref.read(authServiceProvider);
  final trabajadores = await authService.getTrabajadores(); // tu método auth/trabajadores
  return trabajadores;
});
final trabajadorSeleccionadoProvider = StateProvider<Map<String, dynamic>?>((ref) => null);