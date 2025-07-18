import '../../domain/entities/registration_response.dart';

class RegistrationResponseModel extends RegistrationResponse {
  const RegistrationResponseModel({
    required String id,
  }) : super(id: id);

  factory RegistrationResponseModel.fromJson(Map<String, dynamic> json) {
    return RegistrationResponseModel(
      id: json['id'] ?? '',
    );
  }

  RegistrationResponse toEntity() {
    return RegistrationResponse(id: id);
  }
}