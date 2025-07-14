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

  @override
  Future<Either<Failure, domain.User>> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      // Verificar conexión
      final hasConnection = await _networkInfo.isConnected;
      if (!hasConnection) {
        return Left(NetworkFailure.noInternet());
      }

      final userModel = await _authDataSource.signInWithEmailAndPassword(email, password);
      if (userModel != null) {
        return Right(userModel.toEntity());
      }
      return Left(AuthFailure('Error al iniciar sesión'));
    } on FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthException(e));
    } on SocketException {
      return Left(NetworkFailure.noInternet());
    } on TimeoutException {
      return Left(NetworkFailure.timeout());
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, domain.User>> signInWithGoogle() async {
    try {
      final hasConnection = await _networkInfo.isConnected;
      if (!hasConnection) {
        return Left(NetworkFailure.noInternet());
      }

      final userModel = await _authDataSource.signInWithGoogle();
      if (userModel != null) {
        return Right(userModel.toEntity());
      }
      return Left(AuthFailure('Inicio de sesión cancelado'));
    } on FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthException(e));
    } catch (e) {
      return Left(ServerFailure('Error con Google Sign-In: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _authDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al cerrar sesión: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, domain.User?>> getCurrentUser() async {
    try {
      final userModel = await _authDataSource.getCurrentUser();
      return Right(userModel?.toEntity());
    } catch (e) {
      return Left(ServerFailure('Error al obtener usuario: ${e.toString()}'));
    }
  }

  @override
  Stream<domain.User?> get authStateChanges {
    return _authDataSource.authStateChanges.map((userModel) => userModel?.toEntity());
  }

  // ✅ MÉTODO CORREGIDO CON LOS FACTORY METHODS CORRECTOS
  Failure _handleFirebaseAuthException(FirebaseAuthException e) {
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
