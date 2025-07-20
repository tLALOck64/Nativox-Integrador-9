import 'package:integrador/login/data/datasource/firebase_auth_datasource.dart';
import 'package:integrador/login/data/model/user_model.dart';
import '../../data/datasource/registration_datasource.dart';
import '../../data/model/registration_request_model.dart';
import '../../data/model/registration_response_model.dart';

class RegisterWithGoogleUseCase {
  final FirebaseAuthDataSource firebaseAuthDataSource;
  final RegistrationDataSource registrationDataSource;

  RegisterWithGoogleUseCase(
    this.firebaseAuthDataSource,
    this.registrationDataSource,
  );

  Future<RegistrationResponseModel?> call({
    required String nombre,
    required String apellido,
    required String phone,
    required String idiomaPreferido,
    String? fcmToken,
  }) async {
    try {
      print(
        '🔄 RegisterWithGoogleUseCase: Starting Google registration process',
      );

      // 1. Registrar/iniciar sesión en Firebase con Google
      final user = await firebaseAuthDataSource.signInWithGoogle();
      if (user == null) {
        print('❌ RegisterWithGoogleUseCase: Google authentication failed');
        throw Exception('No se pudo autenticar con Google');
      }

      print('✅ RegisterWithGoogleUseCase: Google authentication successful');
      print('✅ RegisterWithGoogleUseCase: User email: ${user.email}');
      print('✅ RegisterWithGoogleUseCase: User UID: ${user.id}');

      // 2. Crear request para la API de Firebase
      final request = RegistrationRequestModel(
        nombre: nombre,
        apellido: apellido,
        email: user.email,
        phone: phone,
        contrasena: '', // No se requiere contraseña para Google
        idiomaPreferido: idiomaPreferido,
        fcmToken: fcmToken ?? 'default_fcm_token',
        isGoogle: true,
      );

      // 3. Registrar en backend usando la nueva API de Firebase
      final response = await registrationDataSource.registerWithFirebase(
        request,
        user.displayName ?? '$nombre $apellido',
        user.id,
        true, // emailVerified siempre es true para Google
      );

      print('✅ RegisterWithGoogleUseCase: Registration successful');
      return response;
    } catch (e) {
      print('❌ RegisterWithGoogleUseCase: Error during registration: $e');
      rethrow;
    }
  }
}
