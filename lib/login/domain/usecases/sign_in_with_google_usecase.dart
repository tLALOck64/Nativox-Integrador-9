

import 'package:integrador/login/domain/entities/auth_result.dart';
import 'package:integrador/login/domain/repository/auth_repository.dart';

class SignInWithGoogleUsecase {
  final AuthRepository _authRepository;

  SignInWithGoogleUsecase(this._authRepository);

  Future<AuthResult> call() async {
    return await _authRepository.signInWithGoogle();
  }
}