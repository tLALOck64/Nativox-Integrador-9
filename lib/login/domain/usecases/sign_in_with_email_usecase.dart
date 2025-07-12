
import 'package:integrador/login/domain/entities/auth_result.dart';
import 'package:integrador/login/domain/repository/auth_repository.dart';

class SignInWithEmailUseCase {
  final AuthRepository _authRepository;

  SignInWithEmailUseCase(this._authRepository);

  Future<AuthResult> call(String email, String password) {
    return _authRepository.signInWithEmailAndPassword(email, password);
  }
}
