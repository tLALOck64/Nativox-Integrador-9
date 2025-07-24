import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:integrador/login/data/model/user_model.dart';
import 'package:integrador/login/data/model/firebase_login_response_model.dart';
import 'package:integrador/core/services/secure_storage_service.dart';

abstract class AuthDataSource {
  Future<UserModel?> signInWithEmailAndPassword(String email, String password);
  Future<UserModel?> signInWithGoogle();
  Future<UserModel?> signInWithFirebase(String idToken, String fcmToken);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthDataSourceImpl implements AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // URL de tu API
  static const String _baseUrl =
      'https://a3pl892azf.execute-api.us-east-1.amazonaws.com/micro-user/api_user';

  AuthDataSourceImpl(this._firebaseAuth, this._googleSignIn);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    print('🚀 API LOGIN - NOT FIREBASE! Starting login for $email');

    try {
      print('🔄 AuthDataSource: Making HTTP POST to API...');
      print('🔄 AuthDataSource: URL: $_baseUrl/usuarios/login');
      print('🔄 AuthDataSource: Email: $email');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/usuarios/login'),
            headers: _headers,
            body: json.encode({'email': email, 'contrasena': password}),
          )
          .timeout(const Duration(seconds: 30));
      print(response);
      print('📡 AuthDataSource: API Response status: ${response.statusCode}');
      print('📡 AuthDataSource: API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('📦 AuthDataSource: Parsed response data: $responseData');

        // ✅ ADAPTACIÓN FLEXIBLE DE LA RESPUESTA
        final userData = responseData['user'] ?? responseData;
        print('👤 AuthDataSource: User data from API: $userData');

        // Guardar el token de la API en almacenamiento seguro
        final token = responseData['token'] ?? responseData['access_token'];
        if (token != null) {
          await SecureStorageService().saveToken(token);
        }

        // Crear UserModel desde la respuesta de tu API
        final userModel = UserModel(
          id:
              userData['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          email: userData['email'] ?? email,
          displayName:
              userData['displayName'] ??
              userData['name'] ??
              userData['username'] ??
              email.split('@')[0],
          photoUrl:
              userData['photoUrl'] ?? userData['photo'] ?? userData['avatar'],
        );

        print('✅ AuthDataSource: User created from API response');
        print('✅ AuthDataSource: User ID: ${userModel.id}');
        print('✅ AuthDataSource: User Email: ${userModel.email}');
        print('✅ AuthDataSource: User Display Name: ${userModel.displayName}');

        return userModel;
      } else if (response.statusCode == 401) {
        print('❌ AuthDataSource: Invalid credentials (401)');
        throw Exception('CUSTOM_AUTH_ERROR: invalid-credential');
      } else if (response.statusCode == 404) {
        print('❌ AuthDataSource: User not found (404)');
        throw Exception('CUSTOM_AUTH_ERROR: user-not-found');
      } else if (response.statusCode == 400) {
        print('❌ AuthDataSource: Bad request (400)');
        throw Exception('CUSTOM_AUTH_ERROR: invalid-email');
      } else {
        print(
          '❌ AuthDataSource: API Error ${response.statusCode}: ${response.body}',
        );
        throw Exception('CUSTOM_AUTH_ERROR: server-error');
      }
    } catch (e) {
      print('❌ AuthDataSource: Exception during API login: $e');

      // ✅ NO CONVERTIR A FirebaseAuthException - Usar excepciones propias
      if (e.toString().contains('CUSTOM_AUTH_ERROR:')) {
        final errorCode = e.toString().split('CUSTOM_AUTH_ERROR: ')[1];
        throw _createCustomAuthException(errorCode);
      }

      if (e.toString().contains('SocketException') ||
          e.toString().contains('network')) {
        throw Exception('CUSTOM_AUTH_ERROR: network-error');
      } else if (e.toString().contains('TimeoutException') ||
          e.toString().contains('timeout')) {
        throw Exception('CUSTOM_AUTH_ERROR: timeout');
      } else {
        throw Exception('CUSTOM_AUTH_ERROR: unknown');
      }
    }
  }

  @override
  Future<UserModel?> signInWithFirebase(String idToken, String fcmToken) async {
    try {
      print('🔄 AuthDataSource: Starting Firebase login with API');
      print('🔄 AuthDataSource: URL: $_baseUrl/firebase/login');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/firebase/login'),
            headers: _headers,
            body: json.encode({'idToken': idToken, 'fcmToken': fcmToken}),
          )
          .timeout(const Duration(seconds: 30));

      print(
        '📡 AuthDataSource: Firebase API Response status: ${response.statusCode}',
      );
      print('📡 AuthDataSource: Firebase API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final firebaseResponse = FirebaseLoginResponseModel.fromJson(
          responseData,
        );
        print(firebaseResponse.data.user);
        print('✅ AuthDataSource: Firebase login successful');
        print('✅ AuthDataSource: API Token: ${firebaseResponse.data.token}');
        print('✅ AuthDataSource: User: ${firebaseResponse.data.user.email}');

        // Guardar el token de la API en almacenamiento seguro
        await SecureStorageService().saveToken(firebaseResponse.data.token);
        await SecureStorageService().saveUserData(
          firebaseResponse.data.user.toJson(),
        );

        // Crear UserModel desde la respuesta de Firebase API
        final userModel = UserModel(
          id: firebaseResponse.data.user.uid,
          email: firebaseResponse.data.user.email,
          displayName: firebaseResponse.data.user.displayName,
          photoUrl: null, // La API no incluye photoUrl en la respuesta
        );

        return userModel;
      } else if (response.statusCode == 401) {
        print('❌ AuthDataSource: Invalid Firebase token (401)');
        throw Exception('CUSTOM_AUTH_ERROR: invalid-credential');
      } else if (response.statusCode == 404) {
        print('❌ AuthDataSource: User not found in API (404)');
        throw Exception('CUSTOM_AUTH_ERROR: user-not-found');
      } else {
        print(
          '❌ AuthDataSource: Firebase API Error ${response.statusCode}: ${response.body}',
        );
        throw Exception('CUSTOM_AUTH_ERROR: server-error');
      }
    } catch (e) {
      print('❌ AuthDataSource: Exception during Firebase login: $e');

      if (e.toString().contains('CUSTOM_AUTH_ERROR:')) {
        final errorCode = e.toString().split('CUSTOM_AUTH_ERROR: ')[1];
        throw _createCustomAuthException(errorCode);
      }
      rethrow;
    }
  }

  Exception _createCustomAuthException(String code) {
    switch (code) {
      case 'invalid-credential':
        return Exception('Email o contraseña incorrectos');
      case 'user-not-found':
        return Exception('Usuario no encontrado');
      case 'invalid-email':
        return Exception('Email inválido');
      case 'network-error':
        return Exception('Error de conexión. Verifica tu internet.');
      case 'timeout':
        return Exception('Tiempo de espera agotado. Intenta nuevamente.');
      case 'server-error':
        return Exception('Error del servidor. Intenta más tarde.');
      default:
        return Exception('Error inesperado. Intenta nuevamente.');
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      print('🔄 AuthDataSource: Starting Google Sign-In with Firebase');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ AuthDataSource: Google Sign-In cancelled by user');
        return null;
      }
      print('googleUser: $googleUser');
      print('✅ AuthDataSource: Google account selected: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('✅ AuthDataSource: Google authentication obtained');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print(
        '🔄 AuthDataSource: Signing in to Firebase with Google credentials',
      );
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        print('✅ AuthDataSource: Firebase Google sign-in successful');
        return UserModel.fromFirebaseUser(firebaseUser);
      }

      print('❌ AuthDataSource: Firebase user is null after Google sign-in');
      return null;
    } catch (e) {
      print('❌ AuthDataSource: Google Sign-In error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      print('🔄 AuthDataSource: Signing out from all systems...');

      await _googleSignIn.signOut();
      print('✅ AuthDataSource: Google sign out completed');
      await _firebaseAuth.signOut();
      print('✅ AuthDataSource: Firebase sign out completed');

    } catch (e) {
      print('❌ AuthDataSource: Sign out error: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // ✅ Primero verificar Firebase (para usuarios de Google)
      final User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        print(
          '✅ AuthDataSource: Current Firebase user found: ${firebaseUser.email}',
        );
        return UserModel.fromFirebaseUser(firebaseUser);
      }

      // ✅ TODO: Verificar token de API almacenado (para usuarios de email/password)
      // return await _getCurrentUserFromApiToken();

      print('ℹ️ AuthDataSource: No current user found');
      return null;
    } catch (e) {
      print('❌ AuthDataSource: Error getting current user: $e');
      return null;
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((User? user) {
      if (user != null) {
        print(
          '🔄 AuthDataSource: Firebase auth state changed - user logged in: ${user.email}',
        );
        return UserModel.fromFirebaseUser(user);
      } else {
        print(
          '🔄 AuthDataSource: Firebase auth state changed - user logged out',
        );
        return null;
      }
    });
  }
}
