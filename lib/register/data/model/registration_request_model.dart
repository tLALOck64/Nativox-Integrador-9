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
    bool isGoogle = false,
  }) : super(
         nombre: nombre,
         apellido: apellido,
         email: email,
         phone: phone,
         contrasena: contrasena,
         idiomaPreferido: idiomaPreferido,
         fcmToken: fcmToken,
         isGoogle: isGoogle,
       );

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'phone': phone,
      'contrasena': contrasena,
      'idiomaPreferido': idiomaPreferido,
      'fcmToken':
          fcmToken ?? 'default_fcm_token', // Token por defecto si no hay
      'isGoogle': isGoogle,
    };
  }

  // Método específico para Firebase
  Map<String, dynamic> toFirebaseJson({
    required String displayName,
    required String firebaseUid,
    required bool emailVerified,
  }) {
    // Procesar el número de teléfono para Firebase
    String processedPhone = phone;

    // Si el teléfono está vacío o es nulo, usar un valor por defecto
    if (phone.isEmpty || phone.trim().isEmpty) {
      processedPhone =
          '0000000000'; // Número por defecto para usuarios de Google
    } else {
      // Si tiene código de país (+52), removerlo
      if (phone.startsWith('+')) {
        processedPhone = phone.substring(1);
      }
      // Remover espacios y caracteres especiales
      processedPhone = processedPhone.replaceAll(RegExp(r'[^\d]'), '');

      // Si después de limpiar está vacío, usar valor por defecto
      if (processedPhone.isEmpty) {
        processedPhone = '0000000000';
      }
    }

    final requestData = {
      'email': email,
      'displayName': displayName,
      'phoneNumber': processedPhone,
      'nombre': nombre,
      'apellido': apellido,
      'idiomaPreferido': idiomaPreferido,
      'fcmToken': fcmToken ?? 'default_fcm_token',
      'firebaseUid': firebaseUid,
      'emailVerified': emailVerified,
    };

    print('📱 RegistrationRequestModel: Phone processing:');
    print('  - Original phone: "$phone"');
    print('  - Processed phone: "$processedPhone"');

    return requestData;
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
