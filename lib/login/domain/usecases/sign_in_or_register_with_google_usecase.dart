import 'package:firebase_auth/firebase_auth.dart';
import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import 'package:integrador/core/services/fcm_service.dart';
import 'package:integrador/login/data/datasource/auth_datasource.dart';
import 'package:integrador/register/data/datasource/registration_datasource.dart';
import 'package:integrador/login/domain/entities/user.dart' as domain;
import 'package:integrador/register/data/model/registration_request_model.dart';

class SignInOrRegisterWithGoogleUseCase {
  final AuthDataSource authDataSource;
  final RegistrationDataSource registrationDataSource;
  final FirebaseAuth _firebaseAuth;
  final FCMService _fcmService;

  SignInOrRegisterWithGoogleUseCase(
    this.authDataSource,
    this.registrationDataSource,
    this._firebaseAuth,
    this._fcmService,
  ) {
    print(
      '🎯 SignInOrRegisterWithGoogleUseCase: Initialized with RegistrationDataSource: ${registrationDataSource.runtimeType}',
    );
  }

  Future<Either<Failure, domain.User>> call() async {
    try {
      print(
        '🔄 SignInOrRegisterWithGoogleUseCase: Starting Google authentication',
      );

      final user = await authDataSource.signInWithGoogle();
      if (user == null) {
        print(
          '❌ SignInOrRegisterWithGoogleUseCase: Google authentication failed',
        );
        return Left(AuthFailure('No se pudo autenticar con Google'));
      }

      print(
        '✅ SignInOrRegisterWithGoogleUseCase: Google authentication successful',
      );
      print('✅ SignInOrRegisterWithGoogleUseCase: User email: ${user.email}');
      print('✅ SignInOrRegisterWithGoogleUseCase: User UID: ${user.id}');

      final idToken = await _getFirebaseIdToken();
      if (idToken == null) {
        print(
          '❌ SignInOrRegisterWithGoogleUseCase: Could not get Firebase ID token',
        );
        return Left(AuthFailure('No se pudo obtener el token de Firebase'));
      }

      try {
        print(
          '🔄 SignInOrRegisterWithGoogleUseCase: Attempting Firebase login with API',
        );
        final fcmToken = await _fcmService.getFCMToken();

        final loginUser = await authDataSource.signInWithFirebase(
          idToken,
          fcmToken,
        );
        if (loginUser != null) {
          print(
            '✅ SignInOrRegisterWithGoogleUseCase: User already exists, login successful',
          );
          return Right(loginUser.toEntity());
        }
      } catch (e) {
        print(
          'ℹ️ SignInOrRegisterWithGoogleUseCase: User not found in API, proceeding with registration',
        );
        print('ℹ️ SignInOrRegisterWithGoogleUseCase: Error: $e');

        if (e.toString().contains('Usuario no encontrado') ||
            e.toString().contains('invalid-credential') ||
            e.toString().contains('user-not-found') ||
            e.toString().contains('Email o contraseña incorrectos')) {
          print(
            'ℹ️ SignInOrRegisterWithGoogleUseCase: User needs registration, continuing...',
          );
        } else {
          print(
            '❌ SignInOrRegisterWithGoogleUseCase: Unexpected error, stopping process',
          );
          return Left(AuthFailure(e.toString()));
        }
      }

      print(
        '🔄 SignInOrRegisterWithGoogleUseCase: Registering new user with Firebase API',
      );

      final nameParts = (user.displayName ?? '').split(' ');
      final nombre = nameParts.isNotEmpty ? nameParts.first : 'Usuario';
      final apellido =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Google';

      final request = RegistrationRequestModel(
        nombre: nombre,
        apellido: apellido,
        email: user.email,
        phone: '', 
        contrasena: '', 
        idiomaPreferido: 'zapoteco', 
        fcmToken: await _fcmService.getFCMToken(),
        isGoogle: true,
      );

      print(
        '🔄 SignInOrRegisterWithGoogleUseCase: Calling registrationDataSource.registerWithFirebase',
      );
      print('🔄 SignInOrRegisterWithGoogleUseCase: Request data:');
      print('  - nombre: $nombre');
      print('  - apellido: $apellido');
      print('  - email: ${user.email}');
      print('  - displayName: ${user.displayName}');
      print('  - firebaseUid: ${user.id}');

      final registrationResponse = await registrationDataSource
          .registerWithFirebase(
            request,
            user.displayName ?? '$nombre $apellido',
            user.id,
            true, 
          );

      print('✅ SignInOrRegisterWithGoogleUseCase: Registration successful');
      print(
        '✅ SignInOrRegisterWithGoogleUseCase: User ID: ${registrationResponse.id}',
      );

      final newIdToken = await _getFirebaseIdToken();
      if (newIdToken != null) {
        final loginUser = await authDataSource.signInWithFirebase(
          newIdToken,
          await _fcmService.getFCMToken(),
        );
        if (loginUser != null) {
          print(
            '✅ SignInOrRegisterWithGoogleUseCase: Login after registration successful',
          );
          return Right(loginUser.toEntity());
        }
      }

      print(
        '⚠️ SignInOrRegisterWithGoogleUseCase: Using Firebase user as fallback',
      );
      return Right(user.toEntity());
    } catch (e) {
      print('❌ SignInOrRegisterWithGoogleUseCase: Error: $e');
      return Left(AuthFailure(e.toString()));
    }
  }

  Future<String?> _getFirebaseIdToken() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final idToken = await currentUser.getIdToken();
        print(
          '✅ SignInOrRegisterWithGoogleUseCase: Firebase ID token obtained',
        );
        return idToken;
      }
      print('❌ SignInOrRegisterWithGoogleUseCase: No Firebase user found');
      return null;
    } catch (e) {
      print(
        '❌ SignInOrRegisterWithGoogleUseCase: Error getting Firebase ID token: $e',
      );
      return null;
    }
  }
}
