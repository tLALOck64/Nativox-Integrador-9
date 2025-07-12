// TODO Implement this library.
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException._(this.message, this.statusCode);

  factory NetworkException.requestCancelled() {
    return const NetworkException._('Request cancelled', null);
  }

  factory NetworkException.unauthorizedRequest() {
    return const NetworkException._('Unauthorized request', 401);
  }

  factory NetworkException.badRequest() {
    return const NetworkException._('Bad request', 400);
  }

  factory NetworkException.notFound() {
    return const NetworkException._('Not found', 404);
  }

  factory NetworkException.requestTimeout() {
    return const NetworkException._('Connection timeout', null);
  }

  factory NetworkException.noInternetConnection() {
    return const NetworkException._('No internet connection', null);
  }

  factory NetworkException.conflict() {
    return const NetworkException._('Conflict', 409);
  }

  factory NetworkException.forbidden() {
    return const NetworkException._('Forbidden', 403);
  }

  factory NetworkException.internalServerError() {
    return const NetworkException._('Internal server error', 500);
  }

  factory NetworkException.unexpectedError() {
    return const NetworkException._('Unexpected error occurred', null);
  }

  @override
  String toString() => 'NetworkException: $message';
}