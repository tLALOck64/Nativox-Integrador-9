// TODO Implement this library.
import 'package:dio/dio.dart';
import 'package:integrador/core/network/exceptions/network_exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    NetworkException exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = NetworkException.requestTimeout();
        break;
      case DioExceptionType.badResponse:
        exception = _handleBadResponse(err);
        break;
      case DioExceptionType.cancel:
        exception = NetworkException.requestCancelled();
        break;
      case DioExceptionType.connectionError:
        exception = NetworkException.noInternetConnection();
        break;
      default:
        exception = NetworkException.unexpectedError();
    }

    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: exception,
    ));
  }

  NetworkException _handleBadResponse(DioException err) {
    switch (err.response?.statusCode) {
      case 400:
        return NetworkException.badRequest();
      case 401:
        return NetworkException.unauthorizedRequest();
      case 403:
        return NetworkException.forbidden();
      case 404:
        return NetworkException.notFound();
      case 409:
        return NetworkException.conflict();
      case 500:
        return NetworkException.internalServerError();
      default:
        return NetworkException.unexpectedError();
    }
  }
}
