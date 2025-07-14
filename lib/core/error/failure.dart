abstract class Failure {
  final String message;
  final int? code;
  
  const Failure(this.message, {this.code});
  
  @override
  String toString() => 'Failure: $message';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && 
           other.message == message && 
           other.code == code;
  }
  
  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
  
  factory ServerFailure.internalError() => 
      const ServerFailure('Error interno del servidor', code: 500);
  
  factory ServerFailure.badRequest() => 
      const ServerFailure('Petición incorrecta', code: 400);
  
  factory ServerFailure.notFound() => 
      const ServerFailure('Recurso no encontrado', code: 404);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
  
  // ✅ FACTORY METHODS QUE NECESITAS
  factory NetworkFailure.noInternet() => 
      const NetworkFailure('Sin conexión a internet');
  
  factory NetworkFailure.timeout() => 
      const NetworkFailure('Tiempo de espera agotado');
  
  factory NetworkFailure.serverError(int statusCode) => 
      NetworkFailure('Error del servidor', code: statusCode);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
  
  factory CacheFailure.notFound() => 
      const CacheFailure('Datos no encontrados en cache');
  
  factory CacheFailure.expired() => 
      const CacheFailure('Cache expirado');
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
  
  // ✅ FACTORY METHODS QUE NECESITAS
  factory AuthFailure.invalidCredentials() => 
      const AuthFailure('Credenciales incorrectas');
  
  factory AuthFailure.userNotFound() => 
      const AuthFailure('Usuario no encontrado');
  
  factory AuthFailure.tokenExpired() => 
      const AuthFailure('Sesión expirada');
  
  factory AuthFailure.emailAlreadyExists() => 
      const AuthFailure('El email ya está registrado');
  
  factory AuthFailure.accountDisabled() =>
      const AuthFailure('Cuenta deshabilitada');
  
  factory AuthFailure.tooManyRequests() =>
      const AuthFailure('Demasiados intentos. Intenta más tarde');
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
  
  // ✅ FACTORY METHODS QUE NECESITAS
  factory ValidationFailure.invalidEmail() => 
      const ValidationFailure('Email inválido');
  
  factory ValidationFailure.weakPassword() => 
      const ValidationFailure('Contraseña muy débil');
  
  factory ValidationFailure.required(String field) => 
      ValidationFailure('$field es requerido');
  
  factory ValidationFailure.minLength(String field, int minLength) =>
      ValidationFailure('$field debe tener al menos $minLength caracteres');
  
  factory ValidationFailure.maxLength(String field, int maxLength) =>
      ValidationFailure('$field no puede tener más de $maxLength caracteres');
}
