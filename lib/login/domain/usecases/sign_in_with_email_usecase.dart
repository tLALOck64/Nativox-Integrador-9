import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import 'package:integrador/core/utils/validators.dart';
import 'package:integrador/login/domain/entities/user.dart' as domain;
import 'package:integrador/login/domain/repository/auth_repository.dart';

class SignInWithEmailUseCase {
  final AuthRepository _authRepository;

  SignInWithEmailUseCase(this._authRepository);

  Future<Either<Failure, domain.User>> call(String email, String password) async {
    final emailValidation = Validators.email(email);
    if (emailValidation.isLeft) {
      return Left(emailValidation.left);
    }

    final passwordValidation = Validators.password(password);
    if (passwordValidation.isLeft) {
      return Left(passwordValidation.left);
    }

    return await _authRepository.signInWithEmailAndPassword(
      emailValidation.right,  
      passwordValidation.right, 
    );
  }
}