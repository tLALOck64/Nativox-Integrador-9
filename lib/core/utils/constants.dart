// TODO Implement this library.
class AppConstants {
  // API
  static const String baseUrl = 'https://a3pl892azf.execute-api.us-east-1.amazonaws.com ';
  static const String apiVersion = 'v1';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Cache
  static const Duration defaultCacheExpiry = Duration(hours: 1);
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
}