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
          fcmToken ?? 'default_fcm_token',
      'isGoogle': isGoogle,
    };
  }

  Map<String, dynamic> toFirebaseJson({
    required String displayName,
    required String firebaseUid,
    required bool emailVerified,
  }) {
    String processedPhone = phone;

    if (phone.isEmpty || phone.trim().isEmpty) {
      processedPhone =
          '';
    } else {
      if (phone.startsWith('+')) {
        processedPhone = phone.substring(1);
      }
      processedPhone = processedPhone.replaceAll(RegExp(r'[^\d]'), '');

      if (processedPhone.isEmpty) {
        processedPhone = '';
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
