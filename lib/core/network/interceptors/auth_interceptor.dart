// TODO Implement this library.
import 'package:dio/dio.dart';
import 'package:integrador/core/services/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService = StorageService();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expirado, intentar refresh
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken != null) {
        try {
          // Implementar lógica de refresh token
          final newToken = await _refreshToken(refreshToken);
          await _storageService.saveToken(newToken);
          
          // Reintentar la petición original
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          
          final dio = Dio();
          final response = await dio.fetch(requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Si falla el refresh, cerrar sesión
          await _storageService.clearTokens();
          // Navegar a login
        }
      }
    }
    handler.next(err);
  }

  Future<String> _refreshToken(String refreshToken) async {
    // Implementar lógica de refresh token
    final dio = Dio();
    final response = await dio.post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });
    return response.data['access_token'];
  }
}
