import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/data/services/auth_service.dart';
import 'package:sistema_ocs/features/login/auth_notifier.dart';

final currentUserProvider = FutureProvider((ref) async {
  final authService = ref.read(authServiceProvider);
  return await authService.getCurrentUser();
});