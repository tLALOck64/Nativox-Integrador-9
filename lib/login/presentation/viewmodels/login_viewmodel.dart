import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/core/navigation/navigation_service.dart';
import 'package:integrador/core/navigation/route_names.dart';
import 'package:integrador/login/domain/entities/user.dart' as domain;
import 'package:integrador/login/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:integrador/login/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:integrador/login/domain/usecases/sign_in_or_register_with_google_usecase.dart';
import 'package:integrador/login/domain/usecases/get_current_user_usecase.dart';
import 'package:integrador/login/domain/usecases/sign_out_usecase.dart';
import 'package:integrador/login/presentation/states/login_state.dart';

class LoginViewModel extends ChangeNotifier {
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInOrRegisterWithGoogleUseCase _signInOrRegisterWithGoogleUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignOutUseCase _signOutUseCase;
  final StorageService _storageService;

  LoginState _state = LoginState.initial();
  LoginState get state => _state;

  LoginViewModel({
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInOrRegisterWithGoogleUseCase
    signInOrRegisterWithGoogleUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SignOutUseCase signOutUseCase,
    required StorageService storageService,
  }) : _signInWithEmailUseCase = signInWithEmailUseCase,
       _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _signInOrRegisterWithGoogleUseCase = signInOrRegisterWithGoogleUseCase,
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

    final result = await _signInOrRegisterWithGoogleUseCase();

    result.fold(
      (failure) => _handleFailure(failure),
      (user) => _handleSuccess(user),
    );
  }

  Future<void> signOut() async {
    print('🔄 LoginViewModel: Starting sign out process');
    try {
      final result = await _signOutUseCase();
      result.fold(
        (failure) {
          print('❌ LoginViewModel: Sign out failed: ${failure.message}');
          _handleFailure(failure);
        },
        (_) async {
          print(
            '✅ LoginViewModel: Sign out successful, clearing data and navigating',
          );
          try {
            await _storageService.clearTokens();
            await _storageService.remove('user_data');
            print('✅ LoginViewModel: Local data cleared');

            _updateState(LoginState.initial());
            print('✅ LoginViewModel: State reset to initial');

            print('🚀 LoginViewModel: Navigating to login screen');
            try {
              NavigationService.pushAndClearStack(RouteNames.login);
              print(
                '✅ LoginViewModel: Navigation successful via NavigationService',
              );
            } catch (e) {
              print('❌ LoginViewModel: NavigationService failed: $e');
              // Backup: usar navegación directa si NavigationService falla
              if (NavigationService.context != null) {
                print(
                  '🔄 LoginViewModel: Trying direct navigation via context',
                );
                NavigationService.context!.go(RouteNames.login);
              } else {
                print('❌ LoginViewModel: No navigation context available');
              }
            }
          } catch (e) {
            print('❌ LoginViewModel: Error during cleanup: $e');
            // Aún así intentar navegar
            NavigationService.pushAndClearStack(RouteNames.login);
          }
        },
      );
    } catch (e) {
      print('❌ LoginViewModel: Unexpected error during sign out: $e');
      // En caso de error, limpiar datos y navegar de todas formas
      try {
        await _storageService.clearTokens();
        await _storageService.remove('user_data');
        _updateState(LoginState.initial());
        NavigationService.pushAndClearStack(RouteNames.login);
      } catch (cleanupError) {
        print(
          '❌ LoginViewModel: Error during emergency cleanup: $cleanupError',
        );
      }
    }
  }

  void _handleFailure(Failure failure) {
    String userMessage = _getErrorMessage(failure);

    _updateState(
      _state.copyWith(status: LoginStatus.error, errorMessage: userMessage),
    );
  }

  void _handleSuccess(domain.User user) async {
    await _storageService.saveUserData({
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
    });

    _updateState(_state.copyWith(status: LoginStatus.success, user: user));
    // Navegación eliminada, la UI se encarga de redirigir al home
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
