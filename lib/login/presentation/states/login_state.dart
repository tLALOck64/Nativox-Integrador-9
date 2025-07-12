import 'package:integrador/login/domain/entities/user.dart' as domain;

enum LoginStatus { initial, loading, success, error }

class LoginState {
  final LoginStatus status;
  final domain.User? user;
  final String? errorMessage;

  const LoginState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory LoginState.initial() {
    return const LoginState(status: LoginStatus.initial);
  }

  LoginState copyWith({
    LoginStatus? status,
    domain.User? user,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
