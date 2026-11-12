import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/data/models/user_model.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';

class WorkersState {
  final bool loading;
  final bool refreshing;
  final List<UserModel> workers;
  final String? errorMessage;

  const WorkersState({
    this.loading = false,
    this.refreshing = false,
    this.workers = const [],
    this.errorMessage,
  });

  WorkersState copyWith({
    bool? loading,
    bool? refreshing,
    List<UserModel>? workers,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WorkersState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      workers: workers ?? this.workers,
      errorMessage:
          clearError
              ? null
              : errorMessage ?? this.errorMessage,
    );
  }
}

final workersProvider = StateNotifierProvider<
    WorkersNotifier,
    WorkersState>(
  (ref) {
    final dio = ref.read(dioProvider);

    return WorkersNotifier(dio);
  },
);

class WorkersNotifier
    extends StateNotifier<WorkersState> {
  final Dio dio;

  WorkersNotifier(this.dio)
      : super(const WorkersState());

  // ===========================================================
  // CARGAR TRABAJADORES
  // ===========================================================

  Future<void> load() async {
    state = state.copyWith(
      loading: state.workers.isEmpty,
      refreshing: state.workers.isNotEmpty,
      clearError: true,
    );

    try {
      final response = await dio.get(
        '/auth/trabajadores',
      );

      final data = response.data;

      if (data is! List) {
        throw Exception(
          'El servidor devolvió un formato inválido.',
        );
      }

      final workers = data
          .whereType<Map<String, dynamic>>()
          .map(
            (json) => UserModel.fromJson(json),
          )
          .toList();

      state = state.copyWith(
        loading: false,
        refreshing: false,
        workers: workers,
        clearError: true,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        loading: false,
        refreshing: false,
        errorMessage:
            _getDioErrorMessage(e),
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        refreshing: false,
        errorMessage:
            'No se pudo cargar la lista de trabajadores.',
      );
    }
  }

  // ===========================================================
  // MENSAJE DE ERROR
  // ===========================================================

  String _getDioErrorMessage(
    DioException error,
  ) {
    final statusCode =
        error.response?.statusCode;

    if (statusCode == 401) {
      return 'La sesión ha expirado. '
          'Inicia sesión nuevamente.';
    }

    if (statusCode == 403) {
      return 'No tienes permisos para consultar '
          'los trabajadores.';
    }

    if (statusCode == 404) {
      return 'No se encontró el recurso solicitado.';
    }

    if (statusCode != null &&
        statusCode >= 500) {
      return 'El servidor presentó un error. '
          'Intenta nuevamente.';
    }

    if (error.type ==
        DioExceptionType.connectionTimeout) {
      return 'Tiempo de conexión agotado.';
    }

    if (error.type ==
        DioExceptionType.receiveTimeout) {
      return 'El servidor tardó demasiado en responder.';
    }

    if (error.type ==
        DioExceptionType.connectionError) {
      return 'No se pudo conectar con el servidor.';
    }

    return 'No se pudo cargar la lista de trabajadores.';
  }
}