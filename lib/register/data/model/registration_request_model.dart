import '../../domain/entities/registration_request.dart';
class RegistrationRequestModel extends RegistrationRequest {
  const RegistrationRequestModel({
    required String nombre,
    required String apellido,
    required String email,
    required String phone,
    required String contrasena,
    required String idiomaPreferido,
    String? fcmToken,
  }) : super(
    nombre: nombre,
    apellido: apellido,
    email: email,
    phone: phone,
    contrasena: contrasena,
    idiomaPreferido: idiomaPreferido,
    fcmToken: fcmToken,
  );

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'phone': phone,
      'contrasena': contrasena,
      'idiomaPreferido': idiomaPreferido,
      'fcmToken': fcmToken ?? 'default_fcm_token', // Token por defecto si no hay
    };
  }

  factory RegistrationRequestModel.fromEntity(RegistrationRequest entity) {
    return RegistrationRequestModel(
      nombre: entity.nombre,
      apellido: entity.apellido,
      email: entity.email,
      phone: entity.phone,
      contrasena: entity.contrasena,
      idiomaPreferido: entity.idiomaPreferido,
      fcmToken: entity.fcmToken,
    );
  }
}

// registro/data/models/registration_response_model.dart
