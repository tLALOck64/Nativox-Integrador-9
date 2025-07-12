import 'package:integrador/login/domain/entities/user.dart' as domain;

class AuthResult {
  final domain.User? user;
  final String? errorMessage;
  final bool isSuccess;

  const AuthResult({
    this.user,
    this.errorMessage,
    required this.isSuccess,
  });

  factory AuthResult.success(domain.User user) {
    return AuthResult(user: user, isSuccess: true);
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult(errorMessage: errorMessage, isSuccess: false);
  }

  @override
  String toString() {
    return 'AuthResult(isSuccess: $isSuccess, user: $user, errorMessage: $errorMessage)';
  }
}
