import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import 'package:integrador/login/domain/entities/user.dart' as domain;
import 'package:integrador/login/domain/repository/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository _authRepository;

  SignInWithGoogleUseCase(this._authRepository);

  Future<Either<Failure, domain.User>> call() async {
    return await _authRepository.signInWithGoogle();
  }
}