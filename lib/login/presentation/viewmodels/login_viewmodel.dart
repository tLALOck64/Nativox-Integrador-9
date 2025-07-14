import 'package:flutter/foundation.dart';
import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/core/navigation/navigation_service.dart';
import 'package:integrador/core/navigation/route_names.dart';
import 'package:integrador/login/domain/entities/user.dart' as domain;
import 'package:integrador/login/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:integrador/login/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:integrador/login/domain/usecases/get_current_user_usecase.dart';
import 'package:integrador/login/domain/usecases/sign_out_usecase.dart';
import 'package:integrador/login/presentation/states/login_state.dart';

class LoginViewModel extends ChangeNotifier {
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignOutUseCase _signOutUseCase;
  final StorageService _storageService;

  LoginState _state = LoginState.initial();
  LoginState get state => _state;

  LoginViewModel({
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SignOutUseCase signOutUseCase,
    required StorageService storageService,
  }) : _signInWithEmailUseCase = signInWithEmailUseCase,
       _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _signOutUseCase = signOutUseCase,
       _storageService = storageService;

  Future<void> signInWithEmail(String email, String password) async {
    _updateState(_state.copyWith(status: LoginStatus.loading));

    final result = await _signInWithEmailUseCase(email, password);
    
    result.fold(
      (failure) => _handleFailure(failure),
      (user) => _handleSuccess(user),
    );
  }

  Future<void> signInWithGoogle() async {
    _updateState(_state.copyWith(status: LoginStatus.loading));

    final result = await _signInWithGoogleUseCase();
    
    result.fold(
      (failure) => _handleFailure(failure),
      (user) => _handleSuccess(user),
    );
  }

  Future<void> signOut() async {
    final result = await _signOutUseCase();
    result.fold(
      (failure) => _handleFailure(failure),
      (_) {
        _storageService.clearTokens();
        _updateState(LoginState.initial());
        NavigationService.pushAndClearStack(RouteNames.login);
      },
    );
  }

  void _handleFailure(Failure failure) {
    String userMessage = _getErrorMessage(failure);
    
    _updateState(_state.copyWith(
      status: LoginStatus.error,
      errorMessage: userMessage,
    ));
  }

  void _handleSuccess(domain.User user) async {
    // Guardar datos del usuario
    await _storageService.saveUserData({
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
    });

    _updateState(_state.copyWith(
      status: LoginStatus.success,
      user: user,
    ));

    // Navegar a home
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

  void _updateState(LoginState newState) {
    _state = newState;
    notifyListeners();
  }
}