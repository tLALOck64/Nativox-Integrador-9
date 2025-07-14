import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integrador/core/error/failure.dart';

class ErrorHandler {
  static Failure handleError(dynamic error) {
    if (error is Failure) {
      return error;
    } else if (error is FirebaseAuthException) {
      return _handleFirebaseAuthException(error);
    } else if (error is DioException) {
      return _handleDioError(error);
    } else if (error is SocketException) {
      return NetworkFailure.noInternet();
    } else if (error is TimeoutException) {
      return NetworkFailure.timeout();
    } else if (error is FormatException) {
      return ValidationFailure('Formato de datos inválido');
    } else {
      return ServerFailure('Error inesperado: ${error.toString()}');
    }
  }

  static Failure _handleFirebaseAuthException(FirebaseAuthException e) {
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
      default:
        return AuthFailure(e.message ?? 'Error de autenticación');
    }
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure.timeout();
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      case DioExceptionType.cancel:
        return NetworkFailure('Petición cancelada');
      case DioExceptionType.connectionError:
        return NetworkFailure.noInternet();
      default:
        return ServerFailure('Error de red: ${error.message}');
    }
  }

  static Failure _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = error.response?.data?['message'] ?? 'Error del servidor';
    
    switch (statusCode) {
      case 400:
        return ServerFailure.badRequest();
      case 401:
        return AuthFailure('No autorizado: $message');
      case 403:
        return AuthFailure('Prohibido: $message');
      case 404:
        return ServerFailure.notFound();
      case 500:
        return ServerFailure.internalError();
      default:
        return ServerFailure('Error del servidor ($statusCode): $message');
    }
  }
}