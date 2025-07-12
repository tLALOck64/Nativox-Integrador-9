import 'package:dio/dio.dart';
import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/network/exceptions/network_exceptions.dart';

class ErrorHandler {
  static Failure handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is NetworkException) {
      return _handleNetworkException(error);
    } else if (error is Exception) {
      return ServerFailure(error.toString());
    } else {
      return const ServerFailure('Error desconocido');
    }
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Tiempo de conexión agotado');
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      case DioExceptionType.cancel:
        return const NetworkFailure('Petición cancelada');
      case DioExceptionType.connectionError:
        return const NetworkFailure('Sin conexión a internet');
      default:
        return const ServerFailure('Error del servidor');
    }
  }

  static Failure _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = error.response?.data?['message'] ?? 'Error del servidor';
    
    switch (statusCode) {
      case 400:
        return ServerFailure('Petición incorrecta: $message');
      case 401:
        return AuthFailure('No autorizado: $message');
      case 403:
        return AuthFailure('Prohibido: $message');
      case 404:
        return ServerFailure('No encontrado: $message');
      case 500:
        return ServerFailure('Error interno del servidor');
      default:
        return ServerFailure('Error del servidor: $message');
    }
  }

  static Failure _handleNetworkException(NetworkException error) {
    return NetworkFailure(error.message);
  }
}
