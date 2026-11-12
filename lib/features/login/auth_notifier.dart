import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:sistema_ocs/data/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:sistema_ocs/data/models/user_model.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthNotifier extends StateNotifier<AuthStatus> {
  final AuthService _authService;
  final FlutterSecureStorage _storage;
  String? lastError;
  int _authRevision = 0;
  Future<void>? _logoutInProgress;

  AuthNotifier(this._authService, this._storage) : super(AuthStatus.initial) {
    _checkAuthStatus();
  }

  // ✅ CAMBIO 1: La firma usa 'email'
  Future<void> login(String email, String password) async {
    if (state == AuthStatus.loading) return;
    final revision = ++_authRevision;
    lastError = null;
    state = AuthStatus.loading;
    try {
      // ✅ Usa el parámetro 'email'
      final token = await _authService.login(email, password);

      await _storage.write(key: 'jwt_token', value: token.accessToken);

      if (revision == _authRevision) state = AuthStatus.authenticated;
    } catch (error, stackTrace) {
      if (revision != _authRevision) return;
      lastError = error.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Login falló: $lastError');
      debugPrintStack(stackTrace: stackTrace);
      state = AuthStatus.unauthenticated;
    }
  }

  Future<void> _checkAuthStatus() async {
    final revision = _authRevision;
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (revision == _authRevision) {
        state = token != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
      }
    } catch (_) {
      if (revision == _authRevision) state = AuthStatus.unauthenticated;
    }
  }

  Future<void> logout() {
    final activeLogout = _logoutInProgress;
    if (activeLogout != null) return activeLogout;

    // Publish logout immediately so the app returns to LoginScreen. The
    // revision prevents the startup token check from restoring stale auth.
    ++_authRevision;
    state = AuthStatus.unauthenticated;
    final operation = _clearSession();
    _logoutInProgress = operation;
    return operation.whenComplete(() => _logoutInProgress = null);
  }

  Future<void> _clearSession() async {
    // Keep unrelated secure preferences (for example the selected theme).
    await _authService.logout();
  }
}

// Proveedores de Riverpod
final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final authServiceProvider = Provider((ref) {
  // Aquí está el truco: le pasamos el Dio que ya tiene el Interceptor
  final dio = ref.watch(dioProvider);
  return AuthService(dio);
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthStatus>(
  (ref) => AuthNotifier(
    ref.watch(authServiceProvider),
    ref.watch(secureStorageProvider),
  ),
);

final authenticatedUserProvider =
    FutureProvider.autoDispose<UserModel>((ref) async {
  try {
    return await ref.read(authServiceProvider).fetchCurrentUser();
  } on DioException catch (error) {
    if (error.response?.statusCode == 401) {
      await ref.read(authNotifierProvider.notifier).logout();
    }
    rethrow;
  }
});
