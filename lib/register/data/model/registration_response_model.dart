import '../../domain/entities/registration_response.dart';

class RegistrationResponseModel extends RegistrationResponse {
  const RegistrationResponseModel({
    required String id, 
    required String email,
    required String nombre,
    required String apellido,
  }) : super(id: id, email: email, nombre: nombre, apellido: apellido);

  factory RegistrationResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return RegistrationResponseModel(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
    );
  }

  RegistrationResponse toEntity() {
    return RegistrationResponse(
      id: id, 
      email: email, 
      nombre: nombre, 
      apellido: apellido
    );
  }
}
