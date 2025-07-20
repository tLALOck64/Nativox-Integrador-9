import '../../data/model/registration_response_model.dart';

enum RegistrationStatus { initial, loading, success, error, checkingEmail }

class RegistrationState {
  final RegistrationStatus status;
  final String? errorMessage;
  final RegistrationResponseModel? registrationResponse;
  final bool isEmailAvailable;
  final bool isEmailChecked;

  const RegistrationState({
    required this.status,
    this.errorMessage,
    this.registrationResponse,
    this.isEmailAvailable = true,
    this.isEmailChecked = false,
  });

  factory RegistrationState.initial() {
    return const RegistrationState(
      status: RegistrationStatus.initial,
      isEmailAvailable: true,
      isEmailChecked: false,
    );
  }

  RegistrationState copyWith({
    RegistrationStatus? status,
    String? errorMessage,
    RegistrationResponseModel? registrationResponse,
    bool? isEmailAvailable,
    bool? isEmailChecked,
  }) {
    return RegistrationState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      registrationResponse: registrationResponse ?? this.registrationResponse,
      isEmailAvailable: isEmailAvailable ?? this.isEmailAvailable,
      isEmailChecked: isEmailChecked ?? this.isEmailChecked,
    );
  }
}
