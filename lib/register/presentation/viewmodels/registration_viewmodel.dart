import 'package:flutter/foundation.dart';
import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/core/navigation/navigation_service.dart';
import 'package:integrador/core/navigation/route_names.dart';
import '../../domain/entities/registration_request.dart';
import '../../domain/usecases/register_with_email_usecase.dart';
import '../../domain/usecases/check_email_availability_usecase.dart';
import '../states/registration_state.dart';

class RegistrationViewModel extends ChangeNotifier {
  final RegisterWithEmailUseCase _registerUseCase;
  final CheckEmailAvailabilityUseCase _checkEmailUseCase;
  final StorageService _storageService;

  RegistrationState _state = RegistrationState.initial();
  RegistrationState get state => _state;

  RegistrationViewModel({
    required RegisterWithEmailUseCase registerUseCase,
    required CheckEmailAvailabilityUseCase checkEmailUseCase,
    required StorageService storageService,
  }) : _registerUseCase = registerUseCase,
       _checkEmailUseCase = checkEmailUseCase,
       _storageService = storageService;

  Future<void> registerWithEmail({
    required String nombre,
    required String apellido,
    required String email,
    required String phone,
    required String contrasena,
    required String confirmPassword,
    required String idiomaPreferido,
    String? fcmToken,
  }) async {
    print('🔄 RegistrationViewModel: Starting registration');
    print('🔄 RegistrationViewModel: Data - nombre: $nombre, apellido: $apellido, email: $email');

    // Validaciones frontend
    if (contrasena != confirmPassword) {
      _updateState(_state.copyWith(
        status: RegistrationStatus.error,
        errorMessage: 'Las contraseñas no coinciden',
      ));
      return;
    }

    _updateState(_state.copyWith(status: RegistrationStatus.loading));

    final request = RegistrationRequest(
      nombre: nombre,
      apellido: apellido,
      email: email,
      phone: phone,
      contrasena: contrasena,
      idiomaPreferido: idiomaPreferido,
      fcmToken: fcmToken ?? 'default_fcm_token',
    );

    final result = await _registerUseCase(request);
    
    result.fold(
      (failure) => _handleFailure(failure),
      (response) => _handleSuccess(response, email, '$nombre $apellido'),
    );
  }

  Future<void> checkEmailAvailability(String email) async {
    if (email.isEmpty) return;

    _updateState(_state.copyWith(
      status: RegistrationStatus.checkingEmail,
      isEmailChecked: false,
    ));

    final result = await _checkEmailUseCase(email);
    
    result.fold(
      (failure) {
        _updateState(_state.copyWith(
          status: RegistrationStatus.initial,
          isEmailAvailable: true,
          isEmailChecked: false,
        ));
      },
      (isAvailable) {
        _updateState(_state.copyWith(
          status: RegistrationStatus.initial,
          isEmailAvailable: isAvailable,
          isEmailChecked: true,
        ));
      },
    );
  }

  void _handleFailure(Failure failure) {
    String userMessage = _getErrorMessage(failure);
    
    _updateState(_state.copyWith(
      status: RegistrationStatus.error,
      errorMessage: userMessage,
    ));
  }

  void _handleSuccess(RegistrationResponse response, String email, String displayName) async {
    print('✅ RegistrationViewModel: Registration successful, ID: ${response.id}');
    
    // Guardar datos del usuario registrado
    await _storageService.saveUserData({
      'id': response.id,
      'email': email,
      'displayName': displayName,
      'photoUrl': null,
      'createdAt': DateTime.now().toIso8601String(),
    });

    print('💾 RegistrationViewModel: User data saved');

    _updateState(_state.copyWith(
      status: RegistrationStatus.success,
      registrationResponse: response,
    ));

    print('🚀 RegistrationViewModel: Navigating to home');
    // Navegar a home después del registro exitoso
    NavigationService.pushAndClearStack(RouteNames.home);
  }

  String _getErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Problema de conexión. Verifica tu internet y intenta nuevamente.';
    } else if (failure is AuthFailure) {
      return failure.message;
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return 'Error del servidor. Intenta más tarde.';
    } else {
      return 'Ocurrió un error inesperado. Intenta nuevamente.';
    }
  }

  void _updateState(RegistrationState newState) {
    _state = newState;
    notifyListeners();
  }

  void clearError() {
    if (_state.status == RegistrationStatus.error) {
      _updateState(_state.copyWith(
        status: RegistrationStatus.initial,
        errorMessage: null,
      ));
    }
  }
}
