import 'package:flutter/foundation.dart';
import 'package:integrador/login/domain/entities/user.dart' as domain;
import 'package:integrador/login/domain/usecases/get_current_user_usecase.dart';
import 'package:integrador/login/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:integrador/login/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:integrador/login/domain/usecases/sign_out_usecase.dart';
import 'package:integrador/login/presentation/states/login_state.dart';

class LoginViewModel extends ChangeNotifier {
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignInWithGoogleUsecase _signInWithGoogleUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignOutUseCase _signOutUseCase;

  LoginState _state = LoginState.initial();
  LoginState get state => _state;

  LoginViewModel({
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required SignInWithGoogleUsecase signInWithGoogleUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SignOutUseCase signOutUseCase,
  }) : _signInWithEmailUseCase = signInWithEmailUseCase,
       _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _signOutUseCase = signOutUseCase;

  Future<void> signInWithEmail(String email, String password) async {
    _updateState(_state.copyWith(status: LoginStatus.loading));

    final result = await _signInWithEmailUseCase(email, password);
    
    if (result.isSuccess) {
      _updateState(_state.copyWith(
        status: LoginStatus.success,
        user: result.user,
      ));
    } else {
      _updateState(_state.copyWith(
        status: LoginStatus.error,
        errorMessage: result.errorMessage,
      ));
    }
  }

  Future<void> signInWithGoogle() async {
    _updateState(_state.copyWith(status: LoginStatus.loading));

    final result = await _signInWithGoogleUseCase();
    
    if (result.isSuccess) {
      _updateState(_state.copyWith(
        status: LoginStatus.success,
        user: result.user,
      ));
    } else {
      _updateState(_state.copyWith(
        status: LoginStatus.error,
        errorMessage: result.errorMessage,
      ));
    }
  }

  Future<void> signOut() async {
    await _signOutUseCase();
    _updateState(LoginState.initial());
  }

  void _updateState(LoginState newState) {
    _state = newState;
    notifyListeners();
  }
}