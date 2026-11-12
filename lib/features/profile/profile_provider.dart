import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/data/models/user_model.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';
import 'package:sistema_ocs/data/network/backend_url.dart';
import 'package:sistema_ocs/features/profile/profile_service.dart';

class ProfileState {
  final UserModel? user;
  final String? signatureImageUrl;
  final bool loading;
  final bool savingSignature;
  final bool uploadingPhoto;
  final String? errorMessage;

  const ProfileState({
    this.user,
    this.signatureImageUrl,
    this.loading = false,
    this.savingSignature = false,
    this.uploadingPhoto = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    UserModel? user,
    String? signatureImageUrl,
    bool? loading,
    bool? savingSignature,
    bool? uploadingPhoto,
    String? errorMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      signatureImageUrl: signatureImageUrl ?? this.signatureImageUrl,
      loading: loading ?? this.loading,
      savingSignature: savingSignature ?? this.savingSignature,
      uploadingPhoto: uploadingPhoto ?? this.uploadingPhoto,
      errorMessage: errorMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _service;
  final String Function(String?) _urlBuilder;

  ProfileNotifier(
    this._service,
    this._urlBuilder,
  ) : super(const ProfileState());

  // ============================================================
  // CARGAR PERFIL
  // GET /auth/me
  // ============================================================
  Future<void> load() async {
    state = state.copyWith(
      loading: true,
      errorMessage: null,
    );

    try {
      final user = await _service.getCurrentUser();

      String? signatureImageUrl;

      if (user.firmaBase64?.trim().isNotEmpty == true) {
        final path = await _service.generateSignatureImage();

        if (path != null) {
          signatureImageUrl = _urlBuilder(path);
        }
      }

      state = ProfileState(
        user: user,
        signatureImageUrl: signatureImageUrl,
      );
    } catch (error, stackTrace) {
      state = ProfileState(
        errorMessage: profileErrorMessage(error),
      );

      debugPrint('Error al cargar el perfil: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ============================================================
  // GUARDAR FIRMA
  // ============================================================
  Future<bool> saveSignature(String base64) async {
    state = state.copyWith(
      savingSignature: true,
      errorMessage: null,
    );

    try {
      final user = await _service.saveSignature(base64);

      final path = await _service.generateSignatureImage();

      state = ProfileState(
        user: user,
        signatureImageUrl:
            path == null ? null : _urlBuilder(path),
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        savingSignature: false,
        errorMessage: profileErrorMessage(error),
      );

      return false;
    }
  }

  // ============================================================
  // SUBIR FOTO
  // ============================================================
  Future<bool> uploadPhoto(PlatformFile file) async {
    state = state.copyWith(
      uploadingPhoto: true,
      errorMessage: null,
    );

    try {
      final user = await _service.uploadPhoto(file);

      state = state.copyWith(
        user: user,
        uploadingPhoto: false,
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        uploadingPhoto: false,
        errorMessage: profileErrorMessage(error),
      );

      return false;
    }
  }

  Future<bool> updateContact({
    required String? telefono,
    required String? telefonoSecundario,
    required String? direccion,
  }) async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      final user = await _service.updateContact(
        telefono: telefono,
        telefonoSecundario: telefonoSecundario,
        direccion: direccion,
      );
      state = ProfileState(user: user, signatureImageUrl: state.signatureImageUrl);
      return true;
    } catch (error) {
      state = state.copyWith(loading: false, errorMessage: profileErrorMessage(error));
      return false;
    }
  }
}

String profileErrorMessage(Object error) {
  if (error is DioException) {
    if (error.response?.statusCode == 401) {
      return 'Tu sesión expiró. Inicia sesión nuevamente.';
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'No se pudo conectar con el servidor. Verifica que el backend esté ejecutándose y que el dispositivo esté conectado a la misma red.';
    }
  }

  return 'No se pudo completar la operación. Inténtalo nuevamente.';
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final dio = ref.watch(dioProvider);

  final service = ProfileService(dio);

  return ProfileNotifier(
    service,
    (path) => buildBackendUrl(dio, path),
  );
});
