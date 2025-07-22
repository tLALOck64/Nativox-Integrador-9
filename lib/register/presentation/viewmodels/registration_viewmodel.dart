import 'package:flutter/foundation.dart';
import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/core/navigation/navigation_service.dart';
import 'package:integrador/core/navigation/route_names.dart';
import '../../domain/entities/registration_request.dart';
import '../../domain/entities/registration_response.dart';
import '../../data/model/registration_response_model.dart';
import '../../domain/usecases/register_with_email_usecase.dart';
import '../../domain/usecases/check_email_availability_usecase.dart';
import '../../domain/usecases/register_with_firebase_email_usecase.dart';
import '../../domain/usecases/register_with_google_usecase.dart';
import '../states/registration_state.dart';

class RegistrationViewModel extends ChangeNotifier {
  final RegisterWithEmailUseCase _registerUseCase;
  final CheckEmailAvailabilityUseCase _checkEmailUseCase;
  final SecureStorageService _storageService;
  final RegisterWithFirebaseEmailUseCase? _registerWithFirebaseEmailUseCase;
  final RegisterWithGoogleUseCase? _registerWithGoogleUseCase;

  RegistrationState _state = RegistrationState.initial();
  RegistrationState get state => _state;

  RegistrationViewModel({
    required RegisterWithEmailUseCase registerUseCase,
    required CheckEmailAvailabilityUseCase checkEmailUseCase,
    required SecureStorageService storageService,
    RegisterWithFirebaseEmailUseCase? registerWithFirebaseEmailUseCase,
    RegisterWithGoogleUseCase? registerWithGoogleUseCase,
  }) : _registerUseCase = registerUseCase,
       _checkEmailUseCase = checkEmailUseCase,
       _storageService = storageService,
       _registerWithFirebaseEmailUseCase = registerWithFirebaseEmailUseCase,
       _registerWithGoogleUseCase = registerWithGoogleUseCase;

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
    print(
      '🔄 RegistrationViewModel: Data - nombre: $nombre, apellido: $apellido, email: $email',
    );

    if (contrasena != confirmPassword) {
      _updateState(
        _state.copyWith(
          status: RegistrationStatus.error,
          errorMessage: 'Las contraseñas no coinciden',
        ),
      );
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

    _updateState(
      _state.copyWith(
        status: RegistrationStatus.checkingEmail,
        isEmailChecked: false,
      ),
    );

    final result = await _checkEmailUseCase(email);

    result.fold(
      (failure) {
        _updateState(
          _state.copyWith(
            status: RegistrationStatus.initial,
            isEmailAvailable: true,
            isEmailChecked: false,
          ),
        );
      },
      (isAvailable) {
        _updateState(
          _state.copyWith(
            status: RegistrationStatus.initial,
            isEmailAvailable: isAvailable,
            isEmailChecked: true,
          ),
        );
      },
    );
  }

  Future<void> registerWithFirebaseEmail({
    required String email,
    required String password,
  }) async {
    if (_registerWithFirebaseEmailUseCase == null) return;
    _updateState(_state.copyWith(status: RegistrationStatus.loading));
    try {
      final user = await _registerWithFirebaseEmailUseCase!(email, password);
      if (user != null) {
        _updateState(_state.copyWith(status: RegistrationStatus.success));
        NavigationService.pushAndClearStack(RouteNames.home);
      } else {
        _updateState(
          _state.copyWith(
            status: RegistrationStatus.error,
            errorMessage: 'No se pudo registrar en Firebase.',
          ),
        );
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          status: RegistrationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> registerWithGoogle({
    required String nombre,
    required String apellido,
    required String phone,
    required String idiomaPreferido,
    String? fcmToken,
  }) async {
    if (_registerWithGoogleUseCase == null) return;
    _updateState(_state.copyWith(status: RegistrationStatus.loading));
    try {
      final response = await _registerWithGoogleUseCase!(
        nombre: nombre,
        apellido: apellido,
        phone: phone,
        idiomaPreferido: idiomaPreferido,
        fcmToken: fcmToken,
      );
      if (response != null) {
        await _storageService.saveUserData({
          'id': response.id,
          'email': response.email,
          'displayName': '$nombre $apellido',
          'photoUrl': null,
          'createdAt': DateTime.now().toIso8601String(),
        });
        _updateState(
          _state.copyWith(
            status: RegistrationStatus.success,
            registrationResponse: response,
          ),
        );
        NavigationService.pushAndClearStack(RouteNames.home);
      } else {
        _updateState(
          _state.copyWith(
            status: RegistrationStatus.error,
            errorMessage: 'No se pudo registrar con Google.',
          ),
        );
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          status: RegistrationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _handleFailure(Failure failure) {
    String userMessage = _getErrorMessage(failure);

    _updateState(
      _state.copyWith(
        status: RegistrationStatus.error,
        errorMessage: userMessage,
      ),
    );
  }

  void _handleSuccess(
    RegistrationResponse response,
    String email,
    String displayName,
  ) async {
    print(
      '✅ RegistrationViewModel: Registration successful, ID: ${response.id}',
    );

    await _storageService.saveUserData({
      'id': response.id,
      'email': email,
      'displayName': displayName,
      'photoUrl': null,
      'createdAt': DateTime.now().toIso8601String(),
    });

    print('💾 RegistrationViewModel: User data saved');

    final responseModel = RegistrationResponseModel(
      id: response.id,
      email: response.email,
      nombre: response.nombre,
      apellido: response.apellido,
    );

    _updateState(
      _state.copyWith(
        status: RegistrationStatus.success,
        registrationResponse: responseModel,
      ),
    );

    print('🚀 RegistrationViewModel: Navigating to home');
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
      _updateState(
        _state.copyWith(status: RegistrationStatus.initial, errorMessage: null),
      );
    }
  }
}
