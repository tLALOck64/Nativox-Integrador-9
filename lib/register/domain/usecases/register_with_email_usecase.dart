import 'package:integrador/core/utils/either.dart';
import 'package:integrador/core/error/failure.dart';
import '../entities/registration_request.dart';
import '../entities/registration_response.dart';
import '../repository/registration_repository.dart';

class RegisterWithEmailUseCase {
  final RegistrationRepository _repository;

  RegisterWithEmailUseCase(this._repository);

  Future<Either<Failure, RegistrationResponse>> call(RegistrationRequest request) async {
    // Validaciones básicas
    if (request.email.isEmpty || !_isValidEmail(request.email)) {
      return Left(ValidationFailure.invalidEmail());
    }
    
    if (request.contrasena.length < 6) {
      return Left(ValidationFailure.weakPassword());
    }
    
    if (request.nombre.isEmpty) {
      return Left(ValidationFailure('El nombre es requerido'));
    }

    if (request.apellido.isEmpty) {
      return Left(ValidationFailure('El apellido es requerido'));
    }

    if (request.phone.isEmpty) {
      return Left(ValidationFailure('El teléfono es requerido'));
    }

    return await _repository.registerWithEmailAndPassword(request);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}