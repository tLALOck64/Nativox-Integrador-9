import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';

class Validators {
  static Either<ValidationFailure, String> email(String? value) {
    if (value == null || value.isEmpty) {
      return Left(ValidationFailure.required('Email'));
    }
    
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    if (!RegExp(pattern).hasMatch(value)) {
      return Left(ValidationFailure.invalidEmail());
    }
    
    return Right(value);
  }

  static Either<ValidationFailure, String> password(String? value) {
    if (value == null || value.isEmpty) {
      return Left(ValidationFailure.required('Contraseña'));
    }
    
    if (value.length < 6) {
      return Left(ValidationFailure.minLength('Contraseña', 6));
    }
    
    if (value.length > 50) {
      return Left(ValidationFailure.maxLength('Contraseña', 50));
    }
    
    return Right(value);
  }

  static Either<ValidationFailure, String> required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return Left(ValidationFailure.required(fieldName));
    }
    return Right(value.trim());
  }
}
