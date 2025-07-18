
import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import 'package:integrador/core/network/network_info.dart';
import 'package:integrador/login/data/datasource/auth_datasource.dart';
import 'package:integrador/login/domain/entities/user.dart' as domain;
import 'package:integrador/login/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl(this._authDataSource, this._networkInfo);

  // ✅ ACTUALIZADO: Email/Password con manejo de tu API
  @override
  Future<Either<Failure, domain.User>> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      print('🔄 AuthRepository: Starting email/password login');
      
      // Verificar conexión
      final hasConnection = await _networkInfo.isConnected;
      if (!hasConnection) {
        print('❌ AuthRepository: No internet connection');
        return Left(NetworkFailure.noInternet());
      }

      print('🔄 AuthRepository: Calling AuthDataSource...');
      final userModel = await _authDataSource.signInWithEmailAndPassword(email, password);
      
      if (userModel != null) {
        print('✅ AuthRepository: User model received, converting to entity');
        return Right(userModel.toEntity());
      }
      
      print('❌ AuthRepository: User model is null');
      return Left(AuthFailure('Error al iniciar sesión'));
      
    } on FirebaseAuthException catch (e) {
      // Solo para casos edge donde Firebase aún se use
      print('❌ AuthRepository: FirebaseAuthException: ${e.code}');
      return Left(_handleFirebaseAuthException(e));
    } on SocketException {
      print('❌ AuthRepository: SocketException');
      return Left(NetworkFailure.noInternet());
    } on TimeoutException {
      print('❌ AuthRepository: TimeoutException');
      return Left(NetworkFailure.timeout());
    } catch (e) {
      print('❌ AuthRepository: Generic exception: $e');
      // ✅ NUEVO: Manejar excepciones de tu API
      return Left(_handleApiException(e));
    }
  }

  // ✅ SIN CAMBIOS: Google sigue usando Firebase
  @override
  Future<Either<Failure, domain.User>> signInWithGoogle() async {
    try {
      print('🔄 AuthRepository: Starting Google login');
      
      final hasConnection = await _networkInfo.isConnected;
      if (!hasConnection) {
        print('❌ AuthRepository: No internet connection for Google');
        return Left(NetworkFailure.noInternet());
      }

      print('🔄 AuthRepository: Calling Google SignIn...');
      final userModel = await _authDataSource.signInWithGoogle();
      
      if (userModel != null) {
        print('✅ AuthRepository: Google user model received');
        return Right(userModel.toEntity());
      }
      
      print('ℹ️ AuthRepository: Google sign-in cancelled');
      return Left(AuthFailure('Inicio de sesión cancelado'));
      
    } on FirebaseAuthException catch (e) {
      print('❌ AuthRepository: Google FirebaseAuthException: ${e.code}');
      return Left(_handleFirebaseAuthException(e));
    } catch (e) {
      print('❌ AuthRepository: Google generic exception: $e');
      return Left(ServerFailure('Error con Google Sign-In: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      print('🔄 AuthRepository: Signing out');
      await _authDataSource.signOut();
      print('✅ AuthRepository: Sign out successful');
      return const Right(null);
    } catch (e) {
      print('❌ AuthRepository: Sign out error: $e');
      return Left(ServerFailure('Error al cerrar sesión: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, domain.User?>> getCurrentUser() async {
    try {
      print('🔄 AuthRepository: Getting current user');
      final userModel = await _authDataSource.getCurrentUser();
      
      if (userModel != null) {
        print('✅ AuthRepository: Current user found: ${userModel.email}');
      } else {
        print('ℹ️ AuthRepository: No current user');
      }
      
      return Right(userModel?.toEntity());
    } catch (e) {
      print('❌ AuthRepository: Error getting current user: $e');
      return Left(ServerFailure('Error al obtener usuario: ${e.toString()}'));
    }
  }

  @override
  Stream<domain.User?> get authStateChanges {
    print('🔄 AuthRepository: Setting up auth state changes stream');
    return _authDataSource.authStateChanges.map((userModel) {
      if (userModel != null) {
        print('🔄 AuthRepository: Auth state changed - user: ${userModel.email}');
      } else {
        print('🔄 AuthRepository: Auth state changed - no user');
      }
      return userModel?.toEntity();
    });
  }

  // ✅ NUEVO: Manejar excepciones de tu API
  Failure _handleApiException(dynamic e) {
    final errorMessage = e.toString().toLowerCase();
    print('🔍 AuthRepository: Handling API exception: $errorMessage');
    
    if (errorMessage.contains('email o contraseña incorrectos') || 
        errorMessage.contains('invalid credentials') ||
        errorMessage.contains('invalid-credential')) {
      return AuthFailure.invalidCredentials();
    } else if (errorMessage.contains('usuario no encontrado') || 
               errorMessage.contains('user not found') ||
               errorMessage.contains('user-not-found')) {
      return AuthFailure.userNotFound();
    } else if (errorMessage.contains('email inválido') || 
               errorMessage.contains('invalid email') ||
               errorMessage.contains('invalid-email')) {
      return ValidationFailure.invalidEmail();
    } else if (errorMessage.contains('error de conexión') || 
               errorMessage.contains('network') ||
               errorMessage.contains('conexión') ||
               errorMessage.contains('internet')) {
      return NetworkFailure.noInternet();
    } else if (errorMessage.contains('tiempo de espera') || 
               errorMessage.contains('timeout') ||
               errorMessage.contains('agotado')) {
      return NetworkFailure.timeout();
    } else if (errorMessage.contains('error del servidor') || 
               errorMessage.contains('server error') ||
               errorMessage.contains('server-error')) {
      return ServerFailure('Error del servidor. Intenta más tarde.');
    } else {
      return ServerFailure('Error inesperado: ${e.toString()}');
    }
  }

  // ✅ MANTENIDO: Para Google Sign-In con Firebase
  Failure _handleFirebaseAuthException(FirebaseAuthException e) {
    print('🔍 AuthRepository: Handling Firebase exception: ${e.code}');
    
    switch (e.code) {
      case 'user-not-found':
        return AuthFailure.userNotFound();
      case 'wrong-password':
        return AuthFailure.invalidCredentials();
      case 'invalid-email':
        return ValidationFailure.invalidEmail();
      case 'user-disabled':
        return AuthFailure.accountDisabled();
      case 'too-many-requests':
        return AuthFailure.tooManyRequests();
      case 'email-already-in-use':
        return AuthFailure.emailAlreadyExists();
      case 'weak-password':
        return ValidationFailure.weakPassword();
      case 'invalid-credential':
        return AuthFailure.invalidCredentials();
      case 'network-request-failed':
        return NetworkFailure.noInternet();
      case 'operation-not-allowed':
        return AuthFailure('Operación no permitida');
      default:
        return AuthFailure(e.message ?? 'Error de autenticación');
    }
  }
}